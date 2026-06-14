import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordController extends GetxController {
  late TextEditingController emailController;
  final GlobalKey<FormState> forgotFormKey = GlobalKey<FormState>();
  
  // State indikator loading saat mengirim email ke server
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetInstructions() async {
    // 1. Validasi regex form email bawaan Flutter
    if (!forgotFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // 2. Setup URL Endpoint cPanel sesuai arsitektur main.py Anda
      final String url = 'http://api.api-happytrip.my.id/auth/forgot-password';
      
      // Menggunakan MultipartRequest karena backend Anda menggunakan skrip Form(...) FastAPI
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['email'] = emailController.text.trim();

      // Send request ke Cloud Neon Server
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;

      // 3. Pengondisian Respon Server
      if (response.statusCode == 200) {
        // Berhasil memicu sistem Resend Email di Backend cPanel
        Get.snackbar(
          "Email Terkirim",
          "Instruksi reset password telah dikirim ke ${emailController.text.trim()}. Silakan cek kotak masuk atau folder spam Anda.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF27AE60), // Hijau sukses
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 5),
        );

        // Tunggu 3 detik lalu otomatis kembalikan pengguna ke halaman Login
        Future.delayed(const Duration(seconds: 3), () {
          Get.back();
        });
      } else {
        // Jika email tidak terdaftar atau server menolak
        String pesanGagal = "Gagal memproses permintaan reset password.";
        try {
          var responseData = jsonDecode(response.body);
          if (responseData['detail'] != null) {
            pesanGagal = responseData['detail'];
          }
        } catch (_) {}

        Get.snackbar(
          "Permintaan Gagal",
          pesanGagal,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFBA1A1A), // Merah error
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Koneksi Bermasalah",
        "Terjadi kesalahan sistem saat menghubungi server: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
      );
    }
  }
}