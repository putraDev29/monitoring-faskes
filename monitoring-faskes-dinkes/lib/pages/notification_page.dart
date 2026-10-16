import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/widgets/reusable_bottom_nav.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = true;

  List<NotificationModel> notifications = [];
  List<NotificationModel> filteredNotifications = [];

  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  Future<void> getNotifications() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result = await ApiService.getNotifications('all');

      if (!mounted) return;

      setState(() {
        notifications = result;
        filteredNotifications = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  void applyFilter() {
    if (selectedFilter == 'all') {
      filteredNotifications = notifications;
    } else if (selectedFilter == 'read') {
      filteredNotifications = notifications
          .where((e) => e.isRead == true)
          .toList();
    } else if (selectedFilter == 'unread') {
      filteredNotifications = notifications
          .where((e) => e.isRead == false)
          .toList();
    }

    setState(() {});
  }

  void markAsRead(int id) {
    notifications = notifications.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00BFFF),
      bottomNavigationBar: const ReusableBottomNav(selected: 4),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00BFFF),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Notifikasi",
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
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton(title: 'Semua', value: 'all'),
                _filterButton(title: 'Sudah Dibaca', value: 'read'),
                _filterButton(title: 'Belum Dibaca', value: 'unread'),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final item = filteredNotifications[index];

                        return GestureDetector(
                          onTap: () async {
                            if (!item.isRead) {
                              await ApiService.readNotification(item.id);

                              setState(() {
                                markAsRead(item.id);
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? Colors.white
                                  : Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _getColor(
                                      item.type,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIcon(item.type),
                                    color: _getColor(item.type),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontWeight: item.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.message,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  item.createdAt.substring(11, 16),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
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

  Widget _filterButton({required String title, required String value}) {
    final selected = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });

        applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(color: selected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'critical':
        return Icons.warning;
      case 'warning':
        return Icons.notifications_active;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
