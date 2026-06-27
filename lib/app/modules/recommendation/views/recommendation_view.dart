import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recommendation_controller.dart';
import '../../../routes/app_pages.dart';

class RecommendationView extends GetView<RecommendationController> {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Rekomendasi Wisata", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0061A8)));
        }

        if (controller.recommendedDestinations.isEmpty) {
          return const Center(child: Text("Tidak ada rekomendasi wisata yang cocok."));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: controller.recommendedDestinations.length,
          itemBuilder: (context, index) {
            final item = controller.recommendedDestinations[index];
            return Obx(() {
              final isSelected = controller.selectedIndices.contains(index);
              return GestureDetector(
                onTap: () => controller.toggleSelection(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0061A8) : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        child: Image.network(
                          item['image'] ?? '',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // Mencegah munculnya Exception error "Unable to load asset" jika server image bermasalah
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 36),
                                const SizedBox(height: 4),
                                Text(
                                  "Gambar tidak tersedia",
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'] ?? 'Wisata Tanpa Nama',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      (item['rating'] ?? 5.0).toString(), 
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.formatRupiah((item['price'] ?? 0.0).toDouble()),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0061A8)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.selectedIndices.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(Routes.ITINERARY),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0061A8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Buat Perjalanan (${controller.selectedIndices.length} Wisata)",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        );
      }),
    );
  }
}