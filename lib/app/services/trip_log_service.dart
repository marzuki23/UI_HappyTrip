import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/trip_log_model.dart';

class TripLogService extends GetxService {
  static TripLogService get to => Get.find();

  final RxList<TripLog> logs = <TripLog>[].obs;
  final GetStorage _box = GetStorage();
  final String _baseUrl = 'http://api.api-happytrip.my.id';

  String get _storageKey {
    final email = _box.read('user_email') ?? 'guest';
    return 'saved_trip_logs_$email';
  }

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    // 1. Muat data dari penyimpanan lokal (offline cache) terlebih dahulu
    final List<dynamic>? rawLogs = _box.read<List<dynamic>>(_storageKey);
    if (rawLogs != null) {
      logs.assignAll(
        rawLogs
            .map((item) => TripLog.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    } else {
      logs.clear();
    }

    // 2. Jika user login (ada token), sinkronkan dengan database Neon Cloud
    final token = _box.read('token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/auth/trip-logs'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> serverLogs = jsonDecode(response.body);
          final parsedLogs = serverLogs.map((item) {
            List<Map<String, dynamic>> destinationsList = [];
            if (item['destinations'] != null) {
              if (item['destinations'] is String) {
                destinationsList = List<Map<String, dynamic>>.from(
                  jsonDecode(item['destinations']),
                );
              } else {
                destinationsList = List<Map<String, dynamic>>.from(
                  item['destinations'],
                );
              }
            }
            return TripLog(
              id:           item['id'] as int?,
              title:        item['title'] ?? '',
              dateRange:    item['dateRange'] ?? '',
              destination:  item['destination'] ?? '',
              vehicleType:  item['vehicleType'] ?? '',
              durationDays: item['durationDays'] ?? 1,
              totalCost:    (item['totalCost'] as num?)?.toDouble() ?? 0.0,
              budget:       (item['budget'] as num?)?.toDouble() ?? 0.0,
              isWithinBudget: item['isWithinBudget'] ?? true,
              destinations: destinationsList,
              savedAt: item['savedAt'] != null
                  ? DateTime.parse(item['savedAt'])
                  : DateTime.now(),
            );
          }).toList();


          logs.assignAll(parsedLogs);
          _box.write(_storageKey, parsedLogs.map((e) => e.toJson()).toList());
        }
      } catch (e) {
        print("Gagal memuat log dari Neon DB: $e");
      }
    }
  }

  Future<void> addLog(TripLog log) async {
    // 1. Simpan secara lokal instan agar UI responsive
    loadLogs();
    logs.insert(0, log);
    _box.write(_storageKey, logs.map((l) => l.toJson()).toList());

    // 2. Kirim data ke database Neon secara asinkron
    final token = _box.read('token');
    if (token != null) {
      try {
        final url = '$_baseUrl/auth/trip-logs';
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['title'] = log.title;
        request.fields['dateRange'] = log.dateRange;
        request.fields['destination'] = log.destination;
        request.fields['vehicleType'] = log.vehicleType;
        request.fields['durationDays'] = log.durationDays.toString();
        request.fields['totalCost'] = log.totalCost.toString();
        request.fields['budget'] = log.budget.toString();
        request.fields['isWithinBudget'] = log.isWithinBudget.toString();
        request.fields['destinations'] = jsonEncode(log.destinations);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("Berhasil menyimpan log perjalanan ke Neon DB");
        } else {
          print(
            "Gagal simpan ke Neon DB: ${response.statusCode} - ${response.body}",
          );
        }
      } catch (e) {
        print("Error simpan log ke Neon DB: $e");
      }
    }
  }

  Future<void> deleteLogAt(int index) async {
    if (index < 0 || index >= logs.length) return;

    final logToDelete = logs[index];

    // 1. Hapus dari list lokal instan agar UI responsif
    logs.removeAt(index);
    _box.write(_storageKey, logs.map((l) => l.toJson()).toList());

    // 2. Hapus dari Neon DB via endpoint DELETE /auth/trip-logs/{id}
    final token = _box.read('token');
    if (token != null && logToDelete.id != null) {
      try {
        final response = await http.delete(
          Uri.parse('$_baseUrl/auth/trip-logs/${logToDelete.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          print("Berhasil hapus log #${logToDelete.id} dari Neon DB");
        } else {
          print("Gagal hapus dari Neon DB: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        print("Gagal hapus log dari Neon DB: $e");
      }
    } else if (logToDelete.id == null) {
      print("Log tidak punya ID server, hanya dihapus dari lokal");
    }
  }

  Future<void> clearLogs() async {
    logs.clear();
    _box.remove(_storageKey);

    final token = _box.read('token');
    if (token != null) {
      try {
        final response = await http.delete(
          Uri.parse('$_baseUrl/auth/trip-logs'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          print("Berhasil menghapus semua log perjalanan di Neon DB");
        }
      } catch (e) {
        print("Gagal menghapus log perjalanan di Neon DB: $e");
      }
    }
  }
}
