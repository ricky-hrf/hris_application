import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../widgets/profile/profile_form_field.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final UpdateProfileUseCase _updateProfileUseCase;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _placeOfBirthCtrl;
  late final TextEditingController _dateOfBirthCtrl;
  late final TextEditingController _nationalIdCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _maritalStatusCtrl;
  late final TextEditingController _educationLevelCtrl;
  late final TextEditingController _educationMajorCtrl;

  String _gender = 'male';
  File? _pickedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    _updateProfileUseCase = UpdateProfileUseCase(
      ProfileRepositoryImpl(ProfileRemoteDataSourceImpl(client)),
    );

    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p.name);
    _placeOfBirthCtrl = TextEditingController(text: p.placeOfBirth ?? '');
    _dateOfBirthCtrl = TextEditingController(text: p.dateOfBirth ?? '');
    _nationalIdCtrl = TextEditingController(text: p.nationalIdNumber ?? '');
    _addressCtrl = TextEditingController(text: p.address ?? '');
    _phoneCtrl = TextEditingController(text: p.phone ?? '');
    _maritalStatusCtrl = TextEditingController(text: p.maritalStatus ?? '');
    _educationLevelCtrl = TextEditingController(text: p.educationLevel ?? '');
    _educationMajorCtrl = TextEditingController(text: p.educationMajor ?? '');
    _gender = p.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeOfBirthCtrl.dispose();
    _dateOfBirthCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _maritalStatusCtrl.dispose();
    _educationLevelCtrl.dispose();
    _educationMajorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  Future<void> _pickDateOfBirth() async {
    final initial = DateTime.tryParse(_dateOfBirthCtrl.text) ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateOfBirthCtrl.text =
      '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      await _updateProfileUseCase(
        name: _nameCtrl.text.trim(),
        gender: _gender,
        placeOfBirth: _placeOfBirthCtrl.text.trim(),
        dateOfBirth: _dateOfBirthCtrl.text.trim(),
        nationalIdNumber: _nationalIdCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        maritalStatus: _maritalStatusCtrl.text.trim(),
        educationLevel: _educationLevelCtrl.text.trim(),
        educationMajor: _educationMajorCtrl.text.trim(),
        photoPath: _pickedPhoto?.path,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true); // true = beri tahu ProfilePage untuk refresh
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal menyimpan perubahan');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: _pickedPhoto != null
                          ? FileImage(_pickedPhoto!)
                          : (widget.profile.photoUrl != null
                          ? NetworkImage(widget.profile.photoUrl!)
                          : const AssetImage('assets/images/profil.jpg')) as ImageProvider,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0E2DE8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            ProfileFormField(controller: _nameCtrl, label: 'Nama Lengkap'),

            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  filled: true,
                  fillColor: const Color(0xFFF9F9FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
            ),

            ProfileFormField(controller: _placeOfBirthCtrl, label: 'Tempat Lahir'),
            ProfileFormField(
              controller: _dateOfBirthCtrl,
              label: 'Tanggal Lahir (YYYY-MM-DD)',
              readOnly: true,
              onTap: _pickDateOfBirth,
            ),
            ProfileFormField(controller: _nationalIdCtrl, label: 'NIK'),
            ProfileFormField(controller: _addressCtrl, label: 'Alamat', maxLines: 3),
            ProfileFormField(controller: _phoneCtrl, label: 'Telepon'),
            ProfileFormField(controller: _maritalStatusCtrl, label: 'Status Pernikahan'),
            ProfileFormField(controller: _educationLevelCtrl, label: 'Jenjang Pendidikan'),
            ProfileFormField(controller: _educationMajorCtrl, label: 'Jurusan'),

            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E2DE8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}