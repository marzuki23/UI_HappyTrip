import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class TripController extends GetxController {
  //TODO: Implement TripController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
          final homeC = Get.put(HomeController()); // ⬅️ ini penting
          homeC.selectedIndex.value = 1;
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
