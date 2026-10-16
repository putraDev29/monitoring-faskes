import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/pages/detail_hospital.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';

import '../models/hospital_model.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({super.key});

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  List<HospitalData> hospitals = [];
  List<HospitalData> filteredHospitals = [];

  bool isLoading = true;

  String searchQuery = "";

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
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  void applySearch() {
    List<HospitalData> result = hospitals;

    if (searchQuery.isNotEmpty) {
      result = result.where((item) {
        return item.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredHospitals = result;
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
    switch (status.toLowerCase()) {
      case 'tersedia':
        return 'Tersedia';

      case 'terbatas':
        return 'Terbatas';

      case 'penuh':
        return 'Penuh';

      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00BFFF),

      bottomNavigationBar: const ReusableBottomNav(selected: 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00BFFF),
        automaticallyImplyLeading: false,
        title: const Text(
          "Daftar Fasilitas",
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
            /// HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),

              child: Column(
                children: [
                  /// SEARCH
                  Container(
                    height: 48,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        applySearch();
                      },

                      style: const TextStyle(color: Colors.black),

                      decoration: InputDecoration(
                        hintText: "Cari rumah sakit...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),

                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),

                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          253,
                          253,
                          253,
                        ), // 👈 background abu-abu

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300, // 👈 border normal
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade500, // 👈 border saat focus
                            width: 1.2,
                          ),
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),

                      itemCount: filteredHospitals.length,
                      itemBuilder: (context, index) {
                        final item = filteredHospitals[index];

                        return GestureDetector(
                          onTap: () async {
                            // 🔥 SHOW LOADING DIALOG (VISIBLE)
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors
                                  .black54, // 👈 biar kelihatan overlay gelap
                              builder: (context) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                            );

                            try {
                              final detail = await ApiService.getDetailHospital(
                                item.id,
                              );

                              // 🔥 pastikan loading ditutup dulu
                              if (context.mounted) Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailHospitalPage(data: detail.data),
                                ),
                              );
                            } catch (e) {
                              if (context.mounted) Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal memuat data: $e"),
                                ),
                              );
                            }
                          },

                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),

                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(20),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),

                                  blurRadius: 10,

                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                /// IMAGE
                                Container(
                                  width: 56,
                                  height: 56,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),

                                    color: Colors.blue.withOpacity(0.08),
                                  ),

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),

                                    child: item.logo != null
                                        ? Image.network(
                                            item.logo!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.local_hospital,
                                            color: Color(0xFF0D47A1),
                                            size: 30,
                                          ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                /// CONTENT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,

                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            margin: const EdgeInsets.only(
                                              top: 23,
                                            ),

                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                item.status,
                                              ).withOpacity(0.12),

                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),

                                            child: Text(
                                              getStatusName(
                                                item.status,
                                              ).toUpperCase(),

                                              style: TextStyle(
                                                color: getStatusColor(
                                                  item.status,
                                                ),

                                                fontWeight: FontWeight.bold,

                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        item.address.isEmpty
                                            ? "Malang, Kota Malang"
                                            : item.address,

                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),

                                              child: LinearProgressIndicator(
                                                value: item.percentage / 100,

                                                minHeight: 8,

                                                backgroundColor:
                                                    Colors.grey.shade200,

                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      getStatusColor(
                                                        item.status,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Text(
                                            "${item.percentage}%",

                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,

                                              fontSize: 13,
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
