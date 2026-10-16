import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/models/profile_model.dart';
import 'package:monitoring_faskes_dinkes/services/fcm_service.dart';

import '../config/app_color.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
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
  ProfileModel? profile;

  // final fcm = FCMService();

  Future<void> getData() async {
    dashboard = await ApiService.getDashboard();
    profile = await ApiService.getProfile();
    print("DATA : ${profile!.data.id}");
    // setState(() {
    //   fcm.initFCM(profile!.data.id);
    // });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      bottomNavigationBar: const ReusableBottomNav(selected: 0),

      body: dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                /// BACKGROUND HEADER
                Container(
                  height: 230,
                  decoration: const BoxDecoration(color: Color(0xFF00BFFF)),
                ),

                /// BODY
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// TOP BAR
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),

                          child: Row(
                            children: [
                              const Icon(Icons.menu, color: Colors.white),

                              const SizedBox(width: 14),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Dinas Kesehatan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),

                                    Text(
                                      "Kota Malang",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// WHITE BODY WITH CURVE
                        Container(
                          width: double.infinity,

                          decoration: const BoxDecoration(
                            color: Color(0xffF5F7FB),

                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(18),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                /// PROFILE CARD
                                Container(
                                  padding: const EdgeInsets.all(8),

                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,

                                        child: Image.asset(
                                          'assets/images/logo-dinkes.png',
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.contain,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              getGreeting(),
                                              style: TextStyle(fontSize: 14),
                                            ),

                                            Text(
                                              "Admin Dinkes",

                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,

                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// TITLE
                                Container(
                                  width: double.infinity, // 👈 full lebar
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Ringkasan Ketersediaan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "Update terakhir: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 18),

                                /// GRID CARD
                                GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent:
                                            200, // lebar tiap item
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                        mainAxisExtent:
                                            134, // 👈 ini kunci tinggi fleksibel
                                      ),
                                  children: [
                                    StatCard(
                                      title: "Total RS",
                                      subtitle: "Rumah Sakit",
                                      value: dashboard!.totalHospital,
                                      color: Colors.blue,
                                    ),

                                    StatCard(
                                      title: "Total Fasilitas",
                                      subtitle: "Jenis Fasilitas",
                                      value: dashboard!.summary.totalFacility,
                                      color: Colors.indigo,
                                    ),

                                    StatCard(
                                      title: "Aman",
                                      subtitle: "Fasilitas",
                                      value: dashboard!.summary.tersedia,
                                      color: Colors.green,
                                    ),

                                    StatCard(
                                      title: "Waspada",
                                      subtitle: "Fasilitas",
                                      value: dashboard!.summary.terbatas,
                                      color: Colors.orange,
                                    ),

                                    StatCard(
                                      title: "Kritis",
                                      subtitle: "Fasilitas",
                                      value: dashboard!.summary.penuh,
                                      color: Colors.red,
                                    ),

                                    /// Percentage card
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.04,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Persentase",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          Text(
                                            "${dashboard!.summary.percentage}%",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          const Text(
                                            "Cukup Baik",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: LinearProgressIndicator(
                                              value:
                                                  dashboard!
                                                      .summary
                                                      .percentage /
                                                  100,
                                              minHeight: 7,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 26),

                                /// ALERT TITLE
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    const Text(
                                      "Peringatan Kritis",

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,

                                        fontSize: 16,
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (_) =>
                                        //         const FacilitiesPage(),
                                        //   ),
                                        // );
                                      },

                                      child: const Text("Lihat Semua"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                /// ALERT LIST
                                ListView.builder(
                                  itemCount: dashboard!.criticalAlerts.length,

                                  shrinkWrap: true,

                                  physics: const NeverScrollableScrollPhysics(),

                                  itemBuilder: (context, index) {
                                    final item =
                                        dashboard!.criticalAlerts[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),

                                      child: WarningCard(
                                        facilityName:
                                            "${item.facilityType.name} - ${item.hospital.name}",

                                        available: item.availableUnit,

                                        total: item.totalUnit,

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
                ),
              ],
            ),
    );
  }
}

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return "Selamat Pagi,";
  } else if (hour >= 12 && hour < 15) {
    return "Selamat Siang,";
  } else if (hour >= 15 && hour < 18) {
    return "Selamat Sore,";
  } else {
    return "Selamat Malam,";
  }
}
