import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../controllers/trip_controller.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.lazyPut<TripController>(
      () => TripController(),
    );
  }
}