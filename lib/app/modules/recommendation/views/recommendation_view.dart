import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recommendation_controller.dart';
import '../../../widgets/header_widget.dart';
import '../../../routes/app_pages.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProvinceBadge("JAWA TENGAH"),
                        const SizedBox(height: 10),
                        const Text(
                          "Rekomendasi Wisata",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pilih destinasi yang paling Anda sukai untuk menyusun rencana perjalanan.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 25),

                        // --- LIST REKOMENDASI ---
                        Obx(() => _buildTripCard(
                          index: 0,
                          image: "assets/images/dieng.jpg",
                          title: "Dieng",
                          desc: "Dataran tinggi dengan pemandangan pegunungan dan kawah yang menakjubkan.",
                          price: "Rp 50.000",
                          rating: "4.9",
                          isBestMatch: true,
                        )),
                        Obx(() => _buildTripCard(
                          index: 1,
                          image: "assets/images/karimun.jpg",
                          title: "Karimunjawa",
                          desc: "Surga tropis dengan taman laut yang indah dan pasir putih bersih.",
                          price: "Rp 8.200.000",
                          rating: "4.8",
                        )),
                      ],
                    ),
                  ),
                  // Tombol melayang di bawah yang reaktif terhadap pilihan
                  _buildBottomButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0061A8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0061A8), 
          fontSize: 10, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required int index,
    required String image,
    required String title,
    required String desc,
    required String price,
    required String rating,
    bool isBestMatch = false,
  }) {
    final isSelected = controller.selectedIndex.value == index;

    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF0061A8) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? const Color(0xFF0061A8).withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05), 
              blurRadius: isSelected ? 20 : 15, 
              offset: const Offset(0, 8)
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => controller.selectCard(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                    child: Image.asset(
                      image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0061A8), 
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price, 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16, 
                            color: Color(0xFF0061A8)
                          )
                        ),
                        Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline, 
                          color: const Color(0xFF0061A8)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Obx(() {
        final bool active = controller.isAnySelected;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.9), Colors.white],
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: active ? () => Get.toNamed(Routes.ITINERARY) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0061A8),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: active ? 8 : 0,
              ),
              child: Text(
                active ? "Buat Itinerary Sekarang" : "Pilih Salah Satu Destinasi",
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade600, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}