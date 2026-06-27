import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../routes/app_pages.dart';
import '../../../services/trip_log_service.dart';

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
        
        // 1. Simpan Token
        String token = responseData['access_token'];
        box.write('token', token);

        // 2. Simpan Data User (Nama & Email) dari objek 'user' yang dikirim backend
        if (responseData['user'] != null) {
          box.write('user_nama', responseData['user']['nama']);
          box.write('user_email', responseData['user']['email']); // Simpan email dari server
          debugPrint("DEBUG: Data user berhasil disimpan: ${responseData['user']['nama']}");
        } else {
          // Fallback jika API lupa kirim objek user, tetap simpan email dari input manual
          box.write('user_email', email.value.trim());
        }

        // Sinkronisasi log perjalanan untuk pengguna baru
        if (Get.isRegistered<TripLogService>()) {
          TripLogService.to.loadLogs();
        }

        // ─── SYNC LOGIC: SINKRONISASI STATUS DAFTAR WAJAH DARI SERVER ME-ENDPOINT ───
        try {
          final String profileUrl = 'http://api.api-happytrip.my.id/auth/me';
          var profileResponse = await http.get(
            Uri.parse(profileUrl),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (profileResponse.statusCode == 200) {
            var profileData = jsonDecode(profileResponse.body);
            bool isFaceRegOnServer = profileData['is_face_registered'] ?? false;
            box.write('is_face_active', isFaceRegOnServer);
            isFaceRegistered.value = isFaceRegOnServer;
            debugPrint("DEBUG: Sinkronisasi wajah berhasil. Terdaftar di server: $isFaceRegOnServer");
          }
        } catch (e) {
          debugPrint("DEBUG: Gagal sinkronisasi status wajah dari server: $e");
        }

        // ─── LOGIKA 2: SELEKSI KONDISI PEMAKSAAN REKAM WAJAH ───
        bool needsFaceReg = (box.read('needs_face_registration') == true) && 
                            (box.read('registered_email') == email.value.trim());

        if (needsFaceReg) {
          _showCustomSnackbar(
            title: 'Verifikasi Berhasil',
            message: 'Akun aktif! Selesaikan pendaftaran wajah Anda.',
            isError: false,
          );
          Get.toNamed(Routes.FACE_LOGIN, arguments: email.value.trim());
        } else {
          _showCustomSnackbar(
            title: 'Login Berhasil',
            message: 'Selamat datang kembali!',
            isError: false,
          );
          Get.offAllNamed(Routes.HOME);
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