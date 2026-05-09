import 'package:get/get.dart';

class RecommendationController extends GetxController {
  //TODO: Implement RecommendationController

  var selectedIndex = (-1).obs;

  // Fungsi untuk memilih kartu (Toggle: klik lagi untuk batal pilih)
  void selectCard(int index) {
    if (selectedIndex.value == index) {
      selectedIndex.value = -1;
    } else {
      selectedIndex.value = index;
    }
  }

  // Getter untuk mengecek status seleksi
  bool get isAnySelected => selectedIndex.value != -1;
  
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
