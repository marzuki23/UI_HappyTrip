import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../controllers/trip_controller.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TripController>(() => TripController(), fenix: true);
  }
}
