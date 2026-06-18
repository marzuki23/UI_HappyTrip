import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;

  // Memuat model dari assets
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/ml/mobilefacenet.tflite',
    );
  }

  // Mendapatkan embedding dari gambar
  Future<List<double>> getEmbedding(InputImage inputImage, Face face) async {
    debugPrint("--- FUNGSI GET EMBEDDING DIPANGGIL ---"); // Tambahkan ini

    // 1. Dapatkan bytes gambar baik dari memory (bytes) maupun file path
    Uint8List bytes;
    if (inputImage.bytes != null) {
      bytes = inputImage.bytes!;
    } else if (inputImage.filePath != null) {
      bytes = await File(inputImage.filePath!).readAsBytes();
    } else {
      throw Exception("Data gambar tidak ditemukan (bytes dan filePath null).");
    }

    img.Image? fullImage = img.decodeImage(bytes);
    if (fullImage == null) throw Exception("Gagal decode gambar");

    // 2. Crop bagian wajah menggunakan named parameters (Sintaks Library Image v4.x)
    debugPrint("Mulai cropping...");
    img.Image croppedFace = img.copyCrop(
      fullImage,
      x: face.boundingBox.left.toInt(),
      y: face.boundingBox.top.toInt(),
      width: face.boundingBox.width.toInt(),
      height: face.boundingBox.height.toInt(),
    );

    // 3. Resize ke 112x112 untuk MobileFaceNet
    img.Image resized = img.copyResize(croppedFace, width: 112, height: 112);

    // 4. Konversi ke format input model (4D: 1, 112, 112, 3)
    var input = List.generate(
      1,
      (b) => List.generate(
        112,
        (y) => List.generate(112, (x) {
          // Mengambil pixel pada koordinat x, y
          img.Pixel pixel = resized.getPixel(x, y);

          return [
            (pixel.r.toDouble() - 127.5) / 128.0,
            (pixel.g.toDouble() - 127.5) / 128.0,
            (pixel.b.toDouble() - 127.5) / 128.0,
          ];
        }),
      ),
    );

    // 5. Jalankan AI di HP User
    debugPrint("Jalankan AI...");
    // Pastikan output buffer sesuai dengan bentuk output model Anda (diubah ke [1, 192])
    var output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    if (_interpreter == null) {
      debugPrint("Interpreter belum siap, mencoba memuat model...");
      await loadModel();
    }

    if (_interpreter == null) {
      throw Exception("Gagal menginisialisasi Interpreter AI (Model null).");
    }

    _interpreter!.run(input, output);
    debugPrint("AI selesai dijalankan. Embedding didapat.");

    return List<double>.from(output[0]);
  }

  void dispose() {
    _interpreter?.close();
  }
}
