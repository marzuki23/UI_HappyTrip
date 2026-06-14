import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  // Variabel pengecekan status Biometrik Wajah di lokal HP
  var isFaceRegistered = false.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Membaca status apakah perangkat ini sudah sukses rekam wajah sebelumnya
    isFaceRegistered.value = box.read('is_face_active') ?? false;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> loginUser() async {
    if (email.value.trim().isEmpty || password.value.isEmpty) {
      _showCustomSnackbar(
        title: 'Formulir Belum Lengkap',
        message: 'Silakan isi email dan password Anda sebelum melanjutkan.',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      final String url = 'http://api.api-happytrip.my.id/auth/login';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['email'] = email.value.trim();
      request.fields['password'] = password.value;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;

      // ─── LOGIKA 1: CEK APAKAH USER BELUM VERIFIKASI EMAIL VIA CPANEL ───
      if (response.statusCode == 403 || response.body.contains("belum diverifikasi")) {
        _showCustomSnackbar(
          title: 'Akun Belum Aktif',
          message: 'Silakan cek kotak masuk atau spam pada email Anda untuk mengaktifkan akun terlebih dahulu.',
          isError: true,
        );
        return;
      }

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        
        // Simpan email data akun secara lokal untuk kebutuhan bypass kamera kelak
        box.write('user_email', email.value.trim());
        box.write('token', responseData['access_token']);

        if (responseData['user'] != null && responseData['user']['nama'] != null) {
          box.write('user_nama', responseData['user']['nama']);
        }

        // ─── LOGIKA 2: SELEKSI KONDISI PEMAKSAAN REKAM WAJAH PERTAMA KALI ───
        if (isFaceRegistered.value == true) {
          _showCustomSnackbar(title: 'Login Berhasil', message: 'Selamat datang kembali di HappyTrip!', isError: false);
          Get.offAllNamed(Routes.HOME);
        } else {
          // Jika baru pertama kali login, paksa masuk halaman Face Login untuk rekam data awal
          _showCustomSnackbar(
            title: 'Verifikasi Berhasil',
            message: 'Akun aktif! Selesaikan pendaftaran wajah Anda untuk fitur login instan selanjutnya.',
            isError: false,
          );
          Get.toNamed(Routes.FACE_LOGIN);
        }
      } else {
        String pesanError = 'Gagal melakukan masuk sistem.';
        try {
          var errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            pesanError = errorData['detail'];
          }
        } catch (e) {
          pesanError = response.body;
        }

        _showCustomSnackbar(
          title: 'Login Gagal',
          message: pesanError,
          isError: true,
        );
      }
    } catch (e) {
      isLoading.value = false;
      _showCustomSnackbar(
        title: 'Masalah Koneksi',
        message: 'Gagal terhubung ke server. Periksa jaringan internet Anda.',
        isError: true,
      );
    }
  }

  void _showCustomSnackbar({required String title, required String message, bool isError = true}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF27AE60),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}