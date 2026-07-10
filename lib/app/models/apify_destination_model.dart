class ApifyDestination {
  final String title;
  final double totalScore;
  final String city;
  final String category;

  ApifyDestination({
    required this.title,
    required this.totalScore,
    required this.city,
    required this.category,
  });

  // Fungsi pengubah dari JSON mentah (Map) menjadi Objek rapi.
  factory ApifyDestination.fromJson(Map<String, dynamic> json) {
    // 1. Ambil teks alamat mentah terlebih dahulu
    String rawAddress =
        json['subTitle'] ?? json['address'] ?? 'Lokasi Tidak Diketahui';
    String cleanedCity = 'Lokasi Tidak Diketahui';

    // 2. Logika Pembersihan Teks Alamat menjadi Nama Kota Saja
    if (rawAddress != 'Lokasi Tidak Diketahui') {
      // Kita potong alamat berdasarkan tanda koma ( , )
      List<String> parts = rawAddress.split(',');

      if (parts.length >= 2) {
        // Biasanya nama Kabupaten/Kota terletak di 2 atau 3 bagian dari belakang sebelum nama Provinsi.
        // Kita ambil bagian yang mengandung kata "Kabupaten" atau "Kota" atau teks sebelum "Jawa Tengah"
        String targetPart = parts[parts.length - 2].trim();

        // Jika bagian tersebut adalah nama provinsi (misal Jawa Tengah), kita mundur 1 langkah lagi ke belakang
        if (targetPart.toLowerCase().contains('jawa') ||
            targetPart.toLowerCase().contains('indonesia')) {
          targetPart = parts[parts.length - 3].trim();
        }

        // Bersihkan kata-kata tidak penting seperti kode pos jika ada
        cleanedCity = targetPart.replaceAll(RegExp(r'\d+'), '').trim();
      } else {
        cleanedCity = rawAddress;
      }
    }

    return ApifyDestination(
      title: json['title'] ?? 'Tanpa Nama',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      city:
          cleanedCity, // Hasil kota yang sudah bersih dari alamat panjang & koordinat
      category: json['categoryName'] ?? json['type'] ?? 'Lainnya',
    );
  }
}
