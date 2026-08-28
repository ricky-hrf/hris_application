import 'package:flutter/material.dart';
import '../../../../profile/domain/entities/profile_entity.dart';

class WorkInfoCard extends StatelessWidget {
  final String department;
  final String position;
  final ScheduleStatusEntity? scheduleToday;
  final ScheduleStatusEntity? scheduleTomorrow;

  const WorkInfoCard({
    super.key,
    required this.department,
    required this.position,
    this.scheduleToday,
    this.scheduleTomorrow,
  });

  static const _teal = Color(0xFF0F5C48);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoTile(icon: Icons.apartment_rounded, label: 'Departemen', value: department),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: _teal.withOpacity(0.10),
              ),
              _InfoTile(icon: Icons.badge_rounded, label: 'Posisi', value: position),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: _teal.withOpacity(0.10), height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ShiftTile(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Shift Hari Ini',
                  isLibur: scheduleToday?.isLibur ?? false,
                  shiftName: scheduleToday?.shiftName,
                  shiftTime: scheduleToday?.shiftTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShiftTile(
                  icon: Icons.event_rounded,
                  label: 'Shift Besok',
                  isLibur: scheduleTomorrow?.isLibur ?? false,
                  shiftName: scheduleTomorrow?.shiftName,
                  shiftTime: scheduleTomorrow?.shiftTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFA9C23F).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF0F5C48), size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF6B8E2F), fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Color(0xFF0F5C48), fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLibur;
  final String? shiftName;
  final String? shiftTime;

  const _ShiftTile({
    required this.icon,
    required this.label,
    required this.isLibur,
    this.shiftName,
    this.shiftTime,
  });

  static const _undetermined = 'Belum ditentukan';
  static const _liburColor = Color(0xFFE0654B);

  @override
  Widget build(BuildContext context) {
    final isSet = shiftName != null && shiftName!.trim().isNotEmpty;

    final String primaryText = isLibur ? 'Libur' : (isSet ? shiftName! : _undetermined);
    final Color primaryColor = isLibur
        ? _liburColor
        : (isSet ? const Color(0xFF0F5C48) : const Color(0xFF0F5C48).withOpacity(0.45));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B8E2F), size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF6B8E2F), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            primaryText,
            style: TextStyle(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontStyle: (!isLibur && !isSet) ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (!isLibur && isSet && shiftTime != null && shiftTime!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              shiftTime!,
              style: const TextStyle(
                color: Color(0xFF6B8E2F),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}