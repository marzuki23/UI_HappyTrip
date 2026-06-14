import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../routes/app_pages.dart';

class FaceLoginController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isLoading = false.obs;
  
  var email = ''.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Mengambil email dari session login manual secara otomatis (jika ada)
    email.value = box.read('user_email') ?? '';
    initCamera();
  }

  // ─── INISIALISASI KAMERA DEPAN DENGAN RESOLUSI TINGGI ───
  Future<void> initCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      
      CameraDescription frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high, // <-- DIUBAH KE HIGH AGAR GAMBAR DIAMBIL TAJAM OLEH AI
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      _showSnackbar('Gagal Membuka Kamera', 'Terjadi kesalahan hardware kamera: $e', true);
    }
  }

  // ─── PROSES HOOKS AUTH BIOMETRIK ───
  Future<void> prosesFaceAuth() async {
    if (email.value.trim().isEmpty) {
      _showSnackbar('Email Kosong', 'Silakan masukkan email Anda terlebih dahulu.', true);
      return;
    }

    if (cameraController == null || !cameraController!.value.isInitialized) {
      _showSnackbar('Kamera Belum Siap', 'Mohon tunggu beberapa saat.', true);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Ambil snapshot wajah dari kamera depan
      XFile fileFoto = await cameraController!.takePicture();

      // 2. Setup Request Multipart ke Server API cPanel Anda
      final String url = 'http://api.api-happytrip.my.id/auth/face-login';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['email'] = email.value.trim();
      
      // Mengirim file foto mentah (.jpg) secara streaming multipart
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Field key harus sesuai dengan parameter UploadFile di FastAPI Backend
          fileFoto.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;

      // 3. Membaca & Mengurai Respon Balikan Server
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['status'] == 'registered') {
          // Kasus Pertama: Berhasil Mendaftarkan Struktur Wajah Baru
          box.write('is_face_active', true);
          box.write('user_email', email.value.trim()); // Simpan permanen agar bypass email aktif
          
          _showStatusDialog(
            title: 'Registrasi Wajah Sukses! 🎉',
            message: 'Wajah Anda berhasil tersimpan di AI Server. Sekarang fitur verifikasi wajah instan Anda telah aktif.',
            isSuccess: true,
          );
        } else if (responseData['status'] == 'success') {
          // Kasus Kedua: Berhasil Mencocokkan Log In Menggunakan Wajah
          _showSnackbar('Autentikasi Berhasil', 'Selamat Datang Kembali di HappyTrip!', false);
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        // Antisipasi penanganan jika server crash mengembalikan berkas non-JSON (HTML 500)
        String pesanGagal = 'Terjadi malfungsi pada AI Server Backend.';
        try {
          var responseData = jsonDecode(response.body);
          if (responseData['detail'] != null) {
            pesanGagal = responseData['detail'];
          }
        } catch (_) {}
        
        _showSnackbar('Autentikasi AI Gagal', pesanGagal, true);
      }

    } catch (e) {
      isLoading.value = false;
      _showSnackbar('System Error', 'Gagal memproses pengiriman data biometrik: $e', true);
    }
  }

  void _showStatusDialog({required String title, required String message, bool isSuccess = true}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.LOGIN); // Kembali ke login untuk aktivasi widget dinamis
            },
            child: Text(
              'Selesai',
              style: TextStyle(
                color: isSuccess ? const Color(0xFF0061A8) : const Color(0xFFBA1A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF27AE60),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    cameraController?.dispose(); // Wajib ditutup saat keluar halaman agar tidak memory leak
    super.onClose();
  }
}