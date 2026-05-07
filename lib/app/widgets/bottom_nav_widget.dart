import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/home/controllers/home_controller.dart';

class BottomNavWidget extends StatelessWidget {
  final HomeController controller;

  const BottomNavWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
              // TOMBOL HOME
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      controller.selectedIndex.value = 0;
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
                            controller.selectedIndex.value == 0 
                                ? Icons.home_filled 
                                : Icons.home_outlined,
                            color: controller.selectedIndex.value == 0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Home",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: controller.selectedIndex.value == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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

              // TOMBOL BUAT PERJALANAN
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      controller.selectedIndex.value = 1;
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
                            Icons.add_circle_outline,
                            color: controller.selectedIndex.value == 1
                                ? Colors.blue
                                : Colors.grey,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Buat Perjalanan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: controller.selectedIndex.value == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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

              // TOMBOL PROFIL
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      controller.selectedIndex.value = 2;
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
                            // Menggunakan Icons.person_outline agar lebih sesuai dengan desain modern di foto
                            controller.selectedIndex.value == 2 
                                ? Icons.person 
                                : Icons.person_outline,
                            color: controller.selectedIndex.value == 2
                                ? Colors.blue
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Profil",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: controller.selectedIndex.value == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
      ),
    );
  }
}