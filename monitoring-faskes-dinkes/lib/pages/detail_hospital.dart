import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/models/examination_model.dart';
import 'package:monitoring_faskes_dinkes/models/hospital_model.dart';
import 'package:monitoring_faskes_dinkes/pages/facilities_page.dart';
import 'package:monitoring_faskes_dinkes/pages/hospital_page.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';

class DetailHospitalPage extends StatefulWidget {
  final DetailHospitalData data;

  const DetailHospitalPage({super.key, required this.data});

  @override
  State<DetailHospitalPage> createState() => _DetailHospitalPageState();
}

class _DetailHospitalPageState extends State<DetailHospitalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Examination> examinations = [];
  bool isLoadingExams = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExaminations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExaminations() async {
    try {
      final result = await ApiService.getHospitalExaminations(
        widget.data.hospital.id,
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
        return Colors.green;
      case 'terbatas':
        return Colors.orange;
      case 'penuh':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusName(String status) {
    switch (status) {
      case 'tersedia':
        return 'Tersedia';
      case 'terbatas':
        return 'Terbatas';
      case 'penuh':
        return 'Penuh';
      default:
        return '';
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
      case 'bed':
        return Icons.bed;
      default:
        return Icons.medical_information;
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
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hospital = widget.data.hospital;
    final summary = widget.data.summary;

    return Scaffold(
      backgroundColor: const Color(0xFF00BFFF),
      bottomNavigationBar: const ReusableBottomNav(selected: 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00BFFF),
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HospitalPage()),
          ),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Rumah Sakit",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // ── HOSPITAL CARD ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 34,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  hospital.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    summary.status,
                                  ).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getStatusName(summary.status).toUpperCase(),
                                  style: TextStyle(
                                    color: getStatusColor(summary.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hospital.address,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── TABBAR ─────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF00BFFF),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFF00BFFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00BFFF).withOpacity(0.3),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.apartment_outlined, size: 16),
                        SizedBox(width: 6),
                        Text("Fasilitas"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_outlined, size: 16),
                        SizedBox(width: 6),
                        Text("Pemeriksaan"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── TAB CONTENT ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFacilitiesTab(), _buildExaminationsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab: Fasilitas ─────────────────────────────────────────────────────────

  Widget _buildFacilitiesTab() {
    final summary = widget.data.summary;
    final hospital = widget.data.hospital;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SUMMARY CARDS
          Row(
            children: [
              Expanded(child: _buildInfoCard("Total Unit", summary.totalUnit)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard("Tersedia", summary.totalAvailable),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            "Persentase Ketersediaan",
            "${summary.percentage}%",
            full: true,
          ),

          const SizedBox(height: 22),

          // TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ringkasan Fasilitas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacilitiesPage(hospital: hospital),
                  ),
                ),
                child: const Text("Lihat Semua"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // GRID
          GridView.builder(
            itemCount: widget.data.facilities.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final item = widget.data.facilities[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: getCardColor(
                          item.facilityType.color,
                        ).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        getIcon(item.facilityType.icon),
                        color: getCardColor(item.facilityType.color),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.facilityType.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${item.percentage}%",
                      style: TextStyle(
                        color: getStatusColor(item.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada data pemeriksaan",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: examinations.length,
      itemBuilder: (context, index) =>
          _buildExaminationCard(examinations[index]),
    );
  }

  Widget _buildExaminationCard(Examination item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Color(0xFF00BFFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // CONTENT
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
                    Icon(
                      Icons.person_outline,
                      size: 13,
                      color: Colors.grey.shade500,
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
                      const Icon(Icons.schedule, size: 13, color: Colors.green),
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

  // ── Info Card ──────────────────────────────────────────────────────────────

  Widget _buildInfoCard(String title, String value, {bool full = false}) {
    return Container(
      width: full ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
