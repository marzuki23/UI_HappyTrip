import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trip_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../widgets/bottom_nav_widget.dart';
import '../../../widgets/header_widget.dart';

class TripView extends GetView<TripController> {
  const TripView({super.key});

  @override
  Widget build(BuildContext context) {
    final controllerHome = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    controllerHome.selectedIndex.value = 1;

    return WillPopScope(
      onWillPop: () async {
        controllerHome.selectedIndex.value = 0;
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

        body: SafeArea(
          child: Stack(
            children: [
              // BACKGROUND
              Container(color: const Color(0xFFF5F5F5)),

              // HEADER (REUSABLE)
              const HeaderWidget(),

              // CONTENT
              Positioned.fill(
                top: 65,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // CARD FORM
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Rencanakan Perjalanan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Atur perjalanan liburanmu dengan mudah",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // KATEGORI
                            const Text("Kategori Wisata"),
                            const SizedBox(height: 5),
                            DropdownButtonFormField(
                              items: ["Pantai", "Gunung", "Kota"]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (value) {},
                              decoration: _inputStyle(),
                            ),

                            const SizedBox(height: 15),

                            // LOKASI
                            const Text("Lokasi"),
                            const SizedBox(height: 5),
                            TextField(
                              decoration:
                                  _inputStyle(hint: "Masukkan lokasi Anda"),
                            ),

                            const SizedBox(height: 15),

                            // BUDGET
                            const Text("Budget (Rp)"),
                            const SizedBox(height: 5),
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: _inputStyle(hint: "1000000"),
                            ),

                            const SizedBox(height: 15),

                            // TANGGAL
                            const Text("Tanggal Berangkat & Pulang"),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration:
                                        _inputStyle(hint: "dd/mm/yyyy"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration:
                                        _inputStyle(hint: "dd/mm/yyyy"),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // KENDARAAN
                            const Text("Jenis Kendaraan"),
                            const SizedBox(height: 5),
                            DropdownButtonFormField(
                              items: [
                                "Motor",
                                "Mobil",
                                "Transportasi Umum"
                              ]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (value) {},
                              decoration: _inputStyle(),
                            ),

                            const SizedBox(height: 20),

                            // BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.search),
                                label: const Text("Lihat Rekomendasi"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavWidget(controller: controllerHome),
      ),
    );
  }

  InputDecoration _inputStyle({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}