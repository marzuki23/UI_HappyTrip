import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  var nama = ''.obs;
  var email = ''.obs;
  var password = ''.obs;

  var isLoading = false.obs;
  
  // ─── FITUR BARU: VARIABEL UNTUK SELEKSI LIHAT PASSWORD ───
  var isPasswordHidden = true.obs;

  // Fungsi untuk membalikkan status menyembunyikan/melihat password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> registerUser() async {
    if (nama.value.trim().isEmpty || email.value.trim().isEmpty || password.value.isEmpty) {
      _showCustomSnackbar(
        title: 'Formulir Belum Lengkap',
        message: 'Silakan isi semua kolom yang tersedia sebelum melanjutkan.',
        isError: true,
      );
      return;
    }

    if (!GetUtils.isEmail(email.value.trim())) {
      _showCustomSnackbar(
        title: 'Format Email Salah',
        message: 'Silakan masukkan alamat email yang valid (contoh: nama@gmail.com).',
        isError: true,
      );
      return;
    }

    // DISINKRONKAN: Sesuai aturan len(new_password) < 6 di main.py cPanel
    if (password.value.length < 6) {
      _showCustomSnackbar(
        title: 'Password Terlalu Pendek',
        message: 'Demi keamanan, gunakan password minimal 6 karakter atau lebih.',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      final String url = 'http://api.api-happytrip.my.id/auth/register';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      request.fields['nama'] = nama.value.trim();
      request.fields['email'] = email.value.trim();
      request.fields['password'] = password.value;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        String pesanError = 'Tidak dapat memproses pendaftaran saat ini.';
        
        try {
          // jsonDecode ini otomatis membaca teks kustom: "Email sudah terdaftar! Silakan gunakan email lain atau langsung masuk." dari backend baru
          var errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            pesanError = errorData['detail'];
          }
        } catch (e) {
          pesanError = response.body;
        }

        _showCustomSnackbar(
          title: 'Registrasi Gagal',
          message: pesanError,
          isError: true,
        );
      }
    } catch (e) {
      isLoading.value = false;
      _showCustomSnackbar(
        title: 'Masalah Koneksi',
        message: 'Gagal terhubung ke server. Pastikan perangkat Anda tersambung ke internet.',
        isError: true,
      );
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 70),
            const SizedBox(height: 20),
            const Text(
              'Registrasi Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 12),
            Text(
              'Akun Anda atas nama "${nama.value}" berhasil didaftarkan. Harap periksa folder kotak masuk atau spam pada email ${email.value} untuk mengaktifkan akun Anda sebelum masuk.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0061A8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ke Halaman Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCustomSnackbar({required String title, required String message, bool isError = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF0061A8),
      colorText: Colors.white,
      icon: Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () { if (Get.isSnackbarOpen) Get.back(); },
        child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}