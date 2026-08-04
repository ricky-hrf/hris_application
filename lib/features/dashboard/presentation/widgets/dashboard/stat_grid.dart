import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatGrid extends StatelessWidget {
  final int present;
  final int late;
  final int absent;
  final int leave;

  const StatGrid({
    super.key,
    this.present = 0,
    this.late = 0,
    this.absent = 0,
    this.leave = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          StatCard(title: 'Present', value: '$present', color: Colors.green),
          StatCard(title: 'Late', value: '$late', color: Colors.orange),
          StatCard(title: 'Absent', value: '$absent', color: Colors.red),
          StatCard(title: 'Leave', value: '$leave', color: Colors.blue),
        ],
      ),
    );
  }
}