import 'dart:math';
import 'package:get/get.dart';
import '../../recommendation/controllers/recommendation_controller.dart';
import '../../trip/controllers/trip_controller.dart';
import '../../../services/trip_log_service.dart';
import '../../../models/trip_log_model.dart';
import '../../../routes/app_pages.dart';

class ItineraryController extends GetxController {
  late final RecommendationController recommendationCtrl;
  late final TripController tripCtrl;

  var tripTitle = "".obs;
  var dateRange = "".obs;

  // List untuk menampung destinasi terpilih yang akan ditampilkan di Itinerary
  var selectedDestinations = <Map<String, dynamic>>[].obs;

  // Biaya-biaya yang dihitung secara dinamis
  var transportCost = 0.0.obs;
  var fuelCost = 0.0.obs;
  var tollCost = 0.0.obs;
  var accommodationFee = 0.0.obs;
  var foodLodgingCost = 0.0.obs;

  // Informasi detail transportasi untuk ditampilkan
  var distanceKm = 0.0.obs;

  // Nilai cache dari TripController (dibaca sekali di onInit agar aman dari disposal)
  late final int cachedDurationDays;
  late final String cachedVehicleType;
  late final String cachedSubVehicle;
  late final String cachedUserLocation;
  late final String cachedDestination;
  late final double cachedBudget;

  // Total biaya tiket masuk destinasi terpilih
  double get attractionCost =>
      selectedDestinations.fold(0.0, (sum, item) => sum + (item['price'] as double));

  // Total biaya keseluruhan
  double get totalEstimation =>
      transportCost.value + attractionCost + foodLodgingCost.value;

  // Budget dari masukan pengguna (pakai cache)
  double get userBudget => cachedBudget;

  // Cek apakah total estimasi berada dalam limit budget pengguna
  bool get isWithinBudget => totalEstimation <= userBudget;

  // Koordinat kota-kota di Jawa Tengah untuk kalkulasi jarak
  static const Map<String, Map<String, double>> _cityCoords = {
    "Semarang":     {"lat": -7.0051, "lng": 110.4381},
    "Wonosobo":     {"lat": -7.3605, "lng": 109.9037},
    "Tegal":        {"lat": -6.8694, "lng": 109.1376},
    "Pekalongan":   {"lat": -6.8880, "lng": 109.6737},
    "Cilacap":      {"lat": -7.7178, "lng": 109.0153},
    "Kendal":       {"lat": -6.9183, "lng": 110.2194},
    "Brebes":       {"lat": -6.8712, "lng": 109.0620},
    "Magelang":     {"lat": -7.4709, "lng": 110.2174},
    "Kebumen":      {"lat": -7.6686, "lng": 109.6573},
    "Banyumas":     {"lat": -7.5145, "lng": 109.2943},
    "Purbalingga":  {"lat": -7.3900, "lng": 109.3633},
    "Purworejo":    {"lat": -7.7105, "lng": 109.9993},
    "Karanganyar":  {"lat": -7.5951, "lng": 110.9488},
    "Boyolali":     {"lat": -7.5315, "lng": 110.5956},
    "Klaten":       {"lat": -7.7124, "lng": 110.6052},
    "Sragen":       {"lat": -7.4279, "lng": 110.9390},
    "Surakarta":    {"lat": -7.5611, "lng": 110.8273},
    "Pemalang":     {"lat": -6.8909, "lng": 109.3826},
    "Batang":       {"lat": -6.9284, "lng": 109.7564},
    "Rembang":      {"lat": -6.7086, "lng": 111.3449},
    "Pati":         {"lat": -6.7553, "lng": 111.0369},
    "Jepara":       {"lat": -6.5741, "lng": 110.6669},
    "Banjarnegara": {"lat": -7.3856, "lng": 109.6852},
    "Purwokerto":   {"lat": -7.4207, "lng": 109.2393},
  };

  @override
  void onInit() {
    super.onInit();
    recommendationCtrl = Get.find<RecommendationController>();
    tripCtrl = Get.find<TripController>();
    // Cache nilai dari TripController agar aman saat TripController di-dispose
    cachedDurationDays = int.tryParse(tripCtrl.durationController.text.trim()) ?? 1;
    cachedVehicleType = tripCtrl.selectedVehicle.value;
    cachedSubVehicle = tripCtrl.selectedSubVehicle.value.toLowerCase();
    cachedUserLocation = tripCtrl.userLocationController.text.trim();
    cachedDestination = tripCtrl.selectedDestination.value;
    cachedBudget = double.tryParse(tripCtrl.budgetController.text.trim()) ?? 0.0;
    loadSelectedDestinations();
    calculateDynamicCosts();
    setupTripDetails();
  }

  void loadSelectedDestinations() {
    var indices = recommendationCtrl.selectedIndices;
    var destinations = recommendationCtrl.recommendedDestinations;
    selectedDestinations.value = indices
        .where((index) => index >= 0 && index < destinations.length)
        .map((index) => destinations[index])
        .toList();
  }

  /// Hitung jarak antar dua kota menggunakan formula Haversine (km)
  double _calculateDistance(String city1, String city2) {
    final c1 = _cityCoords[city1];
    final c2 = _cityCoords[city2];
    if (c1 == null || c2 == null) return 60.0; // default fallback

    const R = 6371.0; // radius bumi dalam km
    final dLat = _toRadians(c2['lat']! - c1['lat']!);
    final dLng = _toRadians(c2['lng']! - c1['lng']!);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(c1['lat']!)) *
            cos(_toRadians(c2['lat']!)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (R * c).roundToDouble();
  }

  double _toRadians(double deg) => deg * pi / 180.0;

  void calculateDynamicCosts() {
    // 1. Hitung biaya makan & penginapan
    double mealCost = 100000.0 * cachedDurationDays;
    double lodgingCost = 200000.0 * (cachedDurationDays - 1);
    foodLodgingCost.value = mealCost + lodgingCost;

    // 2. Hitung biaya transportasi
    String userLoc = _normalizeCity(cachedUserLocation);
    String destLoc = _normalizeCity(cachedDestination);

    double km = _calculateDistance(userLoc, destLoc);
    distanceKm.value = km;

    bool isLocal = (userLoc == destLoc);

    if (isLocal) {
      _calculateLocalCost(cachedVehicleType, cachedSubVehicle);
    } else {
      _calculateIntercityCost(cachedVehicleType, cachedSubVehicle, km);
    }
  }

  String _normalizeCity(String raw) {
    String normalized = raw.trim();
    // Coba cocokkan langsung
    if (_cityCoords.containsKey(normalized)) return normalized;
    // Coba case-insensitive
    for (var key in _cityCoords.keys) {
      if (key.toLowerCase() == normalized.toLowerCase()) return key;
    }
    // Coba contains
    for (var key in _cityCoords.keys) {
      if (key.toLowerCase().contains(normalized.toLowerCase()) ||
          normalized.toLowerCase().contains(key.toLowerCase())) {
        return key;
      }
    }
    return normalized;
  }

  void _calculateLocalCost(String vehicleType, String subVehicle) {
    tollCost.value = 0;
    accommodationFee.value = 0;
    if (vehicleType == "Kendaraan Pribadi") {
      if (subVehicle == "mobil") {
        fuelCost.value = 30000.0;
      } else {
        fuelCost.value = 10000.0;
      }
    } else {
      if (subVehicle == "bis") {
        fuelCost.value = 40000.0;
      } else {
        fuelCost.value = 80000.0;
      }
    }
    transportCost.value = fuelCost.value + tollCost.value + accommodationFee.value;
  }

  void _calculateIntercityCost(String vehicleType, String subVehicle, double km) {
    double totalKm = km * 2; // pulang-pergi

    if (vehicleType == "Kendaraan Pribadi") {
      if (subVehicle == "mobil") {
        double liter = totalKm / 12;
        fuelCost.value = liter * 12500;
        tollCost.value = totalKm * 500;
        accommodationFee.value = 50000.0;
      } else {
        double liter = totalKm / 40;
        fuelCost.value = liter * 10000;
        tollCost.value = 0;
        accommodationFee.value = 30000.0;
      }
    } else {
      double ratePerKm = subVehicle == "bis" ? 800.0 : 1000.0;
      fuelCost.value = totalKm * ratePerKm;
      tollCost.value = 0;
      accommodationFee.value = 0;
    }

    transportCost.value = fuelCost.value + tollCost.value + accommodationFee.value;
  }

  void setupTripDetails() {
    tripTitle.value = "Eksplorasi $cachedDestination";

    DateTime now = DateTime.now();
    DateTime endDate = now.add(Duration(days: cachedDurationDays - 1));

    List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];

    String startStr = "${now.day} ${months[now.month - 1]}";
    String endStr = "${endDate.day} ${months[endDate.month - 1]}";

    if (now.month == endDate.month) {
      if (now.day == endDate.day) {
        dateRange.value = "$startStr ${now.year}";
      } else {
        dateRange.value = "${now.day} - ${endDate.day} ${months[now.month - 1]} ${now.year}";
      }
    } else {
      dateRange.value = "$startStr - $endStr ${now.year}";
    }
  }

  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  /// Simpan log perjalanan dan kembali ke Home
  void saveAndFinish() {
    final log = TripLog(
      title: tripTitle.value,
      dateRange: dateRange.value,
      destination: cachedDestination,
      vehicleType: cachedVehicleType,
      durationDays: cachedDurationDays,
      totalCost: totalEstimation,
      budget: userBudget,
      isWithinBudget: isWithinBudget,
      destinations: List<Map<String, dynamic>>.from(selectedDestinations),
      savedAt: DateTime.now(),
    );
    TripLogService.to.addLog(log);
    tripCtrl.resetForm(); // Reset form perjalanan lama
    Get.offAllNamed(Routes.HOME);
  }
}