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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0061A8)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Trip Itinerary",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTripHeader(),
            
            _buildDaySection(
              date: "MAY 12",
              dayTitle: "Day 1: Dataran Tinggi Dieng",
              items: [
                _itineraryData(
                  image: "assets/images/dieng.jpg",
                  title: "Dieng",
                  desc: "Dataran tinggi dengan pemandangan pegunungan dan kawah yang menakjubkan.",
                  time: "05:00 AM - 09:00 AM",
                  price: "Rp 50.000",
                ),
              ],
            ),

            _buildDaySection(
              date: "MAY 13",
              dayTitle: "Day 2: Eksplorasi Karimunjawa",
              items: [
                _itineraryData(
                  image: "assets/images/karimun.jpg",
                  title: "Karimunjawa",
                  desc: "Surga tropis dengan taman laut yang indah dan pasir putih bersih.",
                  time: "08:30 AM - 12:00 PM",
                  price: "Rp 150.000",
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Widget Summary sekarang dibungkus Obx di dalamnya
            _buildCostSummary(), 
            _buildFinishButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              "assets/images/dieng.jpg",
              height: 220, width: double.infinity, fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Obx(() => Column( // Obx ditambahkan di sini
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildBadge("CONFIRMED", Colors.green.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    _buildBadge(controller.dateRange.value, Colors.white24, icon: Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.tripTitle.value,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text("2 Days • 1 Nights", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            )),
          )
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return Obx(() => Container( // Obx membuat widget ini mendengarkan perubahan harga
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0061A8).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF0061A8).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0061A8), size: 20),
              SizedBox(width: 8),
              Text("Estimasi Total Biaya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _costRow("Transportasi", controller.formatRupiah(controller.transportCost.value)),
          _costRow("Tiket Wisata", controller.formatRupiah(controller.attractionCost.value)),
          _costRow("Akomodasi & Makan", controller.formatRupiah(controller.foodLodgingCost.value)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Keseluruhan", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                controller.formatRupiah(controller.totalEstimation),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0061A8)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "*Biaya dapat berubah sewaktu-waktu tergantung musim dan kebijakan pengelola.",
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    ));
  }

  // --- WIDGET HELPER (Tetap Sama) ---
  Widget _costRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDaySection({required String date, required String dayTitle, required List<Widget> items}) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(date, style: const TextStyle(color: Color(0xFF0061A8), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(dayTitle, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _itineraryData({required String image, required String title, required String desc, required String time, required String price}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(image, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const Divider(height: 30),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF0061A8)),
                    const SizedBox(width: 6),
                    Text(time, style: const TextStyle(fontSize: 11)),
                    const Spacer(),
                    const Icon(Icons.payments_outlined, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: SizedBox(
        width: double.infinity, height: 56,
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed(Routes.HOME),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0061A8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Selesai & Kembali ke Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 12),
          if (icon != null) const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}