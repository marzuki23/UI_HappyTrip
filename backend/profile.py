import logging
import os
import smtplib
import uuid
from datetime import datetime, timedelta, timezone
from email.mime.text import MIMEText
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from fastapi.responses import FileResponse, HTMLResponse
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
BASE_URL = os.getenv("BASE_URL", "http://api.api-happytrip.my.id")

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}
MAX_FILE_SIZE = 5 * 1024 * 1024
PHOTO_DIR = "static/profile_photos"
DEFAULT_PHOTO = "static/default-profile.png"

_verification_tokens: dict[str, dict] = {}


class TokenData(BaseModel):
    user_id: int
    nama: str
    email: str


class ProfileUpdate(BaseModel):
    nama: Optional[str] = None
    email: Optional[str] = None


def _user_attr(user: User, attr: str, default=None):
    return getattr(user, attr, default)


def get_token_data(authorization: str = Depends(lambda: None)) -> TokenData:
    auth_header = authorization
    if not auth_header:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authorization header missing")
    scheme, _, token = auth_header.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authorization scheme")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("user_id")
        nama: str = payload.get("nama")
        email: str = payload.get("sub")
        if user_id is None or email is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
        return TokenData(user_id=user_id, nama=nama, email=email)
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token")


async def get_current_user(
    token_data: TokenData = Depends(get_token_data),
    db: Session = Depends(get_db),
) -> User:
    user = db.query(User).filter(User.id == token_data.user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
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


def _send_verification_link(to_email: str, token: str, verify_path: str, context: str):
    link = f"{BASE_URL}{verify_path}?token={token}"
    body = (
        f"Halo,\n\n"
        f"Anda menerima email ini karena ada permintaan {context}.\n\n"
        f"Klik tautan berikut untuk verifikasi:\n{link}\n\n"
        f"Tautan ini berlaku selama 10 menit.\n"
        f"Jika Anda tidak melakukan permintaan ini, abaikan email ini.\n\n"
        f"Terima kasih,\n{os.getenv('APP_NAME', 'HappyTrip')}"
    )
    _send_email(to_email, context, body)


_VERIFY_PAGE = """\
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title}</title>
  <style>
    body {{
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex; justify-content: center; align-items: center;
      min-height: 100vh; margin: 0; background: #f0f5f9;
    }}
    .card {{
      background: white; border-radius: 24px; padding: 48px 40px;
      text-align: center; max-width: 420px; width: 90%;
      box-shadow: 0 8px 32px rgba(0,0,0,0.08);
    }}
    .icon {{ font-size: 64px; margin-bottom: 16px; }}
    h1 {{ font-size: 22px; color: #1E293B; margin: 0 0 8px; }}
    p {{ font-size: 14px; color: #64748B; line-height: 1.5; margin: 0; }}
    .btn {{
      display: inline-block; margin-top: 24px; padding: 12px 32px;
      background: #0061A8; color: white; border-radius: 12px;
      text-decoration: none; font-weight: 600; font-size: 14px;
    }}
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">{icon}</div>
    <h1>{title}</h1>
    <p>{message}</p>
    <a class="btn" href="{btn_url}">{btn_text}</a>
  </div>
</body>
</html>
"""


def _verify_page(title: str, icon: str, message: str, btn_url: str, btn_text: str) -> HTMLResponse:
    return HTMLResponse(
        _VERIFY_PAGE.format(title=title, icon=icon, message=message, btn_url=btn_url, btn_text=btn_text)
    )


# ─── REGISTRASI ─────────────────────────────────
# Flutter sends multipart form: nama, email, password

@router.post("/auth/register")
async def register(
    nama: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db),
):
    email = email.strip().lower()
    nama = nama.strip()

    if not nama:
        raise HTTPException(status_code=400, detail="Nama tidak boleh kosong")
    if not email or "@" not in email:
        raise HTTPException(status_code=400, detail="Email tidak valid")
    if len(password) < 6:
        raise HTTPException(status_code=400, detail="Password minimal 6 karakter")

    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email sudah terdaftar")

    token = uuid.uuid4().hex
    user = User(nama=nama, email=email, password=password, is_verified=False)
    db.add(user)
    db.commit()
    db.refresh(user)

    _verification_tokens[token] = {
        "user_id": user.id,
        "email": email,
        "expires_at": datetime.now(timezone.utc) + timedelta(minutes=10),
        "type": "register",
    }
    _send_verification_link(email, token, "/auth/register/verify", "verifikasi pendaftaran")

    return {
        "status": "success",
        "message": f"Tautan verifikasi telah dikirim ke {email}",
    }


@router.get("/auth/register/verify")
async def verify_registration(token: str = Query(...), db: Session = Depends(get_db)):
    data = _verification_tokens.get(token)
    if not data or data.get("type") != "register":
        return _verify_page(
            "Tautan Tidak Valid", "&#x274C;",
            "Tautan verifikasi tidak valid atau sudah digunakan.",
            BASE_URL, "Kembali ke Beranda",
        )
    if data["expires_at"] < datetime.now(timezone.utc):
        _verification_tokens.pop(token, None)
        return _verify_page(
            "Tautan Kedaluwarsa", "&#x23F3;",
            "Tautan verifikasi sudah kedaluwarsa. Silakan daftar ulang.",
            BASE_URL, "Kembali ke Beranda",
        )
    user = db.query(User).filter(User.id == data["user_id"]).first()
    if not user:
        return _verify_page(
            "User Tidak Ditemukan", "&#x274C;",
            "Akun tidak ditemukan.",
            BASE_URL, "Kembali ke Beranda",
        )
    user.is_verified = True
    db.commit()
    _verification_tokens.pop(token, None)
    return _verify_page(
        "Verifikasi Berhasil!", "&#x2705;",
        "Akun Anda berhasil diverifikasi. Silakan login untuk melanjutkan.",
        f"{BASE_URL}/login", "Login",
    )


# ─── PROFIL ─────────────────────────────────
# Flutter GET /auth/me → {nama, email, photo_url}

@router.get("/auth/me")
async def get_me(current_user: User = Depends(get_current_user)):
    photo_url = _user_attr(current_user, "photo_url")
    return {
        "id": current_user.id,
        "nama": current_user.nama,
        "email": current_user.email,
        "is_face_registered": _user_attr(current_user, "is_face_registered", False),
        "photo_url": f"/static/profile_photos/{photo_url}" if photo_url else None,
    }


# Flutter PUT /auth/profile with JSON: {nama} or {email}

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

        token = uuid.uuid4().hex
        _verification_tokens[token] = {
            "user_id": current_user.id,
            "email": current_user.email,
            "pending_email": new_email,
            "expires_at": datetime.now(timezone.utc) + timedelta(minutes=10),
            "type": "profile_email",
        }
        _send_verification_link(new_email, token, "/auth/profile/email/verify", "verifikasi perubahan email")
        db.commit()
        return {
            "status": "email_verification_required",
            "message": f"Tautan verifikasi telah dikirim ke {new_email}",
        }

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="Email sudah digunakan")
    return {"status": "success", "message": "Profile updated"}


# Flutter does not call this anymore, but keep for link-based verification
@router.get("/auth/profile/email/verify")
async def verify_profile_email(token: str = Query(...), db: Session = Depends(get_db)):
    data = _verification_tokens.get(token)
    if not data or data.get("type") != "profile_email":
        return _verify_page(
            "Tautan Tidak Valid", "&#x274C;",
            "Tautan verifikasi tidak valid atau sudah digunakan.",
            BASE_URL, "Kembali ke Beranda",
        )
    if data["expires_at"] < datetime.now(timezone.utc):
        _verification_tokens.pop(token, None)
        return _verify_page(
            "Tautan Kedaluwarsa", "&#x23F3;",
            "Tautan verifikasi sudah kedaluwarsa. Silakan ulangi perubahan email.",
            BASE_URL, "Kembali ke Beranda",
        )
    user = db.query(User).filter(User.id == data["user_id"]).first()
    if not user:
        return _verify_page(
            "User Tidak Ditemukan", "&#x274C;",
            "Akun tidak ditemukan.",
            BASE_URL, "Kembali ke Beranda",
        )
    new_email = data["pending_email"]
    existing = db.query(User).filter(
        User.email == new_email, User.id != user.id
    ).first()
    if existing:
        _verification_tokens.pop(token, None)
        return _verify_page(
            "Email Sudah Digunakan", "&#x274C;",
            "Email tersebut sudah terdaftar oleh akun lain.",
            BASE_URL, "Kembali ke Beranda",
        )
    user.email = new_email
    db.commit()
    _verification_tokens.pop(token, None)
    return _verify_page(
        "Email Berhasil Diperbarui!", "&#x2705;",
        "Alamat email Anda berhasil diperbarui.",
        BASE_URL, "Kembali ke Beranda",
    )


# ─── FOTO PROFIL ─────────────────────────────────
# Flutter POST /auth/profile/photo with multipart file field "photo"

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

    try:
        current_user.photo_url = filename
    except AttributeError:
        logger.warning("User model has no 'photo_url' column. File saved but not linked to user.")
        return {
            "status": "success",
            "photo_url": f"/static/profile_photos/{filename}",
            "warning": "photo_url column not found in User model. Run: ALTER TABLE users ADD COLUMN photo_url VARCHAR(255) DEFAULT NULL;",
        }
    db.commit()
    return {"status": "success", "photo_url": f"/static/profile_photos/{filename}"}


@router.get("/auth/profile/photo/{user_id}")
async def get_profile_photo(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    photo_url = _user_attr(user, "photo_url")
    if photo_url:
        filepath = os.path.join(PHOTO_DIR, photo_url)
        if os.path.isfile(filepath):
            return FileResponse(filepath, media_type="image/jpeg")
    if os.path.isfile(DEFAULT_PHOTO):
        return FileResponse(DEFAULT_PHOTO, media_type="image/png")
    raise HTTPException(status_code=404, detail="Photo not found")
