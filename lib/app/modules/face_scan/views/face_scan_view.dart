import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:get/get.dart';
import '../../../services/face_recognition_service.dart';

class FaceScanView extends StatefulWidget {
  @override
  _FaceScanViewState createState() => _FaceScanViewState();
}

class _FaceScanViewState extends State<FaceScanView> {
  CameraController? _controller;
  final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions());
  final FaceRecognitionService _faceService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _faceService.loadModel(); // Load AI model
    final cameras = await availableCameras();
    _controller = CameraController(cameras[1], ResolutionPreset.medium); // Kamera depan
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> scanFace() async {
    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Proses AI: Ekstraksi fitur wajah
        List<double> embedding = await _faceService.getEmbedding(inputImage, faces.first);
        print("Embedding berhasil didapat: ${embedding.length} angka");
        // Selanjutnya: Kirim embedding ini ke server via API (http.post)
      } else {
        Get.snackbar("Error", "Wajah tidak terdeteksi!");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) return Container();
    return Scaffold(
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: scanFace,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}