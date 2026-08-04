import 'package:flutter/material.dart';
import 'check_time_box.dart';

class PresensiCard extends StatelessWidget {
  final String dateLabel;
  final String clockInTime;
  final String clockOutTime;
  final String statusLabel;

  const PresensiCard({
    super.key,
    required this.dateLabel,
    this.clockInTime = '--:--',
    this.clockOutTime = '--:--',
    this.statusLabel = 'Belum Presensi',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRESENSI HARI INI',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF0C4A6E), size: 18),
              const SizedBox(width: 8),
              Text(
                dateLabel,
                style: const TextStyle(color: Color(0xFF005CB0), fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CheckTimeBox(
                  time: clockInTime,
                  label: 'CHECK IN',
                  icon: Icons.login_rounded,
                  gradientColors: const [Color(0xFFEAEAF6), Color(0xFF83A9F3)],
                  textColor: const Color(0xFF0E2DE8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CheckTimeBox(
                  time: clockOutTime,
                  label: 'CHECK OUT',
                  icon: Icons.logout_rounded,
                  gradientColors: const [Color(0xFFFFEDD5), Color(0xFFFED7AA)],
                  textColor: const Color(0xFF9A3412),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Status: $statusLabel',
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}