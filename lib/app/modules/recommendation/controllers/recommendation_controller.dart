import 'package:get/get.dart';

class RecommendationController extends GetxController {
  // 1. Simpan index yang dipilih dalam list reaktif
  var selectedIndices = <int>[].obs;

  // 2. Fungsi untuk menambah/menghapus index (Toggle)
  void selectCard(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }

  // 3. Helper untuk mengecek status di View
  bool isSelected(int index) => selectedIndices.contains(index);

  // 4. Getter untuk mengaktifkan tombol
  bool get isAnySelected => selectedIndices.isNotEmpty;

  final count = 0.obs;

  void increment() => count.value++;
} // <-- Pastikan hanya ada satu kurung kurawal penutup di paling akhir file
