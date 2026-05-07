import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background disesuaikan agar lebih soft/biru pucat seperti di gambar
      backgroundColor: const Color(0xFFF0F5F9), 
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth =
                constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      // TITLE APP (Di Luar Card)
                      const Text(
                        "HappyTrip",
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF0061A8),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      
                      const SizedBox(height: 60),

                      const Text(
                        "Buat Akun",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Mulai penjelajahan tanpa batas bersama kami.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 35),

                      // CARD UTAMA
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAMA LENGKAP
                            _buildLabel("Nama Lengkap"),
                            TextField(
                              decoration: _inputStyle(
                                hint: "Masukkan nama Anda",
                                icon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // EMAIL
                            _buildLabel("Email"),
                            TextField(
                              decoration: _inputStyle(
                                hint: "nama@email.com",
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // PASSWORD
                            _buildLabel("Password"),
                            TextField(
                              obscureText: true,
                              decoration: _inputStyle(
                                hint: "Minimal 8 karakter",
                                icon: Icons.lock_outline,
                                suffixIcon: Icons.visibility_off_outlined,
                              ),
                            ),

                            const SizedBox(height: 35),

                            // BUTTON DAFTAR
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0061A8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // LOGIN LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sudah punya akun? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                color: Color(0xFF0061A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  // Style Input agar sesuai dengan gambar
  InputDecoration _inputStyle({required String hint, required IconData icon, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.black45, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF3F4F6), // Abu-abu muda sesuai gambar
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}