import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/pages/login_page.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_faskes_dinkes/pages/dinkes_list_page.dart';
import 'package:monitoring_faskes_dinkes/pages/user_detail_page.dart';

import '../models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  ProfileModel? profile;

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
            borderRadius: BorderRadius.circular(18),
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
      await prefs.remove("token");
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
        backgroundColor: Color(0xffE8EEF9),
        bottomNavigationBar: ReusableBottomNav(selected: 5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xff0B4A63),
        bottomNavigationBar: ReusableBottomNav(selected: 5),
        body: Center(
          child: Text(
            "Profile gagal dimuat",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final user = profile!.data;

    return Scaffold(
      backgroundColor: const Color(0xff0B4A63),
      bottomNavigationBar: const ReusableBottomNav(selected: 5),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              left: 20,
              right: 20,
              bottom: 28,
            ),
            color: const Color(0xff0B4A63),
            child: Column(
              children: [
                const Text(
                  "Akun",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: const Icon(
                            Icons.local_hospital,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff2E7D32),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.role,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
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

          // ================= MENU (melengkung) =================
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  // ── Group 1: Akun & Data ────────────────────────────
                  _groupCard([
                    _menuTile(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xff0B4A63),
                      iconBg: const Color(0xffE8EEF9),
                      title: "Profil Pengguna",
                      onTap: () {
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetailPage(user: user),
                              ),
                            );
                      },
                    ),
                    _divider(),
                    if (user.role == 'dinkes_utama') ...[
                      _menuTile(
                        icon: Icons.groups_outlined,
                        iconColor: const Color(0xff1565C0),
                        iconBg: const Color(0xffE3F2FD),
                        title: "Profil Dinkes",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DinkesListPage()),
                          );
                        },
                      ),
                    ],
                  ]),

                  const SizedBox(height: 12),

                  // ── Group 2: Preferensi ─────────────────────────────
                  _groupCard([
                    _menuTile(
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xff6D4C41),
                      iconBg: const Color(0xffEFEBE9),
                      title: "Pengaturan",
                      onTap: () {},
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.notifications_none_outlined,
                      iconColor: const Color(0xffE65100),
                      iconBg: const Color(0xffFFF3E0),
                      title: "Notifikasi",
                      badge: "3",
                      onTap: () {},
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xff2E7D32),
                      iconBg: const Color(0xffE8F5E9),
                      title: "Tentang Aplikasi",
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // ── Logout Card ─────────────────────────────────────
                  _groupCard([
                    InkWell(
                      onTap: logout,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                "Keluar",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.red.shade200,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card pembungkus group menu ─────────────────────────────────────────────
  Widget _groupCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }

  // ── Menu tile dengan icon berwarna ─────────────────────────────────────────
  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xffE8EEF9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xff0B4A63),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
