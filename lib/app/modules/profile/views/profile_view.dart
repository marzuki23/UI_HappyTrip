import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Padding disesuaikan agar tombol logout punya jarak ke bawah
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40, // Memastikan halaman penuh
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Memaksa logout ke bawah
              children: [
                // BAGIAN ATAS: KARTU PROFIL
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar Lingkaran Placeholder
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0061A8).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 54,
                              color: Color(0xFF0061A8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Menampilkan Nama Pengguna Dinamis dari Backend
                          Obx(() => Text(
                                controller.userName.value,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              )),
                          const SizedBox(height: 6),
                          // Menampilkan Email Pengguna Dinamis
                          Obx(() => Text(
                                controller.userEmail.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500, // <-- SUDAH DI-FIX DARI MEDIUM
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                // BAGIAN BAWAH: TOMBOL LOGOUT (SUDAH DIHUBUNGKAN KE CONTROLLER)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      // Memicu fungsi hapus session di controller secara aman
                      onPressed: () => controller.logoutUser(), 
                      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}