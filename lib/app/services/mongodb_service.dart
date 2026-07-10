import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDbService {
  static Db? _db;
  static const String _connectionString =
      "mongodb+srv://idris:Idris123@cluster0.1l6mbxu.mongodb.net/happytrip?retryWrites=true&w=majority";

  static Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      debugPrint("Menghubungkan ke MongoDB Atlas...");
      _db = await Db.create(_connectionString);
      await _db!.open();
      debugPrint("Koneksi MongoDB Atlas berhasil!");
    } catch (e) {
      debugPrint("Gagal menghubungkan ke MongoDB Atlas: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDestinations() async {
    try {
      await connect();
      if (_db == null || !_db!.isConnected) {
        throw Exception("MongoDB Atlas tidak terhubung");
      }
      final collection = _db!.collection("destinations");
      final list = await collection.find().toList();
      debugPrint("Berhasil mengambil ${list.length} destinasi dari MongoDB.");
      return list;
    } catch (e) {
      debugPrint("Error fetchDestinations: $e");
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTopDestinations() async {
    try {
      await connect();
      if (_db == null || !_db!.isConnected) {
        throw Exception("MongoDB Atlas tidak terhubung");
      }
      final collection = _db!.collection("top_destinations");
      final list = await collection.find().toList();
      debugPrint("Berhasil mengambil ${list.length} top_destinations dari MongoDB.");
      return list;
    } catch (e) {
      debugPrint("Error fetchTopDestinations: $e");
      rethrow;
    }
  }

  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
      debugPrint("Koneksi MongoDB Atlas ditutup.");
    }
  }
}
