import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/itinerary_controller.dart';
import '../../../routes/app_pages.dart';

class ItineraryView extends GetView<ItineraryController> {
  const ItineraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Trip Itinerary",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTripHeader(),
            
            // List Destinasi Dinamis
            Obx(() {
              if (controller.selectedDestinations.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Text("Belum ada destinasi terpilih."),
                ));
              }
              return Column(
                children: controller.selectedDestinations.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  return _buildDaySection(
                    date: "HARI ${idx + 1}",
                    dayTitle: item['title'],
                    items: [
                      _itineraryCard(
                        image: item['image'],
                        title: item['title'],
                        desc: item['desc'],
                        time: item['time'],
                        price: controller.formatRupiah(item['price']),
                      ),
                    ],
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 20),
            _buildCostSummary(), 
            _buildFinishButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HEADER PROFESIONAL ---
  Widget _buildTripHeader() {
    String headerImg = controller.selectedDestinations.isNotEmpty 
        ? controller.selectedDestinations[0]['image'] 
        : "assets/images/dieng.jpg";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(headerImg, height: 260, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.9)],
              ),
            ),
          ),
          Positioned(
            bottom: 25, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadge("CONFIRMED", Colors.greenAccent.shade700),
                const SizedBox(height: 12),
                Obx(() => Text(
                  controller.tripTitle.value.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5, shadows: [Shadow(blurRadius: 10, color: Colors.black)]
                  ),
                )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Obx(() => Text(controller.dateRange.value, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                    const SizedBox(width: 15),
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 5),
                    Obx(() => Text("${controller.selectedDestinations.length} Lokasi", style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- CARD SUMMARY BIAYA ---
  Widget _buildCostSummary() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estimasi Biaya Perjalanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          _costRow("Transportasi & Guide", controller.formatRupiah(controller.transportCost.value)),
          _costRow("Total Tiket Masuk", controller.formatRupiah(controller.attractionCost)),
          _costRow("Akomodasi & Konsumsi", controller.formatRupiah(controller.foodLodgingCost.value)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Keseluruhan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                controller.formatRupiah(controller.totalEstimation),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0061A8)),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _costRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDaySection({required String date, required String dayTitle, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 25, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(color: Color(0xFF0061A8), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.5)),
              Text(dayTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1E293B))),
            ],
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _itineraryCard({required String image, required String title, required String desc, required String time, required String price}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.asset(image, height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.access_time_filled, size: 14, color: Color(0xFF0061A8)),
                      const SizedBox(width: 5),
                      Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity, height: 58,
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed(Routes.HOME),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0061A8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 5, shadowColor: const Color(0xFF0061A8).withOpacity(0.4),
          ),
          child: const Text("Selesai & Kembali ke Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        ),
      ),
    );
  }

  Widget _buildBadge(String txt, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(8)),
      child: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}