import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/home/controllers/home_controller.dart';

class BottomNavWidget extends StatelessWidget {
  final HomeController controller;

  const BottomNavWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    controller.selectedIndex.value = 0;
                    Get.offAllNamed("/home");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedIndex.value == 0
                          ? Colors.blue.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          color: controller.selectedIndex.value == 0
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Home",
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.selectedIndex.value == 0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    controller.selectedIndex.value = 1;
                    Get.offAllNamed("/trip");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedIndex.value == 1
                          ? Colors.blue.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: controller.selectedIndex.value == 1
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Buat Perjalanan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.selectedIndex.value == 1
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    controller.selectedIndex.value = 2;
                    // TODO: Navigate to profile
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedIndex.value == 2
                          ? Colors.blue.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: controller.selectedIndex.value == 2
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Profil",
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.selectedIndex.value == 2
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}