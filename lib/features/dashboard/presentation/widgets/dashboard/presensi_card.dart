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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5C48).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF0F5C48), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Presensi Hari Ini',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(
              dateLabel,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: CheckTimeBox(
                  time: clockInTime,
                  label: 'CHECK IN',
                  icon: Icons.login_rounded,
                  gradientColors: const [Color(0xFF6B8E2F), Color(0xFFA9C23F)],
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CheckTimeBox(
                  time: clockOutTime,
                  label: 'CHECK OUT',
                  icon: Icons.logout_rounded,
                  gradientColors: const [Color(0xFF0F5C48), Color(0xFF1B7A5C)],
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8E5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA9C23F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Color(0xFF0F5C48),
                    fontSize: 14,
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