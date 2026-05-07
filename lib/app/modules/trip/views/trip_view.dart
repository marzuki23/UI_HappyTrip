import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trip_controller.dart';

class TripView extends GetView<TripController> {
  const TripView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Rencanakan Perjalanan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Atur preferensi liburan idealmu",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                _buildLabel("KATEGORI WISATA"),
                DropdownButtonFormField<String>(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: ["Pantai", "Gunung", "Kota"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: _inputStyle(),
                ),

                _buildSpacing(),

                _buildLabel("LOKASI USER"),
                TextField(
                  decoration: _inputStyle(hint: "Masukkan lokasi Anda"),
                ),

                _buildSpacing(),

                _buildLabel("LOKASI TUJUAN"),
                DropdownButtonFormField<String>(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: ["Wonosobo", "Yogyakarta", "Bandung"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: _inputStyle(),
                ),

                _buildSpacing(),

                // --- BAGIAN TANGGAL (DIPERBAIKI AGAR LURUS) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Kunci agar sejajar atas
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("TANGGAL BERANGKAT"),
                          TextField(
                            decoration: _inputStyle(hint: "mm/dd/yyyy"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15), // Jarak antar kolom
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("TANGGAL PULANG"),
                          TextField(
                            decoration: _inputStyle(hint: "mm/dd/yyyy"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildSpacing(),

                _buildLabel("JENIS KENDARAAN"),
                DropdownButtonFormField<String>(
                  items: ["Kendaraan Pribadi", "Pesawat Terbang", "Kereta Api"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: _inputStyle(),
                ),

                _buildSpacing(),

                // --- BAGIAN BUDGET & DURASI (DIPERBAIKI AGAR LURUS) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Kunci agar sejajar atas
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("BUDGET PERJALANAN"),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: _inputStyle(hint: "Rp 0"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("DURASI"),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: _inputStyle(hint: "1 Hari"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {}, // Fungsi tetap kosong/sama
                    icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    label: const Text(
                      "Lihat Rekomendasi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061A8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Label agar teks tidak turun/miring
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        maxLines: 1, // Memastikan label tidak membungkus ke baris baru
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11, // Ukuran sedikit diperkecil agar pas di layar kecil
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSpacing() => const SizedBox(height: 20);

  // Style Input yang konsisten
  InputDecoration _inputStyle({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      // ContentPadding harus SAMA untuk semua field agar tinggi kotak identik
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}