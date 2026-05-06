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

            // BATASI LEBAR (WEB)
            double maxWidth =
                constraints.maxWidth > 600 ? 400 : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [

                    // SPACING ATAS
                    const Expanded(flex: 3, child: SizedBox()),

                    // LOGO + TEXT
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // LOGO RESPONSIVE
                          Container(
                            width: maxWidth * 0.2,
                            height: maxWidth * 0.2,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                "assets/images/logo.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            "HappyTrip",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "Effortless Exploration",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // PROGRESS BAR
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: maxWidth * 0.2),
                            child: const LinearProgressIndicator(),
                          ),

                          const SizedBox(height: 40),
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