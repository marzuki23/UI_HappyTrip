import 'package:flutter/material.dart';
import 'package:happytrip/app/models/apify_destination_model.dart';
import 'package:happytrip/app/services/mongodb_service.dart';

class TopDestinationsWidget extends StatefulWidget {
  const TopDestinationsWidget({Key? key}) : super(key: key);

  @override
  State<TopDestinationsWidget> createState() => _TopDestinationsWidgetState();
}

class _TopDestinationsWidgetState extends State<TopDestinationsWidget> {
  List<ApifyDestination> allTopDestinations = [];
  List<ApifyDestination> topDestinations = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedDestinationIndex = -1;

  bool isSearching = false;
  String searchQuery = '';
  String selectedCity = 'Semua';
  String sortBy = 'rating';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTopDestinations();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTopDestinations() async {
    try {
      final List<Map<String, dynamic>> data = await MongoDbService.fetchTopDestinations();
      
      // 1. Ubah data JSON mentah menjadi list objek berdasarkan cetakan Model
      List<ApifyDestination> destinations = data
          .map((item) => ApifyDestination.fromJson(item))
          .toList();

      // 2. Sortir data berdasarkan totalScore (rating) tertinggi ke terendah
      destinations.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      // 3. Ambil 10 data teratas saja
      setState(() {
        allTopDestinations = destinations.take(10).toList();
        topDestinations = List.from(allTopDestinations);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data destinasi teratas dari MongoDB';
        isLoading = false;
      });
    }
  }

  void _applyFilterAndSort() {
    List<ApifyDestination> filtered = List.from(allTopDestinations);

    // Filter by City
    if (selectedCity != 'Semua') {
      filtered = filtered.where((item) => item.city.trim().toLowerCase() == selectedCity.trim().toLowerCase()).toList();
    }

    // Filter by Search
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final title = item.title.toLowerCase();
        final city = item.city.toLowerCase();
        final cat = item.category.toLowerCase();
        final q = searchQuery.toLowerCase();
        return title.contains(q) || city.contains(q) || cat.contains(q);
      }).toList();
    }

    // Sort
    if (sortBy == 'rating') {
      filtered.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    } else if (sortBy == 'name') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    }

    setState(() {
      topDestinations = filtered;
    });
  }

  List<String> _getUniqueCities() {
    final cities = allTopDestinations.map((e) => e.city.trim()).toSet().toList();
    cities.sort();
    return ['Semua', ...cities];
  }

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
        child: Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red))),
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
          )
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
                      "Top 10 Destinasi di Jawa Tengah",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ketuk destinasi untuk info. Update: Mei 2026",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isSearching ? Icons.close : Icons.search,
                      size: 20,
                      color: isSearching ? Colors.redAccent : Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                        if (!isSearching) {
                          searchQuery = '';
                          searchController.clear();
                          _applyFilterAndSort();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      sortBy == 'rating' ? Icons.star_rate_rounded : Icons.sort_by_alpha_rounded,
                      size: 20,
                      color: Colors.amber[800],
                    ),
                    tooltip: sortBy == 'rating' ? "Urutkan berdasarkan Rating" : "Urutkan berdasarkan Abjad",
                    onPressed: () {
                      setState(() {
                        sortBy = sortBy == 'rating' ? 'name' : 'rating';
                        _applyFilterAndSort();
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          if (isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Cari destinasi...",
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                              _applyFilterAndSort();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  searchQuery = val;
                  _applyFilterAndSort();
                },
              ),
            ),
          if (allTopDestinations.isNotEmpty)
            Container(
              height: 38,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _getUniqueCities().map((city) {
                  final isSelected = selectedCity == city;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      label: Text(city),
                      selected: isSelected,
                      selectedColor: Colors.blue[50],
                      checkmarkColor: Colors.blue[800],
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue[900] : Colors.black87,
                      ),
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? Colors.blue.shade300 : Colors.transparent,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedCity = city;
                          _applyFilterAndSort();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          topDestinations.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      "Tidak ada destinasi cocok",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topDestinations.length,
                  itemBuilder: (context, index) {
                    final item = topDestinations[index];
                    double progressValue = item.totalScore / 5.0;
                    final bool isSelected = selectedDestinationIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: isSelected ? 8 : 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.amber.withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.amber.withOpacity(0.3) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedDestinationIndex = index;
                          });
                          _showDestinationDetailsBottomSheet(context, item).then((_) {
                            setState(() {
                              selectedDestinationIndex = -1;
                            });
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: index < 3 ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: index < 3 ? Colors.orange : Colors.grey
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title, 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis, 
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)
                                  ),
                                  Text(
                                    "${item.city} | ${item.category}", 
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progressValue,
                                      backgroundColor: Colors.grey.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(index < 3 ? Colors.amber : Colors.blueAccent),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  item.totalScore.toStringAsFixed(1), 
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Future<void> _showDestinationDetailsBottomSheet(BuildContext context, ApifyDestination item) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          item.totalScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Text(
                    item.city,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.category, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 4),
                  Text(
                    item.category,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                "Indikator Skor Kepuasan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.totalScore / 5.0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${((item.totalScore / 5.0) * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tutup Detail",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
