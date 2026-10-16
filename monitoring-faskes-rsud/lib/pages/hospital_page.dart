// pages/hospitals_page.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/hostpital_detail_page.dart';
import 'package:monitoring_faskes_rsud/services/api_service.dart';
import 'package:monitoring_faskes_rsud/widgets/reusable_bottom_nav.dart';

import '../models/hospital_model.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  List<HospitalList> hospitals = [];
  List<HospitalList> filteredHospitals = [];

  bool isLoading = true;
  String selectedFilter = "Semua";
  String searchQuery = "";

  final List<String> filters = ["Semua", "tersedia", "terbatas", "penuh"];

  @override
  void initState() {
    super.initState();
    getHospitals();
  }

  Future<void> getHospitals() async {
    try {
      final result = await ApiService.getHospitals();
      setState(() {
        hospitals = result;
        filteredHospitals = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  void applyFilter() {
    List<HospitalList> result = hospitals;

    if (selectedFilter != "Semua") {
      result = result
          .where((h) => h.status.toLowerCase() == selectedFilter.toLowerCase())
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result
          .where(
            (h) =>
                h.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                h.address.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    setState(() => filteredHospitals = result);
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

  String getStatusLabel(String status) {
    switch (status) {
      case 'tersedia':
        return 'Tersedia';
      case 'terbatas':
        return 'Terbatas';
      case 'penuh':
        return 'Penuh';
      default:
        return 'Semua';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      bottomNavigationBar: const ReusableBottomNav(selected: 1),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Daftar Rumah Sakit",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

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
                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        applyFilter();
                      },
                      decoration: InputDecoration(
                        hintText: "Cari rumah sakit...",
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

                  // FILTER CHIPS
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = selectedFilter == filter;

                        Color selectedColor = const Color(0xFF0D47A1);
                        if (filter == "tersedia") {
                          selectedColor = Colors.green;
                        } else if (filter == "terbatas") {
                          selectedColor = Colors.orange;
                        } else if (filter == "penuh") {
                          selectedColor = Colors.red;
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedFilter = filter);
                            applyFilter();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedColor.withOpacity(0.25),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              getStatusLabel(filter),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : selectedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LIST
                  Expanded(
                    child: filteredHospitals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_hospital_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Tidak ada rumah sakit ditemukan",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredHospitals.length,
                            itemBuilder: (context, index) {
                              final item = filteredHospitals[index];
                              return _buildCard(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(HospitalList item) {
    final statusColor = getStatusColor(item.status);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.black.withOpacity(0.05),
        highlightColor: Colors.black.withOpacity(0.08),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HostpitalDetailPage(hospitalId: item.id),
            ),
          );
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
              // LOGO / ICON
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.logo != null && item.logo!.isNotEmpty
                    ? Image.network(
                        item.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_hospital,
                          color: Color(0xFF0D47A1),
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.local_hospital,
                        color: Color(0xFF0D47A1),
                        size: 28,
                      ),
              ),
              const SizedBox(width: 14),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.address,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // PROGRESS BAR
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: item.percentage / 100,
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

              // STATUS BADGE
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
                  getStatusLabel(item.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ARROW
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
