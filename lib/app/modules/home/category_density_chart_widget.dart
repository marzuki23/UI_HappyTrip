import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:happytrip/app/services/mongodb_service.dart';

class CategoryDensityChartWidget extends StatefulWidget {
  const CategoryDensityChartWidget({Key? key}) : super(key: key);

  @override
  State<CategoryDensityChartWidget> createState() =>
      _CategoryDensityChartWidgetState();
}

class _CategoryDensityChartWidgetState
    extends State<CategoryDensityChartWidget> {
  List<Map<String, dynamic>> categoryDensityData = [];
  List<dynamic> rawApiData = [];
  bool isLoading = true;
  String errorMessage = '';
  int maxCategoryCount = 1;
  String viewMode = 'list'; // 'list', 'bar', 'pie'
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchCategoryDensity();
  }

  Future<void> fetchCategoryDensity() async {
    try {
      final List<Map<String, dynamic>> data =
          await MongoDbService.fetchDestinations();

      // 1. LOGIKA HITUNG KEPADATAN KATEGORI SECARA MANDIRI
      final Map<String, int> countingMap = {};
      final List<String> targetKategori = [
        'Agrowisata',
        'Air Terjun',
        'Alam',
        'Candi',
        'Danau',
        'Goa',
        'Gunung',
        'Museum',
        'Pantai',
        'Religi',
        'Sejarah',
        'Taman',
        'Wisata Keluarga',
      ];

      // Inisialisasi awal semua kategori dengan angka 0
      for (var kat in targetKategori) {
        countingMap[kat] = 0;
      }

      // Mulai menghitung kecocokan kategori dari data API
      for (var item in data) {
        String apiKat = (item['kategori'] ?? 'Lainnya')
            .toString()
            .toLowerCase()
            .trim();

        for (var kat in targetKategori) {
          if (apiKat.contains(kat.toLowerCase())) {
            countingMap[kat] = (countingMap[kat] ?? 0) + 1;
            break;
          }
        }
      }

      // Konversi map penghitung menjadi list terurut untuk grafik horizontal
      final List<Map<String, dynamic>> rawDensityList = [];
      countingMap.forEach((key, value) {
        rawDensityList.add({'name': key, 'count': value});
      });

      // Urutkan dari kategori terbanyak agar membentuk tangga yang rapi
      rawDensityList.sort((a, b) => b['count'].compareTo(a['count']));

      // Cari nilai tertinggi sebagai pembagi batas progress bar
      int currentMax = rawDensityList
          .map((e) => e['count'] as int)
          .fold(0, (max, e) => e > max ? e : max);

      setState(() {
        rawApiData = data;
        categoryDensityData = rawDensityList;
        maxCategoryCount = currentMax == 0 ? 1 : currentMax;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data sebaran kategori dari MongoDB';
        isLoading = false;
      });
    }
  }

  int selectedCategoryIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kepadatan Objek Wisata Per Kategori",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ketuk grafik untuk detail. Update: Mei 2026",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildViewModeButton('list', Icons.format_list_bulleted),
                  _buildViewModeButton('bar', Icons.bar_chart),
                  _buildViewModeButton('pie', Icons.pie_chart_outline),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: viewMode == 'list'
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildListViewChart(),
            secondChild: viewMode == 'bar'
                ? _buildBarChart()
                : _buildPieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String mode, IconData icon) {
    bool isActive = viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          viewMode = mode;
          touchedIndex = -1;
          selectedCategoryIndex = -1;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D47A1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildListViewChart() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryDensityData.length,
      itemBuilder: (context, index) {
        final item = categoryDensityData[index];
        final double progressRatio = item['count'] / maxCategoryCount;
        final bool isSelected = selectedCategoryIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 8 : 4,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? _getCategoryColor(index).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
              _showCategoryDestinationsBottomSheet(item['name']).then((_) {
                setState(() {
                  selectedCategoryIndex = -1;
                });
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? _getCategoryColor(index)
                          : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width:
                                maxWidth *
                                (progressRatio == 0 ? 0.01 : progressRatio),
                            height: 14,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(index),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _getCategoryColor(
                                          index,
                                        ).withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 25,
                  child: Text(
                    "${item['count']}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? _getCategoryColor(index)
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 580,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxCategoryCount + 2).toDouble(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: const Color(0xFF212121).withOpacity(0.9),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final categoryName =
                        categoryDensityData[group.x.toInt()]['name'];
                    return BarTooltipItem(
                      '$categoryName\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${rod.toY.toInt()} Wisata',
                          style: TextStyle(
                            color: _getCategoryColor(group.x.toInt()),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    setState(() {
                      touchedIndex = -1;
                    });
                    return;
                  }
                  final int index = barTouchResponse.spot!.touchedBarGroupIndex;
                  setState(() {
                    touchedIndex = index;
                  });

                  if (event is FlTapUpEvent) {
                    final categoryName = categoryDensityData[index]['name'];
                    _showCategoryDestinationsBottomSheet(categoryName);
                  }
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final int idx = value.toInt();
                      if (idx < 0 || idx >= categoryDensityData.length) {
                        return const SizedBox.shrink();
                      }
                      final name = categoryDensityData[idx]['name'];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            name,
                            style: TextStyle(
                              color: touchedIndex == idx
                                  ? _getCategoryColor(idx)
                                  : Colors.black54,
                              fontWeight: touchedIndex == idx
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 9),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: categoryDensityData.asMap().entries.map((entry) {
                final int idx = entry.key;
                final int count = entry.value['count'];
                final isTouched = idx == touchedIndex;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: _getCategoryColor(idx),
                      width: isTouched ? 16 : 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxCategoryCount.toDouble(),
                        color: Colors.grey.withOpacity(0.05),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    List<Map<String, dynamic>> sortedData = List.from(categoryDensityData);
    List<Map<String, dynamic>> displayData = [];
    int otherCount = 0;

    for (int i = 0; i < sortedData.length; i++) {
      if (i < 5) {
        displayData.add({
          'name': sortedData[i]['name'],
          'count': sortedData[i]['count'],
          'index': i,
        });
      } else {
        otherCount += sortedData[i]['count'] as int;
      }
    }

    if (otherCount > 0) {
      displayData.add({'name': 'Lainnya', 'count': otherCount, 'index': 12});
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      setState(() {
                        touchedIndex = -1;
                      });
                      return;
                    }
                    final int index =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                    setState(() {
                      touchedIndex = index;
                    });

                    if (event is FlTapUpEvent &&
                        index >= 0 &&
                        index < displayData.length) {
                      final categoryName = displayData[index]['name'];
                      if (categoryName == 'Lainnya') {
                        _showLainnyaCategoriesDialog(sortedData.sublist(5));
                      } else {
                        _showCategoryDestinationsBottomSheet(categoryName);
                      }
                    }
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: displayData.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final Map<String, dynamic> item = entry.value;
                  final double count = (item['count'] as int).toDouble();
                  final isTouched = idx == touchedIndex;
                  final double radius = isTouched ? 48.0 : 38.0;
                  final double fontSize = isTouched ? 15.0 : 11.0;
                  final fontWeight = isTouched
                      ? FontWeight.bold
                      : FontWeight.w500;

                  return PieChartSectionData(
                    gradient: _getCategoryGradient(item['index']),
                    value: count,
                    title: '${count.toInt()}',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: displayData.length,
              itemBuilder: (context, idx) {
                final item = displayData[idx];
                final isSelected = touchedIndex == idx;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: _getCategoryGradient(item['index']),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(item['index']).withOpacity(0.35),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          item['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? _getCategoryColor(item['index'])
                                : const Color(0xFF37474F),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLainnyaCategoriesDialog(List<Map<String, dynamic>> lainnyaList) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Kategori Lainnya",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: lainnyaList.length,
              itemBuilder: (context, index) {
                final item = lainnyaList[index];
                return ListTile(
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Text(
                    "${item['count']} Wisata",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCategoryDestinationsBottomSheet(item['name']);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoryDestinationsBottomSheet(String categoryName) {
    final filtered = rawApiData.where((item) {
      String apiKat = (item['kategori'] ?? 'Lainnya')
          .toString()
          .toLowerCase()
          .trim();
      return apiKat.contains(categoryName.toLowerCase());
    }).toList();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final searchResults = filtered.where((item) {
              final name = (item['nama_wisata'] ?? '').toString().toLowerCase();
              final desc = (item['deskripsi'] ?? '').toString().toLowerCase();
              final loc = (item['lokasi'] ?? '').toString().toLowerCase();
              final q = searchQuery.toLowerCase();
              return name.contains(q) || desc.contains(q) || loc.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kategori: $categoryName",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${searchResults.length} objek wisata ditemukan",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari tempat wisata...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: searchResults.isEmpty
                        ? const Center(
                            child: Text(
                              "Tidak ada destinasi cocok",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 20,
                            ),
                            itemCount: searchResults.length,
                            itemBuilder: (context, idx) {
                              final dst = searchResults[idx];
                              double rating =
                                  double.tryParse(
                                    dst['rating']?.toString() ?? '5',
                                  ) ??
                                  5.0;
                              double ticketPrice =
                                  double.tryParse(
                                    dst['harga_tiket']?.toString() ?? '0',
                                  ) ??
                                  0.0;
                              String formatRupiah(double val) {
                                if (val <= 0) return "Gratis";
                                return "Rp ${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                              }

                              String rawFoto =
                                  dst['foto_url']?.toString() ?? '';
                              String imgUrl = '';
                              if (rawFoto.isNotEmpty) {
                                if (rawFoto.startsWith('http')) {
                                  imgUrl = rawFoto;
                                } else {
                                  imgUrl =
                                      'http://api.api-happytrip.my.id$rawFoto';
                                }
                              }

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _showDestinationDetailDialog(
                                      context,
                                      dst,
                                      imgUrl,
                                      formatRupiah(ticketPrice),
                                      rating,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            color: Colors.grey[200],
                                            child: imgUrl.isNotEmpty
                                                ? Image.network(
                                                    imgUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.image,
                                                          color: Colors.grey,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dst['nama_wisata'] ?? 'Wisata',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF212121),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 12,
                                                    color: Colors.redAccent,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Expanded(
                                                    child: Text(
                                                      dst['lokasi'] ?? '',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 12,
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        rating.toStringAsFixed(
                                                          1,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    formatRupiah(ticketPrice),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF0D47A1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDestinationDetailDialog(
    BuildContext context,
    Map<String, dynamic> dst,
    String imgUrl,
    String formattedPrice,
    double rating,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: imgUrl.isNotEmpty
                      ? Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            dst['nama_wisata'] ?? 'Wisata',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dst['kategori'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dst['lokasi'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Tiket: $formattedPrice",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: SingleChildScrollView(
                        child: Text(
                          dst['deskripsi'] ?? 'Tidak ada deskripsi tersedia.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(int index) {
    const List<Color> colors = [
      Color(0xFF3B82F6), // vivid blue
      Color(0xFF10B981), // forest green
      Color(0xFFF59E0B), // golden amber
      Color(0xFFEF4444), // crimson
      Color(0xFF8B5CF6), // violet
      Color(0xFF06B6D4), // ocean teal
      Color(0xFFF97316), // orange
      Color(0xFFEC4899), // pink
      Color(0xFF84CC16), // lime green
      Color(0xFF6366F1), // indigo
      Color(0xFF14B8A6), // teal
      Color(0xFFFF007F), // neon pink
      Color(0xFF64748B), // slate
    ];
    return colors[index % colors.length];
  }

  Gradient _getCategoryGradient(int index) {
    const List<List<Color>> gradientPairs = [
      [Color(0xFF60A5FA), Color(0xFF2563EB)], // Modern Blue
      [Color(0xFF34D399), Color(0xFF059669)], // Modern Emerald
      [Color(0xFFFBBF24), Color(0xFFD97706)], // Amber Orange
      [Color(0xFFF87171), Color(0xFFDC2626)], // Rose/Red
      [Color(0xFFC084FC), Color(0xFF7C3AED)], // Indigo/Violet
      [Color(0xFF22D3EE), Color(0xFF0891B2)], // Cyan/Teal
      [Color(0xFFFB923C), Color(0xFFEA580C)], // Orange
      [Color(0xFFF472B6), Color(0xFFDB2777)], // Pink
      [Color(0xFFA3E635), Color(0xFF65A30D)], // Lime Green
      [Color(0xFF818CF8), Color(0xFF4F46E5)], // Indigo
      [Color(0xFF2DD4BF), Color(0xFF0D9488)], // Teal
      [Color(0xFFFF66B2), Color(0xFFFF007F)], // Neon Pink
      [Color(0xFF94A3B8), Color(0xFF475569)], // Slate
    ];
    final pair = gradientPairs[index % gradientPairs.length];
    return LinearGradient(
      colors: pair,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
