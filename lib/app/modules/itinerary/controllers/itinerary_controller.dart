import 'package:get/get.dart';

class ItineraryController extends GetxController {
  //TODO: Implement ItineraryController

  final count = 0.obs;

  // Gunakan .obs agar reaktif
  var tripTitle = "Dieng Escape".obs;
  var dateRange = "Oct 12 - 13".obs;

  // Data Estimasi Biaya (Sekarang menggunakan .obs)
  var transportCost = 500000.0.obs;
  var attractionCost = 200000.0.obs;
  var foodLodgingCost = 750000.0.obs;

  // Fungsi get sekarang akan otomatis terhitung ulang jika salah satu .obs di dalamnya berubah
  double get totalEstimation => transportCost.value + attractionCost.value + foodLodgingCost.value;

  // Contoh fungsi untuk merubah harga secara dinamis
  void updateTransport(double newValue) {
    transportCost.value = newValue;
  }

  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
