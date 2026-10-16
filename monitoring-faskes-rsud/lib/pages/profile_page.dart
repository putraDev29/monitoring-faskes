import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/login_page.dart';
import 'package:monitoring_faskes_rsud/services/api_service.dart';
import 'package:monitoring_faskes_rsud/widgets/reusable_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';
import 'hospital_profile_page.dart';
import 'admin_list_page.dart';
import 'user_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  ProfileResponse? profile;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final result = await ApiService.getProfile();
      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Keluar"),
          content: const Text("Apakah yakin ingin keluar dari aplikasi?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        bottomNavigationBar: ReusableBottomNav(selected: 6),
        backgroundColor: Color(0xFFF5F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        bottomNavigationBar: ReusableBottomNav(selected: 6),
        body: Center(child: Text('Data profile gagal dimuat')),
      );
    }

    final hospital = profile!.data.hospital;
    final user = profile!.data.user;

    return Scaffold(
      // Background biru agar celah lengkungan tidak abu-abu
      backgroundColor: const Color(0xFF0D47A1),
      bottomNavigationBar: const ReusableBottomNav(selected: 6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER (biru, tidak melengkung) ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 65,
                left: 20,
                right: 20,
                bottom: 28,
              ),
              decoration: const BoxDecoration(color: Color(0xFF0D47A1)),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: hospital.logo != null
                        ? ClipOval(
                            child: Image.network(
                              hospital.logo!,
                              fit: BoxFit.cover,
                              width: 84,
                              height: 84,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.local_hospital,
                                    size: 42,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.local_hospital,
                            size: 42,
                            color: Colors.grey,
                          ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    hospital.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    hospital.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: hospital.status == 'online'
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hospital.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENT AREA (putih, melengkung di atas) ────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // ── MENU LIST ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _menuCard(
                          icon: Icons.local_hospital,
                          title: "Profil Rumah Sakit",
                          subtitle: "Informasi detail rumah sakit",
                          color: const Color(0xFF1565C0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HospitalDetailPage(hospital: hospital),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        if (user.role == 'admin_utama') ...[
                          _menuCard(
                            icon: Icons.people_alt_outlined,
                            title: "Profile Admin",
                            subtitle: "Informasi akun Admin",
                            color: const Color(0xFF7B1FA2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminListPage(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 14),
                        ],

                        _menuCard(
                          icon: Icons.people_alt_outlined,
                          title: "Pengguna",
                          subtitle: "Informasi akun pengguna",
                          color: const Color(0xFF7B1FA2),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetailPage(user: user),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        _menuCard(
                          icon: Icons.info_outline,
                          title: "Tentang Aplikasi",
                          subtitle: "Informasi aplikasi monitoring",
                          color: const Color(0xFF00897B),
                          onTap: () {},
                        ),

                        const SizedBox(height: 14),

                        _menuCard(
                          icon: Icons.help_outline,
                          title: "Bantuan",
                          subtitle: "Pusat bantuan aplikasi",
                          color: const Color(0xFFFF9800),
                          onTap: () {},
                        ),

                        const SizedBox(height: 14),

                        _menuCard(
                          icon: Icons.logout,
                          title: "Keluar",
                          subtitle: "Keluar dari akun aplikasi",
                          color: Colors.red,
                          onTap: logout,
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}
