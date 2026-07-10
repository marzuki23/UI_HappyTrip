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
}