import logging
import os
import random
import smtplib
import uuid
from datetime import datetime, timedelta, timezone
from email.mime.text import MIMEText
from typing import Optional

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from fastapi.responses import FileResponse
from jose import JWTError, jwt
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.database import get_db
from app.models import User

logger = logging.getLogger(__name__)

router = APIRouter(tags=["profile"])

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
ALGORITHM = "HS256"

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}
MAX_FILE_SIZE = 5 * 1024 * 1024
PHOTO_DIR = "static/profile_photos"
DEFAULT_PHOTO = "static/default-profile.png"

_email_verifications: dict[int, dict] = {}


class TokenData(BaseModel):
    user_id: int
    nama: str
    email: str


class ProfileUpdate(BaseModel):
    nama: Optional[str] = None
    email: Optional[str] = None


class EmailConfirm(BaseModel):
    email: str
    code: str


class RegisterRequest(BaseModel):
    nama: str
    email: str
    password: str


class EmailVerifyRequest(BaseModel):
    email: str
    code: str


def get_token_data(authorization: str = Depends(lambda: None)) -> TokenData:
    auth_header = authorization
    if not auth_header:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing",
        )
    scheme, _, token = auth_header.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization scheme",
        )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("user_id")
        nama: str = payload.get("nama")
        email: str = payload.get("sub")
        if user_id is None or email is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token payload",
            )
        return TokenData(user_id=user_id, nama=nama, email=email)
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )


async def get_current_user(
    token_data: TokenData = Depends(get_token_data),
    db: Session = Depends(get_db),
) -> User:
    user = db.query(User).filter(User.id == token_data.user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return user


def _send_email(to_email: str, subject: str, body: str):
    smtp_host = os.getenv("SMTP_HOST")
    if smtp_host:
        try:
            smtp_port = int(os.getenv("SMTP_PORT", "587"))
            smtp_user = os.getenv("SMTP_USER")
            smtp_pass = os.getenv("SMTP_PASS")
            from_email = os.getenv("SMTP_FROM", smtp_user)
            app_name = os.getenv("APP_NAME", "HappyTrip")

            msg = MIMEText(body, "plain", "utf-8")
            msg["Subject"] = f"[{app_name}] {subject}"
            msg["From"] = from_email
            msg["To"] = to_email

            with smtplib.SMTP(smtp_host, smtp_port) as server:
                server.starttls()
                if smtp_user and smtp_pass:
                    server.login(smtp_user, smtp_pass)
                server.send_message(msg)
            logger.info("Email sent to %s: %s", to_email, subject)
            return
        except Exception as e:
            logger.warning("Failed to send email via SMTP: %s", e)
    logger.info("DEV: Email to %s — %s\n%s", to_email, subject, body)


def _send_verification_email(to_email: str, code: str, context: str = "verifikasi email"):
    _send_email(
        to_email,
        f"Kode {context}",
        (
            f"Kode {context} Anda: {code}\n\n"
            f"Kode ini berlaku selama 10 menit.\n"
            f"Jika Anda tidak meminta perubahan ini, abaikan email ini.\n\n"
            f"Terima kasih,\n{os.getenv('APP_NAME', 'HappyTrip')}"
        ),
    )


@router.post("/auth/register")
async def register(body: RegisterRequest, db: Session = Depends(get_db)):
    email = body.email.strip().lower()
    nama = body.nama.strip()
    password = body.password

    if not nama:
        raise HTTPException(status_code=400, detail="Nama tidak boleh kosong")
    if not email or "@" not in email:
        raise HTTPException(status_code=400, detail="Email tidak valid")
    if len(password) < 6:
        raise HTTPException(status_code=400, detail="Password minimal 6 karakter")

    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email sudah terdaftar")

    code = f"{random.randint(100000, 999999)}"
    user = User(nama=nama, email=email, password=password, is_verified=False)
    db.add(user)
    db.commit()
    db.refresh(user)

    _email_verifications[user.id] = {
        "pending_email": email,
        "code": code,
        "expires_at": datetime.now(timezone.utc) + timedelta(minutes=10),
        "type": "register",
    }
    _send_verification_email(email, code, "verifikasi pendaftaran")

    return {
        "status": "email_verification_required",
        "message": f"Kode verifikasi telah dikirim ke {email}",
        "user_id": user.id,
    }


@router.post("/auth/register/verify")
async def verify_registration(body: EmailVerifyRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == body.email.strip().lower()).first()
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")

    pending = _email_verifications.get(user.id)
    if not pending or pending.get("type") != "register":
        raise HTTPException(status_code=400, detail="Tidak ada verifikasi pending")

    if pending["expires_at"] < datetime.now(timezone.utc):
        _email_verifications.pop(user.id, None)
        raise HTTPException(status_code=400, detail="Kode verifikasi sudah kedaluwarsa")

    if pending["code"] != body.code:
        raise HTTPException(status_code=400, detail="Kode verifikasi salah")

    user.is_verified = True
    db.commit()
    _email_verifications.pop(user.id, None)

    return {
        "status": "success",
        "message": "Akun berhasil diverifikasi. Silakan login.",
    }


@router.get("/auth/me")
async def get_me(current_user: User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "nama": current_user.nama,
        "email": current_user.email,
        "is_face_registered": getattr(current_user, "is_face_registered", False),
        "photo_url": (
            f"/static/profile_photos/{current_user.photo_url}"
            if current_user.photo_url
            else None
        ),
    }


@router.put("/auth/profile")
async def update_profile(
    profile: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if profile.nama is not None:
        nama = profile.nama.strip()
        if not nama:
            raise HTTPException(status_code=400, detail="Nama tidak boleh kosong")
        current_user.nama = nama

    if profile.email is not None:
        new_email = profile.email.strip().lower()
        if not new_email or "@" not in new_email:
            raise HTTPException(status_code=400, detail="Email tidak valid")

        if new_email == current_user.email:
            db.commit()
            return {"status": "success", "message": "Profile updated"}

        existing = db.query(User).filter(
            User.email == new_email, User.id != current_user.id
        ).first()
        if existing:
            raise HTTPException(status_code=409, detail="Email sudah digunakan")

        code = f"{random.randint(100000, 999999)}"
        _email_verifications[current_user.id] = {
            "pending_email": new_email,
            "code": code,
            "expires_at": datetime.now(timezone.utc) + timedelta(minutes=10),
            "type": "profile_email",
        }
        _send_verification_email(new_email, code, "verifikasi perubahan email")

        db.commit()
        return {
            "status": "email_verification_required",
            "message": f"Kode verifikasi telah dikirim ke {new_email}",
        }

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="Email sudah digunakan")
    return {"status": "success", "message": "Profile updated"}


@router.post("/auth/profile/email/confirm")
async def confirm_email(
    body: EmailConfirm,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pending = _email_verifications.get(current_user.id)
    if not pending or pending.get("type") != "profile_email":
        raise HTTPException(status_code=400, detail="Tidak ada verifikasi email pending")

    if pending["expires_at"] < datetime.now(timezone.utc):
        _email_verifications.pop(current_user.id, None)
        raise HTTPException(status_code=400, detail="Kode verifikasi sudah kedaluwarsa")

    if pending["code"] != body.code:
        raise HTTPException(status_code=400, detail="Kode verifikasi salah")

    new_email = pending["pending_email"]
    existing = db.query(User).filter(
        User.email == new_email, User.id != current_user.id
    ).first()
    if existing:
        _email_verifications.pop(current_user.id, None)
        raise HTTPException(status_code=409, detail="Email sudah digunakan")

    current_user.email = new_email
    db.commit()
    _email_verifications.pop(current_user.id, None)
    return {"status": "success", "message": "Email berhasil diverifikasi dan diperbarui"}


@router.post("/auth/profile/photo")
async def upload_profile_photo(
    photo: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not photo.content_type or not photo.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are allowed")

    ext = os.path.splitext(photo.filename or "photo.jpg")[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"File type {ext} is not supported. Allowed: {', '.join(ALLOWED_EXTENSIONS)}",
        )

    contents = await photo.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum size is {MAX_FILE_SIZE // (1024 * 1024)} MB",
        )

    os.makedirs(PHOTO_DIR, exist_ok=True)
    filename = f"{uuid.uuid4().hex}{ext}"
    filepath = os.path.join(PHOTO_DIR, filename)
    with open(filepath, "wb") as f:
        f.write(contents)

    current_user.photo_url = filename
    db.commit()
    return {"status": "success", "photo_url": f"/static/profile_photos/{filename}"}


@router.get("/auth/profile/photo/{user_id}")
async def get_profile_photo(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.photo_url:
        filepath = os.path.join(PHOTO_DIR, user.photo_url)
        if os.path.isfile(filepath):
            return FileResponse(filepath, media_type="image/jpeg")

    if os.path.isfile(DEFAULT_PHOTO):
        return FileResponse(DEFAULT_PHOTO, media_type="image/png")

    raise HTTPException(status_code=404, detail="Photo not found")
