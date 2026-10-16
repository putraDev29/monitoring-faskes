// pages/facilities_page.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/detail_facility_page.dart';
import 'package:monitoring_faskes_rsud/pages/input_facility_form.dart';
import 'package:monitoring_faskes_rsud/services/api_service.dart';
import 'package:monitoring_faskes_rsud/widgets/reusable_bottom_nav.dart';

import '../models/facility_model.dart';

class FacilitiesPage extends StatefulWidget {
  final String initialFilter;

  const FacilitiesPage({super.key, this.initialFilter = "Semua"});

  @override
  State<FacilitiesPage> createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage> {
  List<Facility> facilities = [];
  List<Facility> filteredFacilities = [];

  bool isLoading = true;

  late String selectedFilter;
  String searchQuery = "";

  final List<String> filters = ["Semua", "tersedia", "terbatas", "penuh"];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    getFacilities();
  }

  Future<void> getFacilities() async {
    try {
      final result = await ApiService.getFacilities();
      setState(() {
        facilities = result;
        isLoading = false;
      });
      applyFilter();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  void applyFilter() {
    List<Facility> result = facilities;

    if (selectedFilter != "Semua") {
      result = result.where((item) {
        return item.status.toLowerCase() == selectedFilter.toLowerCase();
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((item) {
        return item.facilityType.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }).toList();
    }

    setState(() => filteredFacilities = result);
  }

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

  Color _filterChipColor(String filter) {
    switch (filter.toLowerCase()) {
      case 'tersedia':
        return Colors.green;
      case 'terbatas':
        return Colors.orange;
      case 'penuh':
        return Colors.red;
      default:
        return const Color(0xFF0D47A1);
    }
  }

  String getStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return 'Tersedia';
      case 'terbatas':
        return 'Terbatas';
      case 'penuh':
        return 'Penuh';
      case 'semua':
        return 'Semua';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── PERUBAHAN 1: backgroundColor diubah ke biru ─────────────────────
      // Sebelum: const Color(0xFFF5F7FB)
      // Sesudah: const Color(0xFF0D47A1)
      // Tujuan: area tepat di bawah AppBar (tempat lengkungan berada)
      // menjadi biru, sehingga container putih yang melengkung kontras.
      backgroundColor: const Color(0xFF0D47A1),
      bottomNavigationBar: const ReusableBottomNav(selected: 2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Daftar Fasilitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputFacilityForm()),
                );
                if (result == true) getFacilities();
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),

      // ── PERUBAHAN 2: body dibungkus Container putih melengkung ──────────
      // Sebelum: body langsung berisi Column(children: [...])
      // Sesudah: body berisi Container dengan borderRadius atas,
      //          lalu di dalamnya baru Column dengan semua konten.
      body: isLoading
          ? const Scaffold(
              // ← bungkus dengan Scaffold putih sementara loading
              backgroundColor: Color(0xFFF5F7FB),
              body: Center(child: CircularProgressIndicator()),
              
            )
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              // ── PERUBAHAN 3: padding top 16 di Column dipindah ke sini ──
              // agar lengkungan tidak terpotong oleh padding lama
              child: Column(
                children: [
                  // ── SEARCH ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        applyFilter();
                      },
                      decoration: InputDecoration(
                        hintText: "Cari fasilitas...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // ── FILTER CHIPS ──────────────────────────────────────────
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = selectedFilter == filter;
                        final chipColor = _filterChipColor(filter);

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedFilter = filter);
                            applyFilter();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? chipColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: chipColor.withOpacity(0.25),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              getStatusName(filter),
                              style: TextStyle(
                                color: isSelected ? Colors.white : chipColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── COUNT BADGE ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${filteredFacilities.length} fasilitas",
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── LIST ──────────────────────────────────────────────────
                  Expanded(
                    child: filteredFacilities.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredFacilities.length,
                            itemBuilder: (context, index) =>
                                _buildCard(filteredFacilities[index]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(Facility item) {
    final statusColor = getStatusColor(item.status);
    final cardColor = getCardColor(item.facilityType.color);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.black.withOpacity(0.05),
        highlightColor: Colors.black.withOpacity(0.08),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailFacilityPage(facility: item),
            ),
          );
          if (result == true) getFacilities();
        },
        child: Container(
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getStatusName(item.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            selectedFilter == "Semua"
                ? "Belum ada data fasilitas"
                : "Tidak ada fasilitas dengan\nstatus \"${getStatusName(selectedFilter)}\"",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          if (selectedFilter != "Semua") ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() => selectedFilter = "Semua");
                applyFilter();
              },
              child: const Text("Tampilkan Semua"),
            ),
          ],
        ],
      ),
    );
  }
}
