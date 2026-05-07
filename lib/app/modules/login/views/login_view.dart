import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna background yang lebih elegan (biru pucat/soft grey)
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Deteksi Web / Layar Besar
            double maxWidth = constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      // LOGO & NAMA APP (Pindah ke atas card agar lebih lega)
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
                              width: 60, // Logo lebih besar dan fokus
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "HappyTrip",
                            style: TextStyle(
                              fontSize: 28, // Font lebih besar
                              fontWeight: FontWeight.w900, // Lebih bold
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

                      // CARD INPUT
                      Container(
                        padding: const EdgeInsets.all(28), // Padding dalam lebih luas
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
                            _buildLabel("Email"),
                            TextField(
                              decoration: _inputStyle(
                                hint: "nama@email.com",
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // FIELD PASSWORD
                            _buildLabel("Password"),
                            TextField(
                              obscureText: true,
                              decoration: _inputStyle(
                                hint: "••••••••",
                                icon: Icons.lock_outline,
                                suffixIcon: Icons.visibility_off_outlined,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    color: Color(0xFF0061A8),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // TOMBOL LOGIN (DIBUAT SANGAT DOMINAN)
                            SizedBox(
                              width: double.infinity,
                              height: 56, // Tombol lebih tinggi dan besar
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.offAllNamed(Routes.HOME);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0061A8),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: const Color(0xFF0061A8).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18, // Font di tombol lebih besar
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // REGISTER LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed("/register"),
                            child: const Text(
                              "Daftar Sekarang",
                              style: TextStyle(
                                color: Color(0xFF0061A8),
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      )
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

  // Helper untuk Label Input
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  // Style Input Modern (Sama dengan style Register sebelumnya agar konsisten)
  InputDecoration _inputStyle({required String hint, required IconData icon, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF0061A8), size: 22),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black45, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}