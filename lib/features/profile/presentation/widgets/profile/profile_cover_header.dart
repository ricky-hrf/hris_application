import 'dart:io';
import 'package:flutter/material.dart';

class ProfileCoverHeader extends StatelessWidget {
  final String name;
  final String employeeNumber;
  final String? profession;
  final String? position;
  final String? department;
  final String? photoUrl;
  final File? pickedPhoto;
  final bool isUploadingPhoto;
  final VoidCallback onTapAvatar;

  const ProfileCoverHeader({
    super.key,
    required this.name,
    required this.employeeNumber,
    this.profession,
    this.position,
    this.department,
    this.photoUrl,
    this.pickedPhoto,
    this.isUploadingPhoto = false,
    required this.onTapAvatar,
  });

  static const heroTag = 'profile-avatar-hero';

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;
    if (pickedPhoto != null) {
      avatarImage = FileImage(pickedPhoto!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(photoUrl!);
    } else {
      avatarImage = const AssetImage('assets/images/profil.jpg');
    }

    return Column(
      children: [
        SizedBox(
          height: 128 + 44,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                height: 128,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF042A22),
                      Color(0xFF0F5C48),
                      Color(0xFF1B7A5C),
                    ],
                    stops: [0.0, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 128 - 44,
                child: GestureDetector(
                  onTap: onTapAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Hero(
                      tag: heroTag,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFF7FAF9),
                        backgroundImage: avatarImage,
                        child: isUploadingPhoto
                            ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          ),
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF0F5C48)),
        ),
        const SizedBox(height: 3),
        Text(
          employeeNumber,
          style: TextStyle(fontSize: 12.5, color: const Color(0xFF6B8E2F).withOpacity(0.85), fontWeight: FontWeight.w600),
        ),
        if ((profession != null && profession!.isNotEmpty) || (position != null && position!.isNotEmpty)) ...[
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              if (profession != null && profession!.isNotEmpty) _chip(profession!, filled: true),
              if (position != null && position!.isNotEmpty) _chip(position!, filled: false),
              if (department != null && department!.isNotEmpty) _chip(department!, filled: false),
            ],
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _chip(String text, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF0F5C48) : const Color(0xFF0F5C48).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : const Color(0xFF0F5C48),
        ),
      ),
    );
  }
}