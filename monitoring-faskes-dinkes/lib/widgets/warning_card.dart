import 'package:flutter/material.dart';

import '../config/app_color.dart';

class WarningCard extends StatelessWidget {
  final String facilityName;
  final int available;
  final int total;
  final double percentage;
  final String status;

  const WarningCard({
    super.key,
    required this.facilityName,
    required this.available,
    required this.total,
    required this.percentage,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.warning_amber_rounded;

    if (status == "penuh") {
      statusColor = AppColor.red;
      statusIcon = Icons.error_outline;
    }

    if (status == "terbatas") {
      statusColor = AppColor.green;
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),

            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          /// ICON
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(statusIcon, color: statusColor),
          ),

          const SizedBox(width: 14),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  facilityName,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Tersedia $available dari $total unit",

                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: LinearProgressIndicator(
                    value: percentage / 100,

                    minHeight: 8,

                    backgroundColor: Colors.grey.shade200,

                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// PERCENTAGE
          Column(
            children: [
              Text(
                "${percentage.toStringAsFixed(0)}%",

                style: TextStyle(
                  color: statusColor,

                  fontWeight: FontWeight.bold,

                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }
}
