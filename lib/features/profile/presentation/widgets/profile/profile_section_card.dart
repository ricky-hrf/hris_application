import 'package:flutter/material.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final List<Widget> children;
  final VoidCallback? onEdit;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.children,
    this.onEdit,
  });

  static const _teal = Color(0xFF0F5C48);
  static const _lime = Color(0xFFA9C23F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: _teal.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, color: _teal, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _teal),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _lime.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 15, color: _teal),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}