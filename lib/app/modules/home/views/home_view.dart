import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../trip/views/trip_view.dart';
import '../../../widgets/bottom_nav_widget.dart';
import '../../../widgets/header_widget.dart';
import '../top_destinations_widget.dart';
import '../category_density_chart_widget.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({super.key, this.initialIndex = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    controller.selectedIndex.value = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: const [
                    _HomeContent(),
                    TripView(),
                    ProfileView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavWidget(controller: controller),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TEKS SELAMAT DATANG (DI LUAR KARTU)
          const Text(
            "Selamat Datang di",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const Text(
            "HappyTrip",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mau liburan kemana hari ini?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 40),

          // KARTU PUTIH UTAMA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40), // Lebih melengkung sesuai gambar
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // ICON PESAWAT DENGAN LINGKARAN BIRU
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2), // Biru gelap sesuai gambar
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 35),

                // TOMBOL BUAT PERJALANAN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.selectedIndex.value = 1;
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text(
                      "Buat Perjalanan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1), // Biru lebih pekat
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // DESKRIPSI BAWAH
                const Text(
                  "Mulai rencanakan itinerary perjalanan yang rapi dan terorganisir dalam hitungan menit.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // WIDGET PAPAN PERINGKAT DATA APIFY
          const SizedBox(height: 24), 
          const TopDestinationsWidget(),

          const SizedBox(height: 16),
          const CategoryDensityChartWidget(),
        ],
      ),
    );
  }
}
