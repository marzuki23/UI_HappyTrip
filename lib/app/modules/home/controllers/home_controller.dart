import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs; // index menu aktif

  final count = 0.obs;

  void increment() => count.value++;
}
