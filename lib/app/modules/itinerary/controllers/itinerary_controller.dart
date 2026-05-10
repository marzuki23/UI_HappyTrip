import 'package:get/get.dart';
import '../../recommendation/controllers/recommendation_controller.dart';

class ItineraryController extends GetxController {
  //TODO: Implement ItineraryController

  final RecommendationController recommendationCtrl = Get.find<RecommendationController>();

  var tripTitle = "Jawa Tengah Exploration".obs;
  var dateRange = "May 12 - 13".obs;

  // Master Data Destinasi (sesuaikan dengan yang ada di RecommendationView)
  final List<Map<String, dynamic>> allDestinations = [
    {
      "title": "Bukit Sikunir",
      "desc": "Destinasi wisata populer di Dataran Tinggi Dieng, Jawa Tengah, terkenal dengan pemandangan golden sunrise terbaik di Asia Tenggara.",
      "image": "assets/images/Bukit-Sikunir.jpg",
      "price": 50000.0,
      "time": "05:00 AM - 09:00 AM"
    },
    {
      "title": "Kawah Sikidang",
      "desc": "kawah vulkanik aktif terbesar di Dataran Tinggi Dieng.",
      "image": "assets/images/kawah sikidang.jpg",
      "price": 150000.0,
      "time": "08:30 AM - 12:00 PM"
    },
    {
      "title": "Gunung Sumbing",
      "desc": "Gunung api aktif bertipe stratovolcano tertinggi kedua di Jawa Tengah (setelah Gunung Slamet) dengan ketinggian 3.371 mdpl.",
      "image": "assets/images/gunung sumbing.jpg",
      "price": 50000.0,
      "time": "09:00 AM - 01:00 PM"
    },
    {
      "title": "Gunung Sindoro",
      "desc": "Gunung stratovolcano aktif yang terletak di Jawa Tengah, berbatasan dengan Kabupaten Temanggung dan Wonosobo.",
      "image": "assets/images/gunung-sindoro.jpg",
      "price": 25000.0,
      "time": "10:00 AM - 02:00 PM"
    },
  ];

  // List untuk menampung hanya yang dipilih user
  var selectedDestinations = <Map<String, dynamic>>[].obs;

  var transportCost = 500000.0.obs;
  var foodLodgingCost = 750000.0.obs;

  // Total biaya tiket dihitung dinamis dari destinasi yang dipilih
  double get attractionCost => selectedDestinations.fold(0, (sum, item) => sum + item['price']);
  double get totalEstimation => transportCost.value + attractionCost + foodLodgingCost.value;

  @override
  void onInit() {
    super.onInit();
    loadSelectedDestinations();
  }

  void loadSelectedDestinations() {
    // Ambil index yang dipilih dari controller sebelah
    var indices = recommendationCtrl.selectedIndices;
    
    // Filter master data berdasarkan index yang dipilih
    selectedDestinations.value = indices.map((index) => allDestinations[index]).toList();
  }

  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
