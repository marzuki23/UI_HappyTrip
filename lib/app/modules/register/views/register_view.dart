import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9), 
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
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
                              onChanged: (value) => controller.nama.value = value,
                              decoration: _inputStyle(
                                hint: "Masukkan nama Anda",
                                icon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // EMAIL
                            _buildLabel("Email"),
                            TextField(
                              onChanged: (value) => controller.email.value = value,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputStyle(
                                hint: "nama@email.com",
                                icon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // PASSWORD WITH EYE TOGGLE
                            _buildLabel("Password"),
                            Obx(() {
                              return TextField(
                                onChanged: (value) => controller.password.value = value,
                                obscureText: controller.isPasswordHidden.value, // Tergantung status controller
                                decoration: _inputStyle(
                                  hint: "Minimal 6 karakter",
                                  icon: Icons.lock_outline,
                                  // Menggunakan Widget IconButton agar bisa di-klik oleh pengguna
                                  suffixWidget: IconButton(
                                    icon: Icon(
                                      controller.isPasswordHidden.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black45,
                                      size: 20,
                                    ),
                                    onPressed: () => controller.togglePasswordVisibility(),
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 35),

                            // BUTTON DAFTAR
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Obx(() {
                                return ElevatedButton(
                                  onPressed: controller.isLoading.value ? null : () => controller.registerUser(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0061A8),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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
                                          "Daftar",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              }),
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

  // Modifikasi sedikit helper agar menerima suffixWidget berupa kustom widget / IconButton
  InputDecoration _inputStyle({required String hint, required IconData icon, Widget? suffixWidget}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      suffixIcon: suffixWidget, // Memasukkan IconButton kustom di sini
      filled: true,
      fillColor: const Color(0xFFF3F4F6), 
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}