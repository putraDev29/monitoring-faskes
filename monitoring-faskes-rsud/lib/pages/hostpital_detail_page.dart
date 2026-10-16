// pages/hospital_detail_page.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/services/api_service.dart';

import '../models/examination_model.dart';
import '../models/facility_model.dart';
import '../models/hospital_model.dart';

class HostpitalDetailPage extends StatefulWidget {
  final int hospitalId;

  const HostpitalDetailPage({super.key, required this.hospitalId});

  @override
  State<HostpitalDetailPage> createState() => _HostpitalDetailPageState();
}

class _HostpitalDetailPageState extends State<HostpitalDetailPage>
    with SingleTickerProviderStateMixin {
  HospitalDetail? detail;
  List<Examination> examinations = [];

  bool isLoadingDetail = true;
  bool isLoadingExams = true;

  late TabController _tabController;

  // Tinggi area lengkungan TabBar yang overlap ke header
  static const double _tabBarOverlap = 64.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDetail();
    _loadExaminations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final result = await ApiService.getHospitalDetail(widget.hospitalId);
      setState(() {
        detail = result;
        isLoadingDetail = false;
      });
    } catch (e) {
      setState(() => isLoadingDetail = false);
      debugPrint(e.toString());
    }
  }

  Future<void> _loadExaminations() async {
    try {
      final result = await ApiService.getHospitalExaminations(
        widget.hospitalId,
      );
      setState(() {
        examinations = result;
        isLoadingExams = false;
      });
    } catch (e) {
      setState(() => isLoadingExams = false);
      debugPrint(e.toString());
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color getStatusColor(String status) {
    switch (status) {
      case 'tersedia':
      case 'safe':
        return Colors.green;
      case 'terbatas':
      case 'warning':
        return Colors.orange;
      case 'penuh':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'tersedia':
        return 'Tersedia';
      case 'terbatas':
        return 'Terbatas';
      case 'penuh':
        return 'Penuh';
      case 'safe':
        return 'Aman';
      case 'warning':
        return 'Waspada';
      case 'critical':
        return 'Penuh';
      default:
        return status;
    }
  }

  Color getCardColor(String color) {
    switch (color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'cyan':
        return Colors.cyan;
      case 'lime':
        return Colors.lime;
      case 'yellow':
        return Colors.amber;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData getIcon(String icon) {
    switch (icon) {
      case 'baby':
        return Icons.child_care;
      case 'activity':
        return Icons.monitor_heart;
      case 'heart':
        return Icons.favorite;
      case 'stethoscope':
        return Icons.medical_services;
      case 'hospital':
        return Icons.local_hospital;
      case 'home':
        return Icons.home;
      case 'shield':
        return Icons.shield;
      case 'scissors':
        return Icons.content_cut;
      case 'plus':
        return Icons.add;
      default:
        return Icons.medical_information;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoadingDetail) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (detail == null) {
      return _buildError();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildFixedAppBar(),
      body: Column(
        children: [
          // ── Header + TabBar dalam Stack ────────────────────────────────
          // Header diberi padding bawah ekstra sebesar _tabBarOverlap
          // agar TabBar yang overlap tidak menimpa teks header.
          Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Background gradient (header + ruang untuk lengkungan) ──
              Column(
                children: [
                  _buildHospitalHeader(),
                  // Potongan gradient di bawah header sebagai "alas" TabBar
                  Container(
                    height: _tabBarOverlap,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),

              // ── TabBar putih dengan sudut melengkung ──────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildTabBar(),
              ),
            ],
          ),

          // ── Tab content ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFacilitiesTab(),
                _buildExaminationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fixed AppBar ───────────────────────────────────────────────────────────

  PreferredSizeWidget _buildFixedAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF0D47A1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Detail Rumah Sakit",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Hospital Header ────────────────────────────────────────────────────────

  Widget _buildHospitalHeader() {
    final hospital = detail!.hospital;
    final summary = detail!.summary;
    final statusColor = getStatusColor(summary.status);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: hospital.logo != null && hospital.logo!.isNotEmpty
                ? Image.network(
                    hospital.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 14),

          // Name & address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Text(
              getStatusLabel(summary.status),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TabBar ─────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),

          // Tab items
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            indicatorColor: const Color(0xFF0D47A1),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apartment_outlined, size: 18),
                    SizedBox(width: 6),
                    Text("Fasilitas"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services_outlined, size: 18),
                    SizedBox(width: 6),
                    Text("Pemeriksaan"),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  // ── Tab: Fasilitas ─────────────────────────────────────────────────────────

  Widget _buildFacilitiesTab() {
    final facilities = detail!.facilities;

    if (facilities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.apartment_outlined,
        message: "Belum ada data fasilitas",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: facilities.length,
      itemBuilder: (context, index) => _buildFacilityCard(facilities[index]),
    );
  }

  Widget _buildFacilityCard(Facility item) {
    final statusColor = getStatusColor(item.status);
    final cardColor = getCardColor(item.facilityType.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              getIcon(item.facilityType.icon),
              color: cardColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.facilityType.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tersedia ${item.availableUnit} dari ${item.totalUnit}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: item.availableUnit / item.totalUnit,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${item.percentage}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              getStatusLabel(item.status),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab: Pemeriksaan ───────────────────────────────────────────────────────

  Widget _buildExaminationsTab() {
    if (isLoadingExams) {
      return const Center(child: CircularProgressIndicator());
    }

    if (examinations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.medical_services_outlined,
        message: "Belum ada data pemeriksaan",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: examinations.length,
      itemBuilder: (context, index) =>
          _buildExaminationCard(examinations[index]),
    );
  }

  Widget _buildExaminationCard(Examination item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Color(0xFF0D47A1),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.examinationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.doctorName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 13,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${item.openingHours} – ${item.closingHours}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          "Detail Rumah Sakit",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Data tidak ditemukan",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => isLoadingDetail = true);
                _loadDetail();
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper classes ─────────────────────────────────────────────────────────────

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}