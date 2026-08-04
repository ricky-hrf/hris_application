import 'package:flutter/material.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/presensi_card.dart';
import '../widgets/dashboard/stat_grid.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1E9C), Color(0xFF3395F1)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DashboardHeader(
                name: 'Kopi Kenangan, S.Kom.',
                role: 'Mobile Developer',
              ),
              const SizedBox(height: 16),
              const PresensiCard(
                dateLabel: 'Kamis, 30 Juli 2026',
                clockInTime: '08:00',
                clockOutTime: '--:--',
                statusLabel: 'Hadir',
              ),
              const SizedBox(height: 16),
              const StatGrid(present: 0, late: 0, absent: 0, leave: 0),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}