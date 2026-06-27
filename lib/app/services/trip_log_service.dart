import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/trip_log_model.dart';

class TripLogService extends GetxService {
  static TripLogService get to => Get.find();

  final RxList<TripLog> logs = <TripLog>[].obs;
  final GetStorage _box = GetStorage();

  String get _storageKey {
    final email = _box.read('user_email') ?? 'guest';
    return 'saved_trip_logs_$email';
  }

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  void loadLogs() {
    final List<dynamic>? rawLogs = _box.read<List<dynamic>>(_storageKey);
    if (rawLogs != null) {
      logs.assignAll(rawLogs.map((item) => TripLog.fromJson(Map<String, dynamic>.from(item))).toList());
    } else {
      logs.clear();
    }
  }

  void _saveLogs() {
    final List<Map<String, dynamic>> rawList = logs.map((log) => log.toJson()).toList();
    _box.write(_storageKey, rawList);
  }

  void addLog(TripLog log) {
    loadLogs();
    logs.insert(0, log); // Log terbaru di atas
    _saveLogs();
  }

  void clearLogs() {
    logs.clear();
    _box.remove(_storageKey);
  }
}
