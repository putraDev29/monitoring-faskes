// pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/facilities_page.dart';

import '../config/app_color.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/reusable_bottom_nav.dart';
import '../widgets/stat_card.dart';
import '../widgets/warning_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardModel? dashboard;

  Future<void> getData() async {
    dashboard = await ApiService.getDashboard();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void _goToFacilities({String filter = "Semua"}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FacilitiesPage(initialFilter: filter)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Scaffold = biru agar celah di balik lengkungan
      // content tidak tampak abu-abu
      backgroundColor: const Color(0xFF0D47A1),
      bottomNavigationBar: const ReusableBottomNav(selected: 0),
      body: dashboard == null
          ? const Scaffold(
              // ← bungkus dengan Scaffold putih sementara loading
              backgroundColor: Color(0xFFF5F7FB),
              body: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── HEADER (gradient biru) ───────────────────────────────
                  DashboardHeader(
                    hospitalName: dashboard!.hospital.name,
                    description: dashboard!.hospital.description,
                    status: dashboard!.hospital.status,
                  ),

                  // ── CONTENT AREA (putih, melengkung di atas) ─────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        children: [
                          // ── ROW 1: Total Fasilitas & Total Tersedia ──────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _goToFacilities(),
                                  child: StatCard(
                                    title: "Total Fasilitas",
                                    subtitle: "Jenis",
                                    value: dashboard!.summary.totalFacility,
                                    color: AppColor.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _goToFacilities(filter: "tersedia"),
                                  child: StatCard(
                                    title: "Total Tersedia",
                                    subtitle: "Unit",
                                    value:
                                        dashboard!.summary.totalAvailableUnit,
                                    color: AppColor.green,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ── ROW 2: Tersedia & Terbatas ───────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _goToFacilities(filter: "tersedia"),
                                  child: StatCard(
                                    title: "Tersedia",
                                    subtitle: "Fasilitas",
                                    value: dashboard!.summary.tersedia,
                                    color: AppColor.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _goToFacilities(filter: "terbatas"),
                                  child: StatCard(
                                    title: "Terbatas",
                                    subtitle: "Fasilitas",
                                    value: dashboard!.summary.terbatas,
                                    color: AppColor.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ── ROW 3: Penuh & Persediaan % ─────────────────
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _goToFacilities(filter: "penuh"),
                                  child: StatCard(
                                    title: "Penuh",
                                    subtitle: "Fasilitas",
                                    value: dashboard!.summary.penuh,
                                    color: AppColor.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _goToFacilities(),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.purple.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Persediaan",
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "${dashboard!.summary.percentage}%",
                                          style: const TextStyle(
                                            fontSize: 28,
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        LinearProgressIndicator(
                                          value:
                                              dashboard!.summary.percentage /
                                              100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          color: Colors.purple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── TITLE ALERT ──────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Peringatan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _goToFacilities(),
                                child: const Text("Lihat Semua"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── ALERT LIST ───────────────────────────────────
                          ListView.builder(
                            itemCount: dashboard!.alerts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = dashboard!.alerts[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: WarningCard(
                                  facilityName: item.facilityName,
                                  available: item.available,
                                  total: item.total,
                                  percentage: item.percentage,
                                  status: item.status,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
