import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/trip_log_service.dart';
import '../../../models/trip_log_model.dart';

class ActivityLogView extends StatefulWidget {
  const ActivityLogView({super.key});

  @override
  State<ActivityLogView> createState() => _ActivityLogViewState();
}

class _ActivityLogViewState extends State<ActivityLogView> {
  String _chartMode = 'vehicle'; // 'vehicle' atau 'dailyCost'
  int _touchedChartIndex = -1;

  String _formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String _formatSavedAt(DateTime dt) {
    final List<String> months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    final List<String> days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    String day = days[dt.weekday - 1];
    return "$day, ${dt.day} ${months[dt.month - 1]} ${dt.year} · $hour:$minute";
  }

  String _formatShortDate(DateTime dt) {
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TripLogService.to.loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Obx(() {
        final logs = TripLogService.to.logs;
        return CustomScrollView(
          slivers: [
            // ── HEADER SliverAppBar ──
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: const Color(0xFF003D6B),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                if (logs.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.white70,
                    ),
                    tooltip: "Hapus Semua",
                    onPressed: () => _showClearDialog(),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF003D6B),
                        Color(0xFF0061A8),
                        Color(0xFF0097D6),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Log Aktivitas",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    "${logs.length} Perjalanan Tercatat",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── STATISTIK RINGKASAN (jika ada log) ──
            if (logs.isNotEmpty)
              SliverToBoxAdapter(child: _buildSummaryStats(logs)),

            // ── EMPTY STATE atau LIST LOG ──
            if (logs.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            bottom: 12,
                            left: 4,
                          ),
                          child: Text(
                            "Riwayat Perjalanan",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.0,
                            ),
                          ),
                        );
                      }
                      final log = logs[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Dismissible(
                          key: ValueKey('${log.savedAt.millisecondsSinceEpoch}_$index'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await _showDeleteItemDialog(log.title);
                          },
                          onDismissed: (direction) {
                            final realIndex = index - 1;
                            TripLogService.to.deleteLogAt(realIndex);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          child: _TripLogCard(
                            log: log,
                            index: index - 1,
                            formatRupiah: _formatRupiah,
                            formatSavedAt: _formatSavedAt,
                            formatShortDate: _formatShortDate,
                          ),
                        ),
                      );
                    },
                    childCount: logs.length + 1, // +1 untuk label header
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildInteractiveCharts(logs),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildSummaryStats(List<TripLog> logs) {
    final double totalSpent = logs.fold(0, (sum, l) => sum + l.totalCost);
    final int totalDays = logs.fold(0, (sum, l) => sum + l.durationDays);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0061A8).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF0061A8),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                "Ringkasan Perjalanan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(
                "${logs.length}",
                "Total Trip",
                Icons.flight_rounded,
                const Color(0xFF0061A8),
              ),
              _verticalDivider(),
              _statItem(
                "$totalDays",
                "Total Hari",
                Icons.calendar_today_rounded,
                const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003D6B), Color(0xFF0061A8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pengeluaran",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatRupiah(totalSpent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0061A8).withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_rounded,
              size: 56,
              color: Color(0xFF0061A8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Belum Ada Perjalanan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Selesaikan itinerary pertamamu\nuntuk melihat log di sini.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              "Buat Perjalanan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0061A8),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteItemDialog(String tripTitle) async {
    return await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Hapus Log Ini?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "\"$tripTitle\" akan dihapus secara permanen dari log dan database.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Hapus Semua Log?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Semua riwayat perjalanan akan dihapus secara permanen.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        TripLogService.to.clearLogs();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCharts(List<TripLog> logs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0061A8).withValues(alpha: 0.09),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ROW ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chartMode == 'dailyCost'
                        ? 'Biaya Harian per Trip'
                        : 'Distribusi Kendaraan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _chartMode == 'dailyCost'
                        ? '${logs.length} perjalanan terakhir'
                        : '${logs.length} total perjalanan',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // ── TOGGLE BUTTONS ──
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _chartModeButton('dailyCost', Icons.analytics_outlined),
                    _chartModeButton('vehicle', Icons.directions_car_filled_outlined),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _chartMode == 'dailyCost'
              ? _buildDailyCostBarChart(logs)
              : _buildVehiclePieChart(logs),
        ],
      ),
    );
  }

  Widget _chartModeButton(String mode, IconData icon) {
    final bool isActive = _chartMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _chartMode = mode;
          _touchedChartIndex = -1;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0061A8) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0061A8).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildDailyCostBarChart(List<TripLog> logs) {
    final List<TripLog> displayLogs = logs.take(10).toList().reversed.toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double chartWidth = displayLogs.length * 72.0 > screenWidth - 64
        ? displayLogs.length * 72.0
        : screenWidth - 64;

    // Compute stats for header
    final List<double> dailyCosts = displayLogs.map((l) {
      return l.durationDays > 0 ? l.totalCost / l.durationDays : 0.0;
    }).toList();
    final double maxCost = dailyCosts.isEmpty ? 0 : dailyCosts.reduce((a, b) => a > b ? a : b);
    final double avgCost = dailyCosts.isEmpty ? 0 : dailyCosts.fold(0.0, (s, v) => s + v) / dailyCosts.length;

    double maxVal = 100000;
    for (var log in displayLogs) {
      final double dailyCost = log.durationDays > 0 ? log.totalCost / log.durationDays : 0.0;
      if (dailyCost > maxVal) maxVal = dailyCost;
    }
    maxVal = maxVal * 1.15;

    return Column(
      children: [
        // ── STATS ROW ──
        Row(
          children: [
            _buildChartStatChip(
              Icons.trending_up_rounded,
              'Tertinggi',
              _formatRupiah(maxCost),
              const Color(0xFF0061A8),
            ),
            const SizedBox(width: 10),
            _buildChartStatChip(
              Icons.equalizer_rounded,
              'Rata-rata',
              _formatRupiah(avgCost),
              const Color(0xFF0891B2),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // ── BAR CHART ──
        SizedBox(
          height: 210,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: const Color(0xFF0F172A),
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final log = displayLogs[group.x.toInt()];
                        final daily = rod.toY;
                        return BarTooltipItem(
                          '${log.title}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: _formatRupiah(daily),
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const TextSpan(
                              text: ' / hari',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
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
                        setState(() { _touchedChartIndex = -1; });
                        return;
                      }
                      setState(() {
                        _touchedChartIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= displayLogs.length) return const SizedBox.shrink();
                          final log = displayLogs[idx];
                          final isTouched = _touchedChartIndex == idx;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 6,
                            child: Text(
                              log.title.length > 7 ? '${log.title.substring(0, 6)}..' : log.title,
                              style: TextStyle(
                                color: isTouched ? const Color(0xFF0061A8) : const Color(0xFF94A3B8),
                                fontWeight: isTouched ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == 0) return const SizedBox.shrink();
                          String text = '';
                          if (value >= 1000000) {
                            text = '${(value / 1000000).toStringAsFixed(1)}Jt';
                          } else if (value >= 1000) {
                            text = '${(value / 1000).toStringAsFixed(0)}Rb';
                          } else {
                            text = value.toInt().toString();
                          }
                          return Text(
                            text,
                            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 8),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: const Color(0xFFF1F5F9),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: displayLogs.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final TripLog log = entry.value;
                    final isTouched = idx == _touchedChartIndex;
                    final double dailyCost = log.durationDays > 0 ? log.totalCost / log.durationDays : 0.0;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: dailyCost,
                          gradient: LinearGradient(
                            colors: isTouched
                                ? [const Color(0xFF0097D6), const Color(0xFF00C6FF)]
                                : [const Color(0xFF003D6B), const Color(0xFF0097D6)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: isTouched ? 14 : 10,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxVal,
                            color: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChartStatChip(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                  Text(value, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclePieChart(List<TripLog> logs) {
    final Map<String, int> vehicleCounts = {};
    for (var log in logs) {
      final String vehicle = log.vehicleType.trim().isEmpty ? 'Lainnya' : log.vehicleType.trim();
      vehicleCounts[vehicle] = (vehicleCounts[vehicle] ?? 0) + 1;
    }
    final List<MapEntry<String, int>> displayData = vehicleCounts.entries.toList();
    displayData.sort((a, b) => b.value.compareTo(a.value));

    Color getVehicleColor(String type, int index) {
      switch (type.toLowerCase()) {
        case 'mobil':   return const Color(0xFF0284C7);
        case 'motor':   return const Color(0xFFF59E0B);
        case 'pesawat': return const Color(0xFF10B981);
        case 'kereta':  return const Color(0xFF8B5CF6);
        case 'bus':     return const Color(0xFFEC4899);
        default:
          return [const Color(0xFF06B6D4), const Color(0xFF14B8A6), const Color(0xFF64748B), const Color(0xFFF43F5E)][index % 4];
      }
    }

    Gradient getVehicleGradient(String type, int index) {
      Color c1;
      Color c2;
      switch (type.toLowerCase()) {
        case 'mobil':
          c1 = const Color(0xFF38BDF8);
          c2 = const Color(0xFF0284C7);
          break;
        case 'motor':
          c1 = const Color(0xFFFBBF24);
          c2 = const Color(0xFFD97706);
          break;
        case 'pesawat':
          c1 = const Color(0xFF34D399);
          c2 = const Color(0xFF059669);
          break;
        case 'kereta':
          c1 = const Color(0xFFA78BFA);
          c2 = const Color(0xFF7C3AED);
          break;
        case 'bus':
          c1 = const Color(0xFFF472B6);
          c2 = const Color(0xFFDB2777);
          break;
        default:
          final list = [
            [const Color(0xFF22D3EE), const Color(0xFF0891B2)],
            [const Color(0xFF2DD4BF), const Color(0xFF0D9488)],
            [const Color(0xFF94A3B8), const Color(0xFF475569)],
            [const Color(0xFFFB7185), const Color(0xFFE11D48)],
          ];
          c1 = list[index % list.length][0];
          c2 = list[index % list.length][1];
      }
      return LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    IconData getVehicleIcon(String type) {
      switch (type.toLowerCase()) {
        case 'mobil':   return Icons.directions_car_rounded;
        case 'motor':   return Icons.two_wheeler_rounded;
        case 'pesawat': return Icons.flight_rounded;
        case 'kereta':  return Icons.train_rounded;
        case 'bus':     return Icons.directions_bus_rounded;
        default:        return Icons.commute_rounded;
      }
    }

    final topVehicle = displayData.isNotEmpty ? displayData.first : null;
    final topPct = topVehicle != null ? ((topVehicle.value / logs.length) * 100).toStringAsFixed(0) : '0';

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── DONUT CHART ──
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              setState(() { _touchedChartIndex = -1; });
                              return;
                            }
                            setState(() {
                              _touchedChartIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 28,
                        sections: displayData.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final String vehicle = entry.value.key;
                          final double count = entry.value.value.toDouble();
                          final isTouched = idx == _touchedChartIndex;
                          final double radius = isTouched ? 38.0 : 30.0;
                          final Color color = getVehicleColor(vehicle, idx);
                          final Gradient gradient = getVehicleGradient(vehicle, idx);
                          return PieChartSectionData(
                            gradient: gradient,
                            value: count,
                            title: '${count.toInt()}x',
                            radius: radius,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // ── CENTER LABEL ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$topPct%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (topVehicle != null)
                          Text(
                            topVehicle.key,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // ── LEGEND ──
              Expanded(
                flex: 5,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayData.length,
                  itemBuilder: (context, idx) {
                    final item = displayData[idx];
                    final isSelected = _touchedChartIndex == idx;
                    final percentage = (item.value / logs.length) * 100;
                    final color = getVehicleColor(item.key, idx);
                    return GestureDetector(
                      onTap: () => setState(() => _touchedChartIndex = isSelected ? -1 : idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: getVehicleGradient(item.key, idx),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 3,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? color : const Color(0xFF475569),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.value}x · ${percentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: color.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  KARTU LOG INDIVIDUAL
// ═══════════════════════════════════════════════
class _TripLogCard extends StatelessWidget {
  final TripLog log;
  final int index;
  final String Function(double) formatRupiah;
  final String Function(DateTime) formatSavedAt;
  final String Function(DateTime) formatShortDate;

  const _TripLogCard({
    required this.log,
    required this.index,
    required this.formatRupiah,
    required this.formatSavedAt,
    required this.formatShortDate,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── TOP COLOR STRIP ──
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003D6B), Color(0xFF0097D6)],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── BARIS JUDUL ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge nomor
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF003D6B), Color(0xFF0061A8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log.dateRange,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 14),

                  // ── INFO CHIP ROW ──
                  Row(
                    children: [
                      _chip(
                        Icons.schedule_outlined,
                        "${log.durationDays} Hari",
                        const Color(0xFF7C3AED),
                      ),
                      const SizedBox(width: 8),
                      _chip(
                        Icons.directions_car_outlined,
                        log.vehicleType.replaceAll("Kendaraan ", ""),
                        const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 8),
                      _chip(
                        Icons.place_outlined,
                        "${log.destinations.length} Spot",
                        const Color(0xFFD97706),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── BIAYA SECTION ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Estimasi",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatRupiah(log.totalCost),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0061A8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── TIMESTAMP ──
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          formatSavedAt(log.savedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
