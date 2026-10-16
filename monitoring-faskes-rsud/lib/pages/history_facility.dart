// ===========================
// history_facility.dart
// ===========================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_faskes_rsud/models/facility_model.dart';
import 'package:monitoring_faskes_rsud/services/api_service.dart';
import 'package:monitoring_faskes_rsud/widgets/reusable_bottom_nav.dart';

class HistoryFacilityPage extends StatefulWidget {
  const HistoryFacilityPage({super.key});

  @override
  State<HistoryFacilityPage> createState() => _HistoryFacilityPageState();
}

class _HistoryFacilityPageState extends State<HistoryFacilityPage> {
  List<HistoryFacility> histories = [];
  List<HistoryFacility> filteredHistories = [];

  bool isLoading = true;

  String selectedFilter = "Semua";
  String searchQuery = "";

  final List<String> filters = ["Semua", "Hari ini", "7 Hari", "30 Hari"];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ===========================
  // FETCH DATA
  // ===========================

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getHistory();

    setState(() {
      histories = result;
      filteredHistories = result;
      isLoading = false;
    });
  }

  // ===========================
  // FILTER
  // ===========================

  void applyFilter() {
    List<HistoryFacility> temp = [...histories];

    DateTime now = DateTime.now();

    // FILTER DATE
    if (selectedFilter == "Hari ini") {
      temp = temp.where((e) {
        return e.createdAt.day == now.day &&
            e.createdAt.month == now.month &&
            e.createdAt.year == now.year;
      }).toList();
    } else if (selectedFilter == "7 Hari") {
      temp = temp.where((e) {
        return e.createdAt.isAfter(now.subtract(const Duration(days: 7)));
      }).toList();
    } else if (selectedFilter == "30 Hari") {
      temp = temp.where((e) {
        return e.createdAt.isAfter(now.subtract(const Duration(days: 30)));
      }).toList();
    }

    // SEARCH
    if (searchQuery.isNotEmpty) {
      temp = temp.where((e) {
        final facilityName = e.facility?.facilityType.name.toLowerCase() ?? "";

        final description = e.description.toLowerCase();

        final user = e.user.name.toLowerCase();

        return facilityName.contains(searchQuery.toLowerCase()) ||
            description.contains(searchQuery.toLowerCase()) ||
            user.contains(searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredHistories = temp;
    });
  }

  // ===========================
  // CARD COLOR
  // ===========================

  Color getCardColor(String action) {
    switch (action) {
      case "create":
        return Colors.green;

      case "update":
        return Colors.orange;

      case "delete":
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  // ===========================
  // ICON
  // ===========================

  IconData getIcon(String action) {
    switch (action) {
      case "create":
        return Icons.add;

      case "update":
        return Icons.edit;

      case "delete":
        return Icons.delete;

      default:
        return Icons.history;
    }
  }

  // ===========================
  // TIME FORMAT
  // ===========================

  String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // ===========================
  // DATE FORMAT
  // ===========================

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // ===========================
  // HISTORY CARD
  // ===========================

  Widget buildHistoryCard(HistoryFacility item) {
    String facilityName = item.facility?.facilityType.name ?? "Facility";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: getCardColor(item.action).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(getIcon(item.action), color: getCardColor(item.action)),
          ),

          const SizedBox(width: 14),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facilityName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTime(item.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          formatDate(item.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.person, size: 15, color: Colors.grey.shade500),

                    const SizedBox(width: 4),

                    Text(
                      item.user.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // UI
  // ===========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),

      bottomNavigationBar: const ReusableBottomNav(selected: 4),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Riwayat Perubahan",
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: TextField(
                        onChanged: (value) {
                          searchQuery = value;

                          applyFilter();
                        },

                        decoration: InputDecoration(
                          hintText: "Cari riwayat...",

                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),

                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),

                          filled: true,
                          fillColor: Colors.white,

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF0D47A1),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // FILTER
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

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });

                            applyFilter();
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),

                            margin: const EdgeInsets.only(right: 10),

                            padding: const EdgeInsets.symmetric(horizontal: 18),

                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : Colors.white,

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(
                                color: isSelected
                                    ? selectedColor
                                    : selectedColor.withOpacity(0.25),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? selectedColor.withOpacity(0.20)
                                      : Colors.black.withOpacity(0.03),

                                  blurRadius: 8,

                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),

                            alignment: Alignment.center,

                            child: Text(
                              filter,

                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : selectedColor,

                                fontWeight: FontWeight.w600,

                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // LIST
                  Expanded(
                    child: filteredHistories.isEmpty
                        ? const Center(child: Text("Tidak ada riwayat"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),

                            itemCount: filteredHistories.length,

                            itemBuilder: (context, index) {
                              final item = filteredHistories[index];

                              return buildHistoryCard(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
