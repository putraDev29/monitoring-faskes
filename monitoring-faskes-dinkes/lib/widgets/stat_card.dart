import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
  });

  IconData get icon {
    switch (title.toLowerCase()) {
      case "total rs":
        return Icons.local_hospital_outlined;

      case "total fasilitas":
        return Icons.grid_view_rounded;

      case "aman":
        return Icons.verified_user_outlined;

      case "waspada":
        return Icons.warning_amber_rounded;

      case "kritis":
        return Icons.error_outline_rounded;

      default:
        return Icons.bar_chart_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: color.withOpacity(0.08),

          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: color.withOpacity(0.12),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [
            /// TITLE
            Text(
              title,

              style: TextStyle(
                fontSize: 13,

                fontWeight: FontWeight.w600,

                color: color.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 12),

            /// VALUE
            Text(
              "$value",

              style: TextStyle(
                fontSize: 20,

                height: 1,

                fontWeight: FontWeight.bold,

                color: color,
              ),
            ),

            const SizedBox(height: 10),

            /// BOTTOM
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Expanded(
                  child: Text(
                    subtitle,

                    style: TextStyle(
                      fontSize: 12,

                      fontWeight: FontWeight.w500,

                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                Container(
                  width: 34,
                  height: 34,

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    icon,

                    color: color,

                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}