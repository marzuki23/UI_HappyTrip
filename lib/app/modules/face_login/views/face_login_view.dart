import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/face_login_controller.dart';

class FaceLoginView extends GetView<FaceLoginController> {
  const FaceLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => controller.isCameraInitialized.value
            ? Stack(
                children: [
                  // 1. Preview Kamera (Full Screen Cover)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width:
                            controller
                                .cameraController!
                                .value
                                .previewSize
                                ?.height ??
                            720,
                        height:
                            controller
                                .cameraController!
                                .value
                                .previewSize
                                ?.width ??
                            1280,
                        child: CameraPreview(controller.cameraController!),
                      ),
                    ),
                  ),

                  // 2. High-Tech Viewport Mask Overlay (Latar belakang gelap dengan lubang di tengah)
                  Positioned.fill(
                    child: CustomPaint(painter: FaceScannerOverlayPainter()),
                  ),

                  // 3. Laser Scan Animation (Berada tepat di dalam bingkai viewport)
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 320,
                      child: const ScanningLaserAnimation(height: 320),
                    ),
                  ),

                  // 4. Floating Back Button (Tombol Kembali)
                  Positioned(
                    top: 24,
                    left: 20,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                  ),

                  // 5. Glassmorphic Instruction Card (Kartu Petunjuk)
                  Positioned(
                    top: 100,
                    left: 24,
                    right: 24,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Verifikasi Wajah",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Posisikan wajah Anda di dalam bingkai dan pastikan cahaya ruangan cukup terang.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6. Action Button (Hanya muncul jika tidak sedang loading)
                  if (!controller.isLoading.value)
                    Positioned(
                      bottom: 60,
                      left: 40,
                      right: 40,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0061A8), Color(0xFF0082E6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0061A8).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => controller.triggerScan(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "PINDAI WAJAH SEKARANG",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 7. Loading Overlay (Saat memproses citra wajah)
                  if (controller.isLoading.value)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.75),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF0082E6),
                                strokeWidth: 4,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Menganalisis Biometrik Wajah...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}

// ─── CUSTOM PAINTER UNTUK BINGKAI SCANNER DAN OVERLAY GELAP ───
class FaceScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65);

    // 1. Path luar (seluruh screen)
    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 2. Path dalam (lubang scanning)
    final rectWidth = 250.0;
    final rectHeight = 320.0;
    final rectLeft = (size.width - rectWidth) / 2;
    final rectTop = (size.height - rectHeight) / 2;
    final innerPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rectLeft, rectTop, rectWidth, rectHeight),
          const Radius.circular(24),
        ),
      );

    // 3. Gabungkan: Hitung selisih untuk membuat lubang viewport transparan
    final path = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(path, paint);

    // 4. Gambar border bingkai tipis
    final borderPaint = Paint()
      ..color = const Color(0xFF0061A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectLeft, rectTop, rectWidth, rectHeight),
        const Radius.circular(24),
      ),
      borderPaint,
    );

    // 5. Gambar sudut-sudut siku (glowing corner brackets) berwarana Cyan
    final bracketPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final bracketLength = 24.0;
    final radiusCorrection =
        8.0; // Sedikit pergeseran agar melengkung pas di luar sudut

    // Atas Kiri
    canvas.drawPath(
      Path()
        ..moveTo(rectLeft, rectTop + bracketLength)
        ..lineTo(rectLeft, rectTop + radiusCorrection)
        ..arcToPoint(
          Offset(rectLeft + radiusCorrection, rectTop),
          radius: const Radius.circular(8),
        )
        ..lineTo(rectLeft + bracketLength, rectTop),
      bracketPaint,
    );

    // Atas Kanan
    canvas.drawPath(
      Path()
        ..moveTo(rectLeft + rectWidth - bracketLength, rectTop)
        ..lineTo(rectLeft + rectWidth - radiusCorrection, rectTop)
        ..arcToPoint(
          Offset(rectLeft + rectWidth, rectTop + radiusCorrection),
          radius: const Radius.circular(8),
        )
        ..lineTo(rectLeft + rectWidth, rectTop + bracketLength),
      bracketPaint,
    );

    // Bawah Kiri
    canvas.drawPath(
      Path()
        ..moveTo(rectLeft, rectTop + rectHeight - bracketLength)
        ..lineTo(rectLeft, rectTop + rectHeight - radiusCorrection)
        ..arcToPoint(
          Offset(rectLeft + radiusCorrection, rectTop + rectHeight),
          radius: const Radius.circular(8),
          clockwise: false,
        )
        ..lineTo(rectLeft + bracketLength, rectTop + rectHeight),
      bracketPaint,
    );

    // Bawah Kanan
    canvas.drawPath(
      Path()
        ..moveTo(rectLeft + rectWidth - bracketLength, rectTop + rectHeight)
        ..lineTo(rectLeft + rectWidth - radiusCorrection, rectTop + rectHeight)
        ..arcToPoint(
          Offset(rectLeft + rectWidth, rectTop + rectHeight - radiusCorrection),
          radius: const Radius.circular(8),
          clockwise: false,
        )
        ..lineTo(rectLeft + rectWidth, rectTop + rectHeight - bracketLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── STATEFUL WIDGET ANIMASI LASER SCANNER GARIS GLOWING ───
class ScanningLaserAnimation extends StatefulWidget {
  final double height;

  const ScanningLaserAnimation({Key? key, required this.height})
    : super(key: key);

  @override
  _ScanningLaserAnimationState createState() => _ScanningLaserAnimationState();
}

class _ScanningLaserAnimationState extends State<ScanningLaserAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        seconds: 2500,
        milliseconds: 0,
      ), // Kecepatan gerak laser (2.5 detik)
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.05,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final topOffset = _animation.value * widget.height;
        return Stack(
          children: [
            Positioned(
              top: topOffset,
              left: 10,
              right: 10,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.cyanAccent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
