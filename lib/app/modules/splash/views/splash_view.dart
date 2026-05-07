import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // BATASI LEBAR (WEB/TABLET)
            double maxWidth =
                constraints.maxWidth > 600 ? 400 : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // BAGIAN ATAS (KOSONG) - Diberi flex sama dengan bagian bawah agar logo di tengah
                    const Expanded(flex: 4, child: SizedBox()),

                    // LOGO + TEXT (DI TENGAH)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO RESPONSIVE
                        Container(
                          width: maxWidth * 0.45, // Sedikit diperbesar agar proporsional
                          height: maxWidth * 0.45,
                          child: Image.asset(
                            "assets/images/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 24), // Spasi yang lebih pas

                        const Text(
                          "HappyTrip",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 1.2, // Sedikit renggang agar elegan
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Effortless Exploration",
                          style: TextStyle(
                            fontSize: 16, 
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // PROGRESS BAR & SPACING BAWAH
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: maxWidth * 0.25), // ProgressBar lebih ramping
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10), // Membulatkan ProgressBar
                              child: const LinearProgressIndicator(
                                minHeight: 6, // Sedikit lebih tebal agar terlihat modern
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60), // Memberi ruang di bawah agar tidak terlalu mepet
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}