import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../routes/app_pages.dart';
import '../../../services/face_recognition_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceLoginController extends GetxController {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(),
  );
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isLoading = false.obs;

  bool _isProcessing = false;
  var email = ''.obs;
  final box = GetStorage();
  final FaceRecognitionService _faceService = FaceRecognitionService();

  @override
  void onInit() {
    super.onInit();
    _faceService.loadModel();
    email.value = Get.arguments ?? box.read('user_email') ?? '';
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      List<CameraDescription> cameras = await availableCameras();
      CameraDescription frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Menggunakan ResolutionPreset.medium untuk kompatibilitas perangkat yang lebih luas
      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } on CameraException catch (e) {
      debugPrint("Camera Error: ${e.description}");
      _showSnackbar('Kamera Error', 'Gagal mengakses kamera.', true);
    }
  }

  void triggerScan() {
    if (isCameraInitialized.value) {
      prosesFaceAuth();
    } else {
      _showSnackbar("Peringatan", "Kamera belum siap.", true);
    }
  }

  Future<void> prosesFaceAuth() async {
  if (email.value.trim().isEmpty || _isProcessing || isLoading.value) return;

  try {
    _isProcessing = true;
    isLoading.value = true;

    // Pastikan controller siap
    if (cameraController == null || !cameraController!.value.isInitialized) {
      throw Exception("Kamera tidak terdeteksi");
    }

    // Ambil foto dan simpan hasilnya
    XFile fileFoto = await cameraController!.takePicture();
    
    // VALIDASI: Pastikan file tidak null dan ada isinya
    if (fileFoto.path.isEmpty) {
      throw Exception("Gagal mendapatkan path foto.");
    }

    // Debugging: Pastikan file benar-benar ada di storage
    final File file = File(fileFoto.path);
    if (!(await file.exists())) {
      throw Exception("File foto tidak ditemukan di penyimpanan.");
    }

      List<double> faceEmbedding = await _getEmbeddingFromImage(fileFoto.path);

      if (faceEmbedding.every((element) => element == 0.0)) {
        throw Exception("Wajah tidak terdeteksi dengan jelas.");
      }

      final String url = 'http://api.api-happytrip.my.id/auth/face-login';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['email'] = email.value.trim();
      request.fields['embedding'] = jsonEncode(faceEmbedding);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;
      _isProcessing = false;

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'registered') {
          // Simpan status biometrik wajah aktif
          box.write('is_face_active', true);
          // Hapus flag pendaftaran wajah baru
          box.remove('needs_face_registration');
          box.remove('registered_email');

          // Simpan Token & Data User jika dikirim backend
          if (responseData['access_token'] != null) {
            box.write('token', responseData['access_token']);
          }
          if (responseData['user'] != null) {
            box.write('user_nama', responseData['user']['nama']);
            box.write('user_email', responseData['user']['email']);
          }

          _showStatusDialog('Registrasi Sukses!', 'Wajah berhasil disimpan.', true);
        } else if (responseData['status'] == 'success') {
          box.write('is_face_active', true);

          // Simpan Token & Data User jika dikirim backend
          if (responseData['access_token'] != null) {
            box.write('token', responseData['access_token']);
          }
          if (responseData['user'] != null) {
            box.write('user_nama', responseData['user']['nama']);
            box.write('user_email', responseData['user']['email']);
          }

          _showSnackbar('Login Berhasil', 'Selamat datang kembali!', false);
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        _showSnackbar('Gagal', 'Wajah tidak cocok, silakan coba lagi.', false);
      }
    } catch (e) {
      isLoading.value = false;
      _isProcessing = false;
      
      try {
        if (cameraController != null && cameraController!.value.isInitialized) {
          await cameraController!.resumePreview();
        }
      } catch (_) {}
      
      _showSnackbar('Error', e.toString().replaceAll("Exception: ", ""), true);
      debugPrint("DETAIL ERROR: $e");
    }
  }

  Future<List<double>> _getEmbeddingFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      throw Exception("Wajah tidak terdeteksi.");
    }
    return await _faceService.getEmbedding(inputImage, faces.first);
  }

  void _showStatusDialog(String title, String message, bool isRegistration) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.HOME);
            },
            child: const Text('Selesai'),
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
    );
  }

  @override
  void onClose() {
    if (cameraController != null) {
      cameraController!.dispose();
    }
    _faceDetector.close();
    super.onClose();
  }
}