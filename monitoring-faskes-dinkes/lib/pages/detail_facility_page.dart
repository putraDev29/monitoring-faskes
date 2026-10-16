// pages/detail_facility_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_faskes_dinkes/models/facility_model.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';

class DetailFacilityPage extends StatefulWidget {
  final int hospitalId;
  final int facilityId;

  const DetailFacilityPage({
    super.key,
    required this.hospitalId,
    required this.facilityId,
  });

  @override
  State<DetailFacilityPage> createState() => _DetailFacilityPageState();
}

class _DetailFacilityPageState extends State<DetailFacilityPage> {
  DetailFacilityData? data;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDetail();
  }

  Future<void> getDetail() async {
    try {
      final result = await ApiService.getDetailFacility(
        hospitalId: widget.hospitalId,
        facilityId: widget.facilityId,
      );

      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
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

  String getIconAsset(String icon) {
    switch (icon) {
      case 'IGD':
        return 'assets/icons/IGD.png';

      case 'ICU':
        return 'assets/icons/ICU.png';

      case 'ICCI':
        return 'assets/icons/ICCI.png';

      case 'PICU':
        return 'assets/icons/PICU.png';

      case 'NICU':
        return 'assets/icons/NICU.png';

      case 'VENTI DEWASA':
        return 'assets/icons/VENTI_DEWASA.png';

      case 'VENTI ANAK':
        return 'assets/icons/VENTI_ANAK.png';

      case 'HCU':
        return 'assets/icons/HCU.png';

      case 'CPAP':
        return 'assets/icons/CPAP.png';

      case 'RESUSITATOR KID':
        return 'assets/icons/RESUSITATOR_KID.png';

      default:
        return 'assets/icons/CVCU.png';
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

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return DateFormat('dd MMM yyyy HH:mm').format(parsed);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        bottomNavigationBar: const ReusableBottomNav(selected: 1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        backgroundColor: const Color(0xffF5F7FB),
        bottomNavigationBar: const ReusableBottomNav(selected: 1),
        body: Center(child: Text("Data tidak ditemukan")),
      );
    }

    final facility = data!.facility;

    return Scaffold(
      backgroundColor: Color(0xFF00BFFF),
      bottomNavigationBar: const ReusableBottomNav(selected: 1),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF00BFFF),

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),

        centerTitle: true,

        title: const Text(
          "Detail Fasilitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                children: [
                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,

                          decoration: BoxDecoration(
                            color: getCardColor(
                              facility.facilityType.color,
                            ).withOpacity(0.12),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Image.asset(
                            getIconAsset(facility.facilityType.name),
                            width: 24,
                            height: 24,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      facility.facilityType.name,

                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),

                                    decoration: BoxDecoration(
                                      color: getStatusColor(
                                        facility.status,
                                      ).withOpacity(0.12),

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Text(
                                      getStatusName(facility.status),

                                      style: TextStyle(
                                        color: getStatusColor(facility.status),

                                        fontWeight: FontWeight.bold,

                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              Text(
                                data!.hospital.name,

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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    /// PROGRESS CARD
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Column(
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,

                            child: Stack(
                              alignment: Alignment.center,

                              children: [
                                SizedBox(
                                  width: 180,
                                  height: 180,

                                  child: CircularProgressIndicator(
                                    value: facility.totalUnit == 0
                                        ? 0
                                        : facility.availableUnit /
                                              facility.totalUnit,

                                    strokeWidth: 14,

                                    backgroundColor: Colors.grey.shade200,

                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      getStatusColor(facility.status),
                                    ),
                                  ),
                                ),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Text(
                                      "${facility.percentage}%",

                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    const Text(
                                      "Tersedia",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          buildInfo(
                            "Total Unit",
                            facility.totalUnit.toString(),
                            Colors.blue,
                          ),

                          buildInfo(
                            "Tersedia",
                            facility.availableUnit.toString(),
                            Colors.green,
                          ),

                          buildInfo(
                            "Terpakai",
                            facility.usedUnit.toString(),
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// HISTORY
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Riwayat Perubahan (7 Hari terakhir)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 16),

                          ListView.builder(
                            itemCount: data!.histories.length,

                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            itemBuilder: (context, index) {
                              final item = data!.histories[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),

                                padding: const EdgeInsets.all(14),

                                decoration: BoxDecoration(
                                  color: const Color(0xffF8FAFC),

                                  borderRadius: BorderRadius.circular(18),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,

                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                              item.afterStatus,
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            item.description,

                                            style: const TextStyle(
                                              fontSize: 13,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      formatDate(item.createdAt),

                                      style: TextStyle(
                                        color: Colors.grey.shade600,

                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Oleh: ${item.user.name}",

                                      style: TextStyle(
                                        color: Colors.grey.shade600,

                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
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

  Widget buildInfo(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,

            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(child: Text(title)),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
