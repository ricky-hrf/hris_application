import 'package:flutter/material.dart';
import '../../../domain/entities/profile_entity.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileEntity profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : const AssetImage('assets/images/profil.jpg') as ImageProvider,
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            profile.employeeNumber,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _row('Username', profile.username),
          _row('Email', profile.email),
          _row('Jenis Kelamin', profile.gender == 'male' ? 'Laki-laki' : 'Perempuan'),
          _row('Tempat Lahir', profile.placeOfBirth),
          _row('Tanggal Lahir', profile.dateOfBirth),
          _row('NIK', profile.nationalIdNumber),
          _row('Alamat', profile.address),
          _row('Telepon', profile.phone),
          _row('Status Nikah', profile.maritalStatus),
          _row('Pendidikan', profile.educationLevel),
          _row('Jurusan', profile.educationMajor),
          _row('Tanggal Masuk', profile.hireDate),
          _row('Status', profile.isActive ? 'Aktif' : 'Tidak Aktif'),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}