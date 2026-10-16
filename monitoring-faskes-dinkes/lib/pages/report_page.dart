// pages/report_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/models/report_model.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';
import 'package:monitoring_faskes_dinkes/services/export_service.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';
import 'package:flutter/foundation.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  ReportModel? report;
  bool isLoading = true;
  String? errorMessage;
  String selectedPeriod = '7days';

  @override
  void initState() {
    super.initState();
    getReport();
  }

  Future<void> getReport() async {
    // Guard: jangan setState jika sudah dispose
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getReport(period: selectedPeriod);

      if (!mounted) return; // ← cek lagi setelah await

      setState(() {
        report = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint(e.toString());
    }
  }

  Future<void> _handleExport(String format) async {
    // Web
    if (kIsWeb) {
      try {
        await ExportService.downloadAndOpen(
          format: format,
          period: selectedPeriod,
        );
      } catch (e) {
        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      }
      return;
    }

    // Android/iOS/Desktop
    double progress = 0;
    bool isDone = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ExportProgressDialog(
        format: format,
        getProgress: () => progress,
        isDone: () => isDone,
      ),
    );

    try {
      await ExportService.downloadAndOpen(
        format: format,
        period: selectedPeriod,
        onProgress: (p) => progress = p,
      );

      isDone = true;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BFFF),
      bottomNavigationBar: const ReusableBottomNav(selected: 2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00BFFF),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Laporan Ketersediaan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading
    if (isLoading) {
      return const ColoredBox(
        color: Color(0xFFF5F7FB),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Error — report gagal dimuat
    if (errorMessage != null || report == null) {
      return ColoredBox(
        color: const Color(0xFFF5F7FB),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat laporan',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: getReport,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Data tersedia
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 20),
                  _buildChart(),
                  const SizedBox(height: 20),
                  _buildExportCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Periode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(66, 221, 222, 223),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriod,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                items: const [
                  DropdownMenuItem(value: 'today', child: Text('Hari Ini')),
                  DropdownMenuItem(
                    value: '7days',
                    child: Text('7 Hari Terakhir'),
                  ),
                  DropdownMenuItem(
                    value: '30days',
                    child: Text('30 Hari Terakhir'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() => selectedPeriod = value);
                    getReport();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    // report dijamin non-null di sini karena sudah difilter di _buildBody()
    final summary = report!.data.summary;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            "Total Rumah\nSakit",
            summary.totalHospital.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            "Total Fasilitas",
            summary.totalFacility.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            "Rata-rata\nKetersediaan",
            "${summary.averagePercentage}%",
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final graph = report!.data.graph;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(66, 221, 222, 223),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Grafik Ketersediaan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 24),
          // Tampilkan pesan jika data grafik kosong
          if (graph.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Tidak ada data untuk periode ini',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 12,
                      getTooltipItems: (spots) => spots
                          .map(
                            (spot) => LineTooltipItem(
                              "${spot.y.toInt()}%",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 25,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) => Text(
                          "${value.toInt()}%",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= graph.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              graph[index].date,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        graph.length,
                        (i) => FlSpot(
                          i.toDouble(),
                          graph[i].percentage.toDouble(),
                        ),
                      ),
                      isCurved: true,
                      color: const Color(0xFF16A34A),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 3.5,
                              color: const Color(0xFF16A34A),
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF16A34A).withOpacity(0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Ekspor Laporan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFFF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _periodLabel(selectedPeriod),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0077AA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Filter aktif akan diterapkan pada laporan yang diekspor.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  title: "PDF",
                  color: Colors.green,
                  icon: Icons.picture_as_pdf,
                  onTap: () => _handleExport('pdf'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  title: "Excel",
                  color: Colors.blue,
                  icon: Icons.table_chart,
                  onTap: () => _handleExport('excel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  title: "CSV",
                  color: Colors.orange,
                  icon: Icons.description,
                  onTap: () => _handleExport('csv'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _periodLabel(String period) => switch (period) {
    'today' => 'Hari Ini',
    '30days' => '30 Hari',
    _ => '7 Hari',
  };

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(66, 221, 222, 223),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress Dialog ───────────────────────────────────────────────────────────

class _ExportProgressDialog extends StatefulWidget {
  final String format;
  final double Function() getProgress;
  final bool Function() isDone;

  const _ExportProgressDialog({
    required this.format,
    required this.getProgress,
    required this.isDone,
  });

  @override
  State<_ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<_ExportProgressDialog> {
  late final Stream<double> _stream;

  @override
  void initState() {
    super.initState();
    _stream = Stream.periodic(
      const Duration(milliseconds: 150),
      (_) => widget.getProgress(),
    ).takeWhile((_) => !widget.isDone());
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (widget.format) {
      'excel' => 'Excel',
      'csv' => 'CSV',
      _ => 'PDF',
    };

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: StreamBuilder<double>(
        stream: _stream,
        initialData: 0,
        builder: (context, snapshot) {
          final progress = snapshot.data ?? 0;
          final percent = (progress * 100).toInt();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Icon(
                Icons.download_rounded,
                size: 40,
                color: Color(0xFF00BFFF),
              ),
              const SizedBox(height: 16),
              Text(
                "Mengunduh $label...",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF00BFFF),
                ),
              ),
              if (progress > 0) ...[
                const SizedBox(height: 8),
                Text(
                  "$percent%",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
