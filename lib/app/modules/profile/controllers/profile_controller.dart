import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  // Observable untuk menampung data nama dan email secara dinamis
  var userName = ''.obs;
  var userEmail = ''.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Membaca data email dari session lokal
    userEmail.value = box.read('user_email') ?? 'traveler@example.com';
    
    // ─── AMBIL NAMA ASLI DARI MEMORI, JIKA KOSONG GUNAKAN EMAIL SEBAGAI ALTERNATIF ───
    String? namaTersimpan = box.read('user_nama');
    if (namaTersimpan != null && namaTersimpan.isNotEmpty) {
      userName.value = namaTersimpan;
    } else {
      // Jika nama belum ter-cache (misal login lama), potong bagian depan email sebagai nama sementara
      userName.value = userEmail.value.split('@')[0]; 
    }
  }

  // Fungsi hapus sesi saat logout tetap aman dan bersih
  void logoutUser() {
    box.remove('token');
    box.remove('user_email');
    box.remove('user_nama'); // Ikut bersihkan cache nama saat keluar aplikasi
    
    Get.offAllNamed(Routes.LOGIN);
  }
}