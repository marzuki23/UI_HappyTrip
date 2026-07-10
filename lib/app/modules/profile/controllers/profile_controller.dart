import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../routes/app_pages.dart';
import '../../../services/trip_log_service.dart';

class ProfileController extends GetxController {
  // Observable untuk menampung data nama dan email secara dinamis
  var userName = ''.obs;
  var userEmail = ''.obs;
  // Observable untuk menampung path foto profil (bisa berupa URL network atau path local file)
  var profileImagePath = ''.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Membaca data email dari session lokal
    userEmail.value = box.read('user_email') ?? 'traveler@example.com';

    // Ambil path foto profil spesifik akun jika ada
    profileImagePath.value = box.read('user_photo_path_${userEmail.value}') ?? box.read('user_photo_path') ?? '';

    // ─── AMBIL NAMA ASLI DARI MEMORI, JIKA KOSONG GUNAKAN EMAIL SEBAGAI ALTERNATIF ───
    String? namaTersimpan = box.read('user_nama_${userEmail.value}') ?? box.read('user_nama');
    if (namaTersimpan != null && namaTersimpan.isNotEmpty) {
      userName.value = namaTersimpan;
    } else {
      // Jika nama belum ter-cache (misal login lama), potong bagian depan email sebagai nama sementara
      userName.value = userEmail.value.split('@')[0];
    }
  }

  // Fungsi untuk memilih gambar dari Galeri atau Kamera
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (image != null) {
        await updateProfile(fotoPath: image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal mengambil gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fungsi untuk mengirim pembaruan profil ke backend
  Future<void> updateProfile({String? nama, String? fotoPath}) async {
    try {
      final String url = 'http://api.api-happytrip.my.id/auth/update-profile';
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Sesi login tidak ditemukan. Silakan login kembali.',
        );
        return;
      }

      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      if (nama != null && nama.trim().isNotEmpty) {
        request.fields['nama'] = nama.trim();
      }

      if (fotoPath != null && fotoPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
      }

      Get.showOverlay(
        asyncFunction: () async {
          var streamedResponse = await request.send();
          var response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            if (data['status'] == 'success') {
              var user = data['user'];

              if (user['nama'] != null) {
                userName.value = user['nama'];
                box.write('user_nama', user['nama']);
                box.write('user_nama_${userEmail.value}', user['nama']);
              }

              if (user['foto_url'] != null) {
                profileImagePath.value = user['foto_url'];
                box.write('user_photo_path', user['foto_url']);
                box.write('user_photo_path_${userEmail.value}', user['foto_url']);
              }

              Get.snackbar(
                'Sukses',
                'Profil berhasil diperbarui',
                snackPosition: SnackPosition.BOTTOM,
              );
            } else {
              Get.snackbar(
                'Gagal',
                data['message'] ?? 'Gagal memperbarui profil',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            var errorDetail = 'Gagal memperbarui profil di server';
            try {
              var data = json.decode(response.body);
              errorDetail = data['detail'] ?? errorDetail;
            } catch (_) {}
            Get.snackbar(
              'Gagal',
              errorDetail,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fungsi hapus sesi saat logout tetap aman dan bersih
  void logoutUser() {
    box.remove('token');
    box.remove('user_email');
    box.remove('user_nama'); // Ikut bersihkan cache nama saat keluar aplikasi
    box.remove('user_photo_path'); // Bersihkan foto profil saat logout
    profileImagePath.value = '';

    // Sinkronisasi ulang log agar kosong atau menggunakan key guest
    if (Get.isRegistered<TripLogService>()) {
      TripLogService.to.loadLogs();
    }

    Get.offAllNamed(Routes.LOGIN);
  }
}
