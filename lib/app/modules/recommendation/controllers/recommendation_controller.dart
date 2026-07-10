import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../trip/controllers/trip_controller.dart';

class RecommendationController extends GetxController {
  late final TripController tripCtrl;

  // Base URL backend FastAPI
  static const String _baseUrl = 'http://api.api-happytrip.my.id';

  // Simpan index yang dipilih dalam list reaktif
  var selectedIndices = <int>[].obs;
  // Simpan list destinasi hasil filter
  var recommendedDestinations = <Map<String, dynamic>>[].obs;
  // Loading state
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    tripCtrl = Get.find<TripController>();
    fetchRecommendations();
  }

  void fetchRecommendations() async {
    isLoading.value = true;
    selectedIndices.clear();
    recommendedDestinations.clear();

    final String targetLoc = tripCtrl.selectedDestination.value;
    final String targetCat = tripCtrl.selectedCategory.value;

    // ─── FETCHER API NEON VIA BACKEND FASTAPI ───
    try {
      final String url = '$_baseUrl/destinations';
      var response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        List<dynamic> apiData = jsonDecode(response.body);

        // Map kolom database Neon ke format Flutter
        List<Map<String, dynamic>> allDestinations = apiData.map((item) {
          // ── Harga ──
          double price = 0.0;
          if (item['harga_tiket'] != null) {
            price = double.tryParse(item['harga_tiket'].toString()) ?? 0.0;
          }

          // ── Rating ──
          double rating = 5.0;
          if (item['rating'] != null) {
            rating = double.tryParse(item['rating'].toString()) ?? 5.0;
          }

          // ── Kategori (gunakan langsung dari database) ──
          final String mappedCategory = item['kategori']?.toString() ?? "Kota";

          // ── Foto: gunakan URL lengkap dari server ──
          String imgPath = '';
          final rawFoto = item['foto_url']?.toString() ?? '';
          if (rawFoto.isNotEmpty) {
            if (rawFoto.startsWith('http')) {
              imgPath = rawFoto;
            } else {
              // Path relatif: gabungkan dengan base URL
              imgPath = '$_baseUrl$rawFoto';
            }
          }
          if (imgPath.isEmpty) {
            imgPath = _defaultAssetForCategory(mappedCategory);
          }

          return {
            "id": item['id'],
            "name": item['nama_wisata'] ?? "Wisata Tanpa Nama", // Sinkronisasi 'name' untuk view
            "title": item['nama_wisata'] ?? "Wisata Tanpa Nama",
            "description": item['deskripsi'] ?? "", // Sinkronisasi 'description' untuk view
            "desc": item['deskripsi'] ?? "",
            "image": imgPath,
            "isNetworkImage": imgPath.startsWith('http'),
            "price": price,
            "rating": rating,
            "category": mappedCategory,
            "location": item['lokasi'] ?? "",
            "time": "08:00 AM - 05:00 PM",
          };
        }).toList();

        debugPrint(
            "DEBUG: Berhasil memuat ${allDestinations.length} data wisata dari Neon API.");

        // ─── LOGIKA FILTER ───
        var filtered = allDestinations.where((item) {
          final dbLoc = item['location'].toString().trim().toLowerCase();
          final dbCatMapped = item['category'].toString().trim().toLowerCase();
          
          final uiLoc = targetLoc.trim().toLowerCase();
          final uiCat = targetCat.trim().toLowerCase();

          final isLocMatch = (dbLoc == uiLoc);
          final isCatMatch = (dbCatMapped == uiCat);

          return isLocMatch && isCatMatch;
        }).toList();



        // ─── SORTING ───
        filtered.sort((a, b) {
          if (a['category'] == targetCat && b['category'] != targetCat) {
            return -1;
          }
          if (a['category'] != targetCat && b['category'] == targetCat) {
            return 1;
          }
          return 0;
        });

        recommendedDestinations.value = filtered;
      } else {
        throw Exception("Server mengembalikan status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("DEBUG: Gagal mengambil data dari API Neon: $e");
      Get.snackbar(
        "Gagal Memuat Data",
        "Tidak dapat terhubung ke server. Pastikan perangkat Anda terhubung ke internet.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFBA1A1A),
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Asset lokal cadangan bila foto dari server kosong
  String _defaultAssetForCategory(String category) {
    switch (category) {
      case "Pantai":
        return "assets/images/karimun.jpg";
      case "Gunung":
        return "assets/images/gunung-sindoro.jpg";
      default:
        return "assets/images/dieng.jpg";
    }
  }

  // Fungsi seleksi card lokal lama Anda
  void selectCard(int index) {
    toggleSelection(index);
  }

  // ALIAS METHOD: Agar terpanggil sukses dari View tanpa error undefined (PERBAIKAN)
  void toggleSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }

  // Helper untuk mengecek status seleksi di View
  bool isSelected(int index) => selectedIndices.contains(index);

  // Getter untuk mengaktifkan tombol lanjut
  bool get isAnySelected => selectedIndices.isNotEmpty;

  // METHOD LOGIKAL FORMAT RUPIAH (PERBAIKAN BIAYA DI VIEW)
  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}