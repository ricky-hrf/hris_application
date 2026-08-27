import 'package:flutter/material.dart';

class WorkInfoCard extends StatelessWidget {
  final String department;
  final String position;
  final String? shiftTodayName;
  final String? shiftTodayTime;
  final String? shiftTomorrowName;
  final String? shiftTomorrowTime;

  const WorkInfoCard({
    super.key,
    required this.department,
    required this.position,
    this.shiftTodayName,
    this.shiftTodayTime,
    this.shiftTomorrowName,
    this.shiftTomorrowTime,
  });

  static const _undetermined = 'Belum ditentukan';
  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _lime = Color(0xFFA9C23F);

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
              _InfoTile(
                icon: Icons.apartment_rounded,
                label: 'Departemen',
                value: department,
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: _teal.withOpacity(0.10),
              ),
              _InfoTile(
                icon: Icons.badge_rounded,
                label: 'Posisi',
                value: position,
              ),
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
                  name: shiftTodayName,
                  time: shiftTodayTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShiftTile(
                  icon: Icons.event_rounded,
                  label: 'Shift Besok',
                  name: shiftTomorrowName,
                  time: shiftTomorrowTime,
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
  final String? name;
  final String? time;

  const _ShiftTile({
    required this.icon,
    required this.label,
    this.name,
    this.time,
  });

  static const _undetermined = 'Belum ditentukan';

  @override
  Widget build(BuildContext context) {
    final isSet = name != null && name!.trim().isNotEmpty;

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
            isSet ? name! : _undetermined,
            style: TextStyle(
              color: isSet ? const Color(0xFF0F5C48) : const Color(0xFF0F5C48).withOpacity(0.45),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontStyle: isSet ? FontStyle.normal : FontStyle.italic,
            ),
          ),
          if (isSet && time != null && time!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              time!,
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