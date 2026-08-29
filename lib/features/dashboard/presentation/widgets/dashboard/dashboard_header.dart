import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? profession;
  final String? photoUrl;
  final int spLetterUnreadCount;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.role,
    this.profession,
    this.photoUrl,
    this.spLetterUnreadCount = 0,
    this.onNotificationTap,
  });

  String get _greetingWord {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  IconData get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return Icons.wb_twilight_rounded;
    if (hour >= 11 && hour < 15) return Icons.wb_sunny_rounded;
    if (hour >= 15 && hour < 18) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  String get _firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Pengguna';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAF9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFA9C23F),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF7FAF9),
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl!)
                  : const AssetImage('assets/images/profil.jpg') as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_greetingIcon, color: const Color(0xFF6B8E2F), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$_greetingWord $_firstName,',
                        style: const TextStyle(
                          color: Color(0xFF0F5C48),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (profession != null && profession!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profession!,
                    style: const TextStyle(
                      color: Color(0xFF6B8E2F),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          _NotificationBell(
            unreadCount: spLetterUnreadCount,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onTap;

  const _NotificationBell({required this.unreadCount, this.onTap});

  static const _teal = Color(0xFF0F5C48);
  static const _warn = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.notifications_rounded, color: _teal, size: 20),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: _warn,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF7FAF9), width: 2),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}