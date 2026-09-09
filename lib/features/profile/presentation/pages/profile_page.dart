import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../widgets/profile/profile_cover_header.dart';
import '../widgets/profile/profile_section_card.dart';
import '../widgets/profile/profile_detail_row.dart';
import 'profile_section_edit_page.dart';
import '../widgets/profile/photo_viewer_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _teal = Color(0xFF0F5C48);

  late final GetProfileUseCase _getProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final LogoutUseCase _logoutUseCase;

  bool _isLoading = true;
  bool _isLoggingOut = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;
  ProfileEntity? _profile;
  File? _pickedPhotoPreview;

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final profileRepository = ProfileRepositoryImpl(ProfileRemoteDataSourceImpl(client));

    _getProfileUseCase = GetProfileUseCase(profileRepository);
    _updateProfileUseCase = UpdateProfileUseCase(profileRepository);

    _logoutUseCase = LogoutUseCase(
      AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(client),
        localDataSource: AuthLocalDataSourceImpl(storage),
      ),
    );

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _getProfileUseCase();
      setState(() => _profile = profile);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Terjadi kesalahan yang tidak diketahui');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    try {
      await _logoutUseCase();
    } catch (_) {
    } finally {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _previewAvatar() {
    final photoUrl = _profile?.photoUrl;

    final ImageProvider image = (photoUrl != null && photoUrl.isNotEmpty)
        ? NetworkImage(photoUrl)
        : const AssetImage('assets/images/profil.jpg');

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => PhotoViewerPage(
          image: image,
          heroTag: ProfileCoverHeader.heroTag,
          onEdit: _changeAvatar,
        ),
      ),
    );
  }

  Future<void> _changeAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _teal),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _teal),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _pickedPhotoPreview = file;
      _isUploadingPhoto = true;
    });

    try {
      final updated = await _updateProfileUseCase(photoPath: file.path);
      if (mounted) setState(() => _profile = updated);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memperbarui foto profil');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          _pickedPhotoPreview = null;
        });
      }
    }
  }

  Future<void> _openSectionEdit(Widget page) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => page),
    );
    if (result == true) _loadProfile();
  }

  void _editPersonalInfo() {
    final p = _profile!;
    final nameCtrl = TextEditingController(text: p.name);
    final placeOfBirthCtrl = TextEditingController(text: p.placeOfBirth ?? '');
    final dateOfBirthCtrl = TextEditingController(text: p.dateOfBirth ?? '');
    final maritalStatusCtrl = TextEditingController(text: p.maritalStatus ?? '');
    final genderNotifier = ValueNotifier<String>(p.gender == 'female' ? 'female' : 'male');

    _openSectionEdit(
      ProfileSectionEditPage(
        title: 'Informasi Pribadi',
        fields: [
          ProfileEditField.text(key: 'name', label: 'Nama Lengkap', icon: Icons.badge_rounded, controller: nameCtrl),
          ProfileEditField.dropdown(
            key: 'gender',
            label: 'Jenis Kelamin',
            icon: Icons.wc_rounded,
            notifier: genderNotifier,
            options: const {'male': 'Laki-laki', 'female': 'Perempuan'},
          ),
          ProfileEditField.text(key: 'place_of_birth', label: 'Tempat Lahir', icon: Icons.location_city_rounded, controller: placeOfBirthCtrl),
          ProfileEditField.date(
            key: 'date_of_birth',
            label: 'Tanggal Lahir',
            icon: Icons.cake_rounded,
            controller: dateOfBirthCtrl,
            contextGetter: () => context,
          ),
          ProfileEditField.text(key: 'marital_status', label: 'Status Pernikahan', icon: Icons.favorite_rounded, controller: maritalStatusCtrl),
        ],
        onSubmit: (values) async {
          final updated = await _updateProfileUseCase(
            name: values['name'],
            gender: values['gender'],
            placeOfBirth: values['place_of_birth'],
            dateOfBirth: values['date_of_birth'],
            maritalStatus: values['marital_status'],
          );
          if (mounted) setState(() => _profile = updated);
        },
      ),
    );
  }

  void _editContact() {
    final p = _profile!;
    final phoneCtrl = TextEditingController(text: p.phone ?? '');
    final addressCtrl = TextEditingController(text: p.address ?? '');

    _openSectionEdit(
      ProfileSectionEditPage(
        title: 'Kontak',
        fields: [
          ProfileEditField.text(key: 'phone', label: 'Telepon', icon: Icons.phone_rounded, controller: phoneCtrl, keyboardType: TextInputType.phone),
          ProfileEditField.text(key: 'address', label: 'Alamat', icon: Icons.home_rounded, controller: addressCtrl, maxLines: 3),
        ],
        onSubmit: (values) async {
          final updated = await _updateProfileUseCase(
            phone: values['phone'],
            address: values['address'],
          );
          if (mounted) setState(() => _profile = updated);
        },
      ),
    );
  }

  void _editIdentity() {
    final p = _profile!;
    final nikCtrl = TextEditingController(text: p.nationalIdNumber ?? '');

    _openSectionEdit(
      ProfileSectionEditPage(
        title: 'Identitas',
        fields: [
          ProfileEditField.text(key: 'national_id_number', label: 'NIK', icon: Icons.credit_card_rounded, controller: nikCtrl, keyboardType: TextInputType.number),
        ],
        onSubmit: (values) async {
          final updated = await _updateProfileUseCase(nationalIdNumber: values['national_id_number']);
          if (mounted) setState(() => _profile = updated);
        },
      ),
    );
  }

  void _editEducation() {
    final p = _profile!;
    final levelCtrl = TextEditingController(text: p.educationLevel ?? '');
    final majorCtrl = TextEditingController(text: p.educationMajor ?? '');

    _openSectionEdit(
      ProfileSectionEditPage(
        title: 'Pendidikan',
        fields: [
          ProfileEditField.text(key: 'education_level', label: 'Jenjang Pendidikan', icon: Icons.school_rounded, controller: levelCtrl),
          ProfileEditField.text(key: 'education_major', label: 'Jurusan', icon: Icons.menu_book_rounded, controller: majorCtrl),
        ],
        onSubmit: (values) async {
          final updated = await _updateProfileUseCase(
            educationLevel: values['education_level'],
            educationMajor: values['education_major'],
          );
          if (mounted) setState(() => _profile = updated);
        },
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _teal))
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _loadProfile, child: const Text('Coba Lagi')),
              ],
            ),
          ),
        )
            : _profile == null
            ? const SizedBox.shrink()
            : RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                ProfileCoverHeader(
                  name: _profile!.name,
                  employeeNumber: _profile!.employeeNumber,
                  profession: _profile!.profession,
                  position: _profile!.position,
                  department: _profile!.department,
                  photoUrl: _profile!.photoUrl,
                  pickedPhoto: _pickedPhotoPreview,
                  isUploadingPhoto: _isUploadingPhoto,
                  onTapAvatar: _previewAvatar,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      ProfileSectionCard(
                        title: 'Akun',
                        titleIcon: Icons.account_circle_rounded,
                        children: [
                          ProfileDetailRow(icon: Icons.person_rounded, label: 'Username', value: _profile!.username),
                          ProfileDetailRow(icon: Icons.email_rounded, label: 'Email', value: _profile!.email),
                        ],
                      ),
                      ProfileSectionCard(
                        title: 'Kepegawaian',
                        titleIcon: Icons.work_rounded,
                        children: [
                          ProfileDetailRow(icon: Icons.apartment_rounded, label: 'Departemen', value: _profile!.department ?? '-'),
                          ProfileDetailRow(icon: Icons.badge_rounded, label: 'Posisi', value: _profile!.position ?? '-'),
                          ProfileDetailRow(icon: Icons.medical_services_rounded, label: 'Profesi', value: _profile!.profession ?? '-'),
                          ProfileDetailRow(icon: Icons.event_available_rounded, label: 'Tanggal Masuk', value: _formatDate(_profile!.hireDate)),
                          ProfileDetailRow(icon: Icons.verified_rounded, label: 'Status', value: _profile!.isActive ? 'Aktif' : 'Tidak Aktif'),
                        ],
                      ),
                      ProfileSectionCard(
                        title: 'Informasi Pribadi',
                        titleIcon: Icons.person_pin_rounded,
                        onEdit: _editPersonalInfo,
                        children: [
                          ProfileDetailRow(icon: Icons.wc_rounded, label: 'Jenis Kelamin', value: _profile!.gender == 'male' ? 'Laki-laki' : 'Perempuan'),
                          ProfileDetailRow(icon: Icons.location_city_rounded, label: 'Tempat Lahir', value: _profile!.placeOfBirth ?? '-'),
                          ProfileDetailRow(icon: Icons.cake_rounded, label: 'Tanggal Lahir', value: _formatDate(_profile!.dateOfBirth)),
                          ProfileDetailRow(icon: Icons.favorite_rounded, label: 'Status Pernikahan', value: _profile!.maritalStatus ?? '-'),
                        ],
                      ),
                      ProfileSectionCard(
                        title: 'Kontak',
                        titleIcon: Icons.contact_phone_rounded,
                        onEdit: _editContact,
                        children: [
                          ProfileDetailRow(icon: Icons.phone_rounded, label: 'Telepon', value: _profile!.phone ?? '-'),
                          ProfileDetailRow(icon: Icons.home_rounded, label: 'Alamat', value: _profile!.address ?? '-'),
                        ],
                      ),
                      ProfileSectionCard(
                        title: 'Identitas',
                        titleIcon: Icons.credit_card_rounded,
                        onEdit: _editIdentity,
                        children: [
                          ProfileDetailRow(icon: Icons.credit_card_rounded, label: 'NIK', value: _profile!.nationalIdNumber ?? '-'),
                        ],
                      ),
                      ProfileSectionCard(
                        title: 'Pendidikan',
                        titleIcon: Icons.school_rounded,
                        onEdit: _editEducation,
                        children: [
                          ProfileDetailRow(icon: Icons.school_rounded, label: 'Jenjang', value: _profile!.educationLevel ?? '-'),
                          ProfileDetailRow(icon: Icons.menu_book_rounded, label: 'Jurusan', value: _profile!.educationMajor ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isLoggingOut ? null : _handleLogout,
                          icon: _isLoggingOut
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.logout_rounded, color: Colors.redAccent),
                          label: Text(
                            _isLoggingOut ? 'Keluar...' : 'Logout',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}