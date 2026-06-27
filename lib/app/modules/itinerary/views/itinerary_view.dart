import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/itinerary_controller.dart';

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Trip Itinerary",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
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
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Text("Belum ada destinasi terpilih."),
                  ),
                );
              }
              final int durationDays = controller.cachedDurationDays;
              final int totalDest = controller.selectedDestinations.length;

              // Bagi destinasi merata ke setiap hari
              int usedDays = durationDays > totalDest
                  ? totalDest
                  : durationDays;
              int base = totalDest ~/ usedDays;
              int extra = totalDest % usedDays;

              List<List<Map<String, dynamic>>> dayGroups = [];
              int destIdx = 0;
              for (int d = 0; d < usedDays; d++) {
                int count = base + (d < extra ? 1 : 0);
                dayGroups.add(
                  controller.selectedDestinations.sublist(
                    destIdx,
                    destIdx + count,
                  ),
                );
                destIdx += count;
              }

              return Column(
                children: dayGroups.asMap().entries.map((entry) {
                  int dayIdx = entry.key;
                  List<Map<String, dynamic>> group = entry.value;
                  String dayTitle = group.length == 1
                      ? group[0]['title']
                      : "Destinasi Pilihan";
                  return _buildDaySection(
                    date: "HARI ${dayIdx + 1}",
                    dayTitle: dayTitle,
                    items: group.asMap().entries.map((e) {
                      var item = e.value;
                      return _itineraryCard(
                        image: item['image'],
                        title: item['title'],
                        desc: item['desc'],
                        time: _generateTimeSlot(e.key, group.length),
                        price: controller.formatRupiah(item['price']),
                      );
                    }).toList(),
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
    var firstItem = controller.selectedDestinations.isNotEmpty
        ? controller.selectedDestinations[0]
        : null;
    String headerImg = firstItem?['image'] ?? "assets/images/dieng.jpg";
    bool isNetwork = firstItem?['isNetworkImage'] == true;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: isNetwork
                  ? Image.network(
                      headerImg,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 260,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    )
                  : Image.asset(
                      headerImg,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadge("CONFIRMED", Colors.greenAccent.shade700),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    controller.tripTitle.value.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Obx(
                      () => Text(
                        controller.dateRange.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Obx(
                      () => Text(
                        "${controller.selectedDestinations.length} Lokasi",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD SUMMARY BIAYA ---
  Widget _buildCostSummary() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Estimasi Biaya Perjalanan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            // Detail Transportasi
            _sectionHeader("Transportasi", Icons.directions_car_rounded),
            const SizedBox(height: 8),
            if (controller.distanceKm.value > 0)
              _costRow(
                "Jarak PP",
                "${(controller.distanceKm.value * 2).toStringAsFixed(0)} km (${controller.distanceKm.value.toStringAsFixed(0)} km × 2)",
              ),
            if (controller.fuelCost.value > 0)
              _costRow(
                controller.cachedVehicleType == "Kendaraan Pribadi"
                    ? "Biaya BBM"
                    : "Biaya Tiket",
                controller.formatRupiah(controller.fuelCost.value),
              ),
            if (controller.tollCost.value > 0)
              _costRow(
                "Biaya Tol",
                controller.formatRupiah(controller.tollCost.value),
              ),
            if (controller.accommodationFee.value > 0)
              _costRow(
                "Parkir & Lainnya",
                controller.formatRupiah(controller.accommodationFee.value),
              ),
            _costRow(
              "Subtotal Transportasi",
              controller.formatRupiah(controller.transportCost.value),
              isBold: true,
            ),
            const SizedBox(height: 14),
            // Tiket Masuk
            _sectionHeader("Tiket Masuk", Icons.confirmation_number_rounded),
            const SizedBox(height: 8),
            ...controller.selectedDestinations.map(
              (item) => _costRow(
                item['name'] ?? 'Wisata',
                controller.formatRupiah((item['price'] as double)),
              ),
            ),
            _costRow(
              "Total Tiket Masuk",
              controller.formatRupiah(controller.attractionCost),
              isBold: true,
            ),
            const SizedBox(height: 14),
            // Makan & Penginapan
            _sectionHeader("Makan & Penginapan", Icons.restaurant_rounded),
            const SizedBox(height: 8),
            _costRow(
              "Makan Rp100.000 × ${controller.cachedDurationDays} hari",
              controller.formatRupiah(
                (100000 * controller.cachedDurationDays).toDouble(),
              ),
            ),
            if (controller.cachedDurationDays > 1)
              _costRow(
                "Hotel Rp200.000 × ${controller.cachedDurationDays - 1} malam",
                controller.formatRupiah(
                  (200000 * (controller.cachedDurationDays - 1)).toDouble(),
                ),
              ),
            _costRow(
              "Subtotal Makan & Penginapan",
              controller.formatRupiah(controller.foodLodgingCost.value),
              isBold: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Keseluruhan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  controller.formatRupiah(controller.totalEstimation),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0061A8),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildBudgetTrackerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0061A8)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0061A8),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTrackerWidget() {
    final bool within = controller.isWithinBudget;
    final double budget = controller.userBudget;
    final double diff = (controller.totalEstimation - budget).abs();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: within ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: within ? const Color(0xFF81C784) : const Color(0xFFE57373),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                within ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: within
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                within ? "Sesuai Budget" : "Melebihi Budget!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: within
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Budget Anda:",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                controller.formatRupiah(budget),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                within ? "Sisa Saldo:" : "Kurang Saldo:",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                controller.formatRupiah(diff),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: within
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black87 : Colors.grey.shade600,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
              color: isBold ? Colors.black87 : null,
            ),
          ),
        ],
      ),
    );
  }

  String _generateTimeSlot(int index, int total) {
    if (total <= 1) return "08:00 - 17:00";
    // Bagi waktu kunjungan merata sepanjang hari (08:00 - 17:00 = 9 jam)
    int slotMinutes = (9 * 60) ~/ total;
    int startMin = 8 * 60 + index * slotMinutes;
    int endMin = startMin + slotMinutes;
    String pad(int n) => n.toString().padLeft(2, '0');
    return "${pad(startMin ~/ 60)}:${pad(startMin % 60)} - ${pad(endMin ~/ 60)}:${pad(endMin % 60)}";
  }

  Widget _buildDaySection({
    required String date,
    required String dayTitle,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 25, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF0061A8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                dayTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _itineraryCard({
    required String image,
    required String title,
    required String desc,
    required String time,
    required String price,
  }) {
    bool isNetwork = image.startsWith('http');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: isNetwork
                ? Image.network(
                    image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 36,
                      ),
                    ),
                  )
                : Image.asset(
                    image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 14,
                          color: Color(0xFF0061A8),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () => controller.saveAndFinish(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0061A8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 5,
            shadowColor: const Color(0xFF0061A8).withOpacity(0.4),
          ),
          child: const Text(
            "Selesai & Kembali ke Home",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String txt, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
