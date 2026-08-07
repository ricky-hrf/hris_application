import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatGrid extends StatelessWidget {
  final Map<String, int> counts;

  const StatGrid({super.key, required this.counts});

  static const List<Color> _palette = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.blue,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
  ];


  @override
  Widget build(BuildContext context) {
    final entries = counts.entries.toList();

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          return StatCard(
            title: entry.key,
            value: '${entry.value}',
            color: _palette[index % _palette.length],
          );
        }),
      ),
    );
  }
}