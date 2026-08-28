import 'package:flutter/material.dart';

class QuickMenuItem {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool comingSoon;

  const QuickMenuItem({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.onTap,
    this.comingSoon = false,
  });
}

class QuickMenuGrid extends StatelessWidget {
  final List<QuickMenuItem> items;

  const QuickMenuGrid({super.key, required this.items});

  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _lime = Color(0xFFA9C23F);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
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
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _lime.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.flash_on_rounded, color: _teal, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Akses Cepat',
                style: TextStyle(
                  color: _teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _QuickMenuTile(item: item);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickMenuTile extends StatelessWidget {
  final QuickMenuItem item;

  const _QuickMenuTile({required this.item});

  static const _teal = Color(0xFF0F5C48);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: item.comingSoon
          ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.label} segera hadir')),
        );
      }
          : item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.accentColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: item.accentColor, size: 24),
          ),
          const SizedBox(height: 7),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: item.comingSoon ? _teal.withOpacity(0.45) : _teal,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}