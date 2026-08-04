import 'package:flutter/material.dart';

class LocationBadge extends StatelessWidget {
  final bool isLoading;
  final bool isInRange;
  final int? distanceMeters;
  final int? radiusMeters;

  const LocationBadge({
    super.key,
    required this.isLoading,
    required this.isInRange,
    this.distanceMeters,
    this.radiusMeters,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLoading ? Colors.grey : (isInRange ? Colors.green : Colors.red);
    final label = isLoading
        ? 'Mendeteksi lokasi...'
        : (isInRange
        ? 'Dalam jangkauan (${distanceMeters}m / ${radiusMeters}m)'
        : 'Di luar jangkauan (${distanceMeters}m / ${radiusMeters}m)');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              isInRange ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: color,
              size: 16,
            ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}