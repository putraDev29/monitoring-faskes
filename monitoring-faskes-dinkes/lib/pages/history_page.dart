import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_faskes_dinkes/models/history_model.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController searchController = TextEditingController();

  List<HistoryItem> allData = [];
  List<HistoryItem> filteredData = [];

  bool isLoading = true;

  String selectedFacility = "Semua Fasilitas";

  @override
  void initState() {
    super.initState();

    fetchHistory();

    searchController.addListener(() {
      filterLocal();
    });
  }

  // ================= FETCH API =================

  Future<void> fetchHistory() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getHistory(facility: selectedFacility);

    setState(() {
      allData = result;
      filteredData = result;
      isLoading = false;
    });

    filterLocal();
  }

  // ================= FILTER LOCAL =================

  void filterLocal() {
    final keyword = searchController.text.toLowerCase();

    setState(() {
      filteredData = allData.where((item) {
        return item.hospitalName.toLowerCase().contains(keyword) ||
            item.facilityName.toLowerCase().contains(keyword) ||
            item.description.toLowerCase().contains(keyword) ||
            item.updatedBy.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  // ================= FACILITY LIST =================

  List<String> get facilities {
    final list = allData.map((e) => e.facilityName).toSet().toList();

    list.insert(0, "Semua Fasilitas");

    return list;
  }

  // ================= STATUS COLOR =================

  Color getStatusColor(String status) {
    switch (status) {
      case "tersedia":
        return Colors.green;

      case "terbatas":
        return Colors.orange;

      case "penuh":
        return Colors.red;

      case "deleted":
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  // ================= FORMAT DATE =================

  String formatDate(String? date) {
    if (date == null) return "-";

    try {
      final parsed = DateTime.parse(date).toLocal();

      return DateFormat("dd MMM yyyy • HH:mm").format(parsed);
    } catch (e) {
      return "-";
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00BFFF),
      bottomNavigationBar: const ReusableBottomNav(selected: 3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00BFFF),
        automaticallyImplyLeading: false,
        title: const Text(
          "Riwayat Perubahan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),
      body: Container(
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
            // ================= CONTENT =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    // ================= SEARCH =================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(14),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),

                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: searchController,

                        decoration: InputDecoration(
                          hintText: "Cari perubahan...",

                          hintStyle: TextStyle(color: Colors.grey.shade500),

                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color.fromARGB(255, 94, 93, 93),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),

                            borderSide: BorderSide.none,
                          ),

                          filled: true,
                          fillColor: const Color.fromARGB(66, 221, 222, 223),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= LIST =================
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredData.isEmpty
                          ? const Center(child: Text("Data tidak ditemukan"))
                          : RefreshIndicator(
                              onRefresh: fetchHistory,

                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),

                                itemCount: filteredData.length,

                                itemBuilder: (context, index) {
                                  final item = filteredData[index];

                                  return IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        // ================= TIMELINE =================
                                        Column(
                                          children: [
                                            Container(
                                              width: 12,

                                              height: 12,

                                              decoration: BoxDecoration(
                                                color: getStatusColor(
                                                  item.status,
                                                ),

                                                shape: BoxShape.circle,
                                              ),
                                            ),

                                            if (index !=
                                                filteredData.length - 1)
                                              Expanded(
                                                child: Container(
                                                  width: 2,

                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                          ],
                                        ),

                                        const SizedBox(width: 14),

                                        // ================= CARD =================
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 22,
                                            ),

                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                Text(
                                                  "${item.hospitalName} - ${item.facilityName}",

                                                  style: const TextStyle(
                                                    fontSize: 15,

                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  item.description,

                                                  style: TextStyle(
                                                    fontSize: 13,

                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,

                                                      size: 14,

                                                      color:
                                                          Colors.grey.shade500,
                                                    ),

                                                    const SizedBox(width: 4),

                                                    Text(
                                                      formatDate(
                                                        item.createdAt,
                                                      ),

                                                      style: TextStyle(
                                                        fontSize: 12,

                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 4),

                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person,

                                                      size: 14,

                                                      color:
                                                          Colors.grey.shade500,
                                                    ),

                                                    const SizedBox(width: 4),

                                                    Text(
                                                      "Oleh: ${item.updatedBy}",

                                                      style: TextStyle(
                                                        fontSize: 12,

                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
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
