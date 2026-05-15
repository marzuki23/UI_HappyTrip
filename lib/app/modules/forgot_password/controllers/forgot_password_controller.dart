import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  late TextEditingController emailController;
  final GlobalKey<FormState> forgotFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void sendResetInstructions() {
    if (forgotFormKey.currentState!.validate()) {
      // Simulasi pengiriman email
      Get.snackbar(
        "Email Terkirim",
        "Instruksi reset password telah dikirim ke ${emailController.text}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
      );
      
      // Tunggu sebentar lalu kembali ke Login
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }
}