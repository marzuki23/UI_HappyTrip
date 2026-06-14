import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/face_login_controller.dart';

class FaceLoginView extends GetView<FaceLoginController> {
  const FaceLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // ─── LINGKARAN PREVIEW KAMERA (SUDAH DIPERBAIKI AGAR TIDAK DISTORSI) ───
              Center(
                child: Obx(() {
                  if (!controller.isCameraInitialized.value) {
                    return Container(
                      width: 240,
                      height: 240,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0061A8),
                        ),
                      ),
                    );
                  }

                  // Mengambil ukuran asli resolusi dari hardware sensor kamera depan HP
                  final previewSize = controller.cameraController!.value.previewSize!;
                  
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0061A8), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0061A8).withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: FittedBox(
                        fit: BoxFit.cover, // Memotong gambar secara pas tanpa merusak rasio wajah
                        child: SizedBox(
                          width: previewSize.height,
                          height: previewSize.width,
                          child: CameraPreview(controller.cameraController!),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // KETERANGAN PANDUAN USER
              const Text(
                "Posisikan Wajah di Dalam Lingkaran",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pastikan berada di tempat terang untuk akurasi\nMobileFaceNet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // --- CARD KONFIRMASI EMAIL & TOMBOL PINDAI ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "KONFIRMASI EMAIL AKUN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Input Email Otomatis / Manual
                    TextField(
                      onChanged: (value) => controller.email.value = value,
                      controller: TextEditingController(text: controller.email.value)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.email.value.length),
                        ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "masukkan email terdaftar...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black45, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL EKSEKUSI UTAMA
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Obx(() {
                        return ElevatedButton.icon(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.prosesFaceAuth(),
                          icon: controller.isLoading.value
                              ? const SizedBox.shrink()
                              : const Icon(Icons.face_unlock_rounded, color: Colors.white),
                          label: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Pindai & Verifikasi Wajah",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0061A8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}