class MongoDestination {
  final String namaWisata;
  final String lokasi;
  final double rating;
  final String kategori;
  final String fotoUrl;

  MongoDestination({
    required this.namaWisata,
    required this.lokasi,
    required this.rating,
    required this.kategori,
    required this.fotoUrl,
  });

  factory MongoDestination.fromJson(Map<String, dynamic> json) {
    return MongoDestination(
      namaWisata: json['nama_wisata'] ?? 'Tanpa Nama',
      lokasi: json['lokasi'] ?? 'Lokasi Tidak Diketahui',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      kategori: json['kategori'] ?? 'Lainnya',
      fotoUrl: json['foto_url'] ?? '',
    );
  }
}
