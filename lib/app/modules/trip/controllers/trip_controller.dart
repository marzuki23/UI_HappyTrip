import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripController extends GetxController {
  // Text Editing Controllers for manual input fields
  final TextEditingController userLocationController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  // Reactive states for dropdown fields
  var selectedCategory = "Pantai".obs;
  var selectedDestination = "".obs; // Kosongkan default-nya karena menunggu data API
  var selectedVehicle = "Kendaraan Pribadi".obs;
  var selectedSubVehicle = "".obs;

  // RxList untuk menampung data lokasi (kota) dan kategori dari database backend
  var destinationList = <String>[].obs;
  var categoryList = <String>[].obs;

  // State untuk indikator loading data dari backend
  var isLoadingDestinations = true.obs;

  final List<String> vehicleList = ["Kendaraan Pribadi", "Kendaraan Umum"];

  // Instance GetConnect untuk hit ke API Backend
  final GetConnect _connect = GetConnect();

  @override
  void onInit() {
    super.onInit();
    // Reset form saat pertama kali diinisialisasi
    resetForm();
    fetchDestinationsFromBackend(); // Panggil fungsi API saat controller aktif
  }

  /// Reset semua input form ke kosong/default untuk perjalanan baru
  void resetForm() {
    userLocationController.text = destinationList.isNotEmpty ? destinationList.first : "Semarang";
    durationController.clear();
    _resetDropdowns();
  }

  /// Reset dropdown ke kondisi awal untuk perjalanan baru
  void _resetDropdowns() {
    selectedVehicle.value = "Kendaraan Pribadi";
    selectedSubVehicle.value = "";
  }

  // FUNGSI UNTUK MENGAMBIL DATA LOKASI & KATEGORI DARI BACKEND
  void fetchDestinationsFromBackend() async {
    try {
      isLoadingDestinations.value = true;

      final response = await _connect.get(
        'http://api.api-happytrip.my.id/destinations',
      );

      if (response.status.hasError) {
        throw Exception("Gagal mengambil data dari database");
      }

      if (response.body != null && response.body is List) {
        // API mengembalikan array objek langsung: [{...}, {...}]
        List<dynamic> rawData = response.body;

        // Ekstrak unique lokasi (kota tujuan) dari database
        Set<String> uniqueLocations = {};
        Set<String> uniqueCategories = {};

        for (var item in rawData) {
          if (item is Map) {
            final lokasi = item['lokasi']?.toString();
            final kategori = item['kategori']?.toString();

            if (lokasi != null && lokasi.isNotEmpty) {
              uniqueLocations.add(lokasi);
            }

            if (kategori != null && kategori.isNotEmpty) {
              uniqueCategories.add(kategori);
            }
          }
        }

        destinationList.value = uniqueLocations.toList()..sort();
        categoryList.value = uniqueCategories.toList()..sort();

        if (destinationList.isNotEmpty) {
          selectedDestination.value = destinationList.first;
          if (userLocationController.text.isEmpty || userLocationController.text == "Semarang") {
            userLocationController.text = destinationList.first;
          }
        }

        if (categoryList.isNotEmpty) {
          selectedCategory.value = categoryList.first;
        }
      } else {
        throw Exception("Format response tidak sesuai");
      }
    } catch (e) {
      _showErrorSnackbar(
        title: "Koneksi Backend Gagal",
        message:
            "Tidak dapat memuat data dari database. Menggunakan data cadangan.",
      );

      // Data fallback
      destinationList.value = [
        "Semarang",
        "Wonosobo",
        "Tegal",
        "Pekalongan",
        "Cilacap",
        "Kendal",
        "Brebes",
        "Magelang",
        "Kebumen",
        "Banyumas",
        "Purbalingga",
        "Purworejo",
        "Karanganyar",
        "Boyolali",
        "Klaten",
        "Sragen",
        "Surakarta",
        "Pemalang",
        "Batang",
        "Rembang",
        "Pati",
        "Jepara",
        "Banjarnegara"
      ];

      categoryList.value = [
        "Pantai",
        "Gunung",
        "Alam",
        "Candi",
        "Air Terjun",
        "Danau",
        "Goa",
        "Sejarah",
        "Religi",
        "Museum",
        "Taman",
        "Wisata Keluarga",
        "Agrowisata"
      ];

      selectedDestination.value = destinationList.first;
      selectedCategory.value = categoryList.first;
    } finally {
      isLoadingDestinations.value = false;
    }
  }

  List<String> getSubVehicleList() {
    if (selectedVehicle.value == "Kendaraan Pribadi") {
      return ["Mobil", "Motor"];
    } else if (selectedVehicle.value == "Kendaraan Umum") {
      return ["Kereta", "Bis"];
    }
    return [];
  }

  void onVehicleChanged(String value) {
    selectedVehicle.value = value;
    selectedSubVehicle.value = "";
  }

  bool validateInputs() {
    // Baca langsung dari controller agar tidak ada masalah state reactive vs non-reactive
    final String userLocation = userLocationController.text.trim();
    final String durationText = durationController.text.trim();

    if (userLocation.isEmpty) {
      _showErrorSnackbar(
        title: "Lokasi Kosong",
        message: "Silakan masukkan lokasi asal Anda saat ini.",
      );
      return false;
    }

    if (durationText.isEmpty) {
      _showErrorSnackbar(
        title: "Durasi Kosong",
        message: "Silakan masukkan durasi perjalanan Anda.",
      );
      return false;
    }

    final durationVal = int.tryParse(durationText);

    if (durationVal == null || durationVal <= 0) {
      _showErrorSnackbar(
        title: "Durasi Tidak Valid",
        message: "Masukkan durasi hari berupa angka bulat positif.",
      );
      return false;
    }

    if (selectedSubVehicle.value.isEmpty) {
      _showErrorSnackbar(
        title: "Tipe Kendaraan Belum Dipilih",
        message: "Silakan pilih spesifikasi tipe kendaraan.",
      );
      return false;
    }

    return true;
  }

  void _showErrorSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFBA1A1A),
      colorText: Colors.white,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
      ),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    // Jangan di-dispose di sini karena TripView di dalam IndexedStack (HomeView) tetap hidup
    // dan GetX fenix bisa me-recreate controller secara internal sementara widget-nya masih me-refer ke controller ini.
    super.onClose();
  }
}