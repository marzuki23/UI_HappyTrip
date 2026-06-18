import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background biru muda pucat sesuai desain
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsivitas untuk layar lebar (Web/Tablet)
            double maxWidth = constraints.maxWidth > 600
                ? 400
                : constraints.maxWidth * 0.9;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      // --- HEADER: LOGO & NAMA APP ---
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.explore,
                                    size: 40,
                                    color: Color(0xFF0061A8),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "HappyTrip",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0061A8),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Masuk untuk melanjutkan perjalanan Anda",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // --- FORM CARD ---
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FIELD EMAIL
                            _buildLabel("EMAIL"),
                            TextField(
                              onChanged: (value) => controller.email.value = value,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputStyle(
                                hint: "nama@email.com",
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // FIELD PASSWORD DENGAN TOMBOL MATA (SINKRON KE CONTROLLER)
                            _buildLabel("PASSWORD"),
                            Obx(() {
                              return TextField(
                                onChanged: (value) => controller.password.value = value,
                                obscureText: controller.isPasswordHidden.value,
                                decoration: InputDecoration(
                                  hintText: "••••••••",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black45, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isPasswordHidden.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black38,
                                      size: 18,
                                    ),
                                    onPressed: () => controller.togglePasswordVisibility(),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF3F4F6),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 12),

                            // LUPA PASSWORD
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Get.toNamed(Routes.FORGOT_PASSWORD);
                                },
                                child: const Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    color: Color(0xFF0061A8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // TOMBOL LOGIN UTAMA DENGAN INDIKATOR LOADING
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Obx(() {
                                return ElevatedButton(
                                  onPressed: controller.isLoading.value 
                                      ? null 
                                      : () => controller.loginUser(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0061A8),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(0xFF0061A8).withOpacity(0.6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // ─── FITUR LOGIKA BARU: TOMBOL FACE RECOGNITION MANDIRI ───
                            Obx(() {
                              bool isActive = controller.isFaceRegistered.value;
                              return SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: isActive 
                                      ? () {
                                          String targetEmail = controller.email.value.trim();
                                          if (targetEmail.isEmpty) {
                                            targetEmail = controller.box.read('user_email') ?? '';
                                          }
                                          if (targetEmail.isEmpty) {
                                            Get.snackbar(
                                              'Email Diperlukan',
                                              'Silakan masukkan email Anda terlebih dahulu untuk menggunakan masuk wajah.',
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: const Color(0xFFBA1A1A),
                                              colorText: Colors.white,
                                            );
                                            return;
                                          }
                                          Get.toNamed(Routes.FACE_LOGIN, arguments: targetEmail);
                                        }
                                      : null, // Jika belum daftar wajah, tombol mati (tidak bisa di-klik)
                                  icon: Icon(
                                    isActive ? Icons.face_unlock_rounded : Icons.face_retouching_off_rounded, 
                                    color: isActive ? const Color(0xFF0061A8) : Colors.black38,
                                    size: 22,
                                  ),
                                  label: Text(
                                    isActive ? "Masuk dengan Verifikasi Wajah" : "Biometrik Wajah Belum Aktif",
                                    style: TextStyle(
                                      fontSize: 15, // Ukuran teks yang pas dan proporsional
                                      fontWeight: FontWeight.w600, // Menggunakan semi-bold agar lebih elegan
                                      color: isActive ? const Color(0xFF0061A8) : Colors.black38,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isActive ? const Color(0xFF0061A8) : Colors.grey.shade300, 
                                      width: 1.2, // Ketebalan garis border premium
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30), // Mengikuti kelengkungan tombol login utama Anda
                                    ),
                                    backgroundColor: isActive ? Colors.transparent : Colors.grey.shade100, // Efek dim saat tidak aktif
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 20),

                            // FOOTER: DAFTAR SEKARANG
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Belum punya akun? ",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(Routes.REGISTER),
                                  child: const Text(
                                    "Daftar Sekarang",
                                    style: TextStyle(
                                      color: Color(0xFF0061A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _inputStyle({
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.black38, size: 18)
          : null,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}