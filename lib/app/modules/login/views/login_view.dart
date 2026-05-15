import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:happytrip/app/modules/forgot_password/views/forgot_password_view.dart';

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
            double maxWidth = constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

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
                                )
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.explore, size: 40, color: Color(0xFF0061A8)),
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
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FIELD EMAIL
                            _buildLabel("EMAIL"),
                            TextField(
                              decoration: _inputStyle(
                                hint: "nama@email.com",
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // FIELD PASSWORD
                            _buildLabel("PASSWORD"),
                            TextField(
                              obscureText: true,
                              decoration: _inputStyle(
                                hint: "••••••••",
                                icon: Icons.lock_outline,
                                suffixIcon: Icons.visibility_off_outlined,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // LUPA PASSWORD
                            Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Ini fungsi untuk pindah halaman
                              Get.to(() => const ForgotPasswordView()); 
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

                            // TOMBOL LOGIN UTAMA
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => Get.offAllNamed(Routes.HOME),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0061A8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // PEMISAH ATAU
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "ATAU",
                                    style: TextStyle(
                                      color: Colors.grey, 
                                      fontSize: 11, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // TOMBOL GOOGLE (ASSET)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/google.png", // <--- Ganti dengan asset lokal kamu
                                      height: 22,
                                      errorBuilder: (context, error, stackTrace) => 
                                          const Icon(Icons.login, color: Colors.red),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Login dengan Google",
                                      style: TextStyle(
                                        color: Colors.black87, 
                                        fontSize: 15, 
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 35),

                            // FOOTER: DAFTAR SEKARANG
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Belum punya akun? ",
                                  style: TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed("/register"),
                                  child: const Text(
                                    "Daftar Sekarang",
                                    style: TextStyle(
                                      color: Color(0xFF0061A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              ],
                            )
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
          letterSpacing: 0.5
        ),
      ),
    );
  }

  InputDecoration _inputStyle({required String hint, required IconData icon, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black38, size: 18) : null,
      filled: true,
      fillColor: const Color(0xFFF3F4F6), // Warna abu muda tipis
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0061A8), width: 1),
      ),
    );
  }
}