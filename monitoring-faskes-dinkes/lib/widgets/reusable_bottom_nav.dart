import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/config/app_color.dart';
import 'package:monitoring_faskes_dinkes/pages/dashboard_page.dart';
import 'package:monitoring_faskes_dinkes/pages/history_page.dart';
import 'package:monitoring_faskes_dinkes/pages/hospital_page.dart';
import 'package:monitoring_faskes_dinkes/pages/notification_page.dart';
import 'package:monitoring_faskes_dinkes/pages/profile_page.dart';
import 'package:monitoring_faskes_dinkes/pages/report_page.dart';
import 'package:monitoring_faskes_dinkes/services/api_service.dart';

class ReusableBottomNav extends StatefulWidget {
  final int selected;

  const ReusableBottomNav({super.key, required this.selected});

  @override
  State<ReusableBottomNav> createState() => _ReusableBottomNavState();
}

class _ReusableBottomNavState extends State<ReusableBottomNav> {
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    getUnreadNotificationCount();
  }

  Future<void> getUnreadNotificationCount() async {
    if (!mounted) return;

    try {
      final result = await ApiService.getUnreadNotificationCount();

      if (!mounted) return;

      setState(() {
        unreadCount = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void onItemTapped(BuildContext context, int index) {
    if (index == widget.selected) return;

    Widget page;

    switch (index) {
      case 0:
        page = const DashboardPage();
        break;

      case 1:
        page = const HospitalPage();
        break;

      case 2:
        page = const ReportPage();
        break;

      case 3:
        page = const HistoryPage();
        break;

      case 4:
        page = const NotificationPage();
        break;

      case 5:
        page = const ProfilePage();
        break;

      default:
        page = const DashboardPage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selected,

      selectedItemColor: const Color(0xFF00BFFF),
      unselectedItemColor: Colors.grey,

      type: BottomNavigationBarType.fixed,

      onTap: (index) => onItemTapped(context, index),

      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: "RS",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: "Laporan",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "Riwayat",
        ),

        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),

              if (unreadCount > 0)
                Positioned(
                  right: -6,
                  top: -2,

                  child: Container(
                    padding: const EdgeInsets.all(4),

                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),

                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),

                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          label: "Notif",
        ),

        const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
      ],
    );
  }
}
