import 'package:flutter/material.dart';
import 'package:hris_application/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hris_application/features/history/presentation/pages/history_page.dart';
import 'package:hris_application/features/presensi/presentation/pages/presensi_page.dart';
import 'package:hris_application/features/leave/presentation/pages/leave_page.dart';
import 'package:hris_application/features/profile/presentation/pages/profile_page.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/usecases/get_profile_usecase.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  String? _profilePhotoUrl;

  final List<Widget> _pages = const [
    DashboardPage(),
    HistoryPage(),
    PresensiPage(),
    LeavePage(),
    ProfilePage(),
  ];

  static const _primaryColor = Color(0xFF0F5C48);
  static const _accentColor = Color(0xFFA9C23F);

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(client),
      localDataSource: AuthLocalDataSourceImpl(storage),
    );
    final getProfileUseCase = GetProfileUseCase(authRepository);

    try {
      final profile = await getProfileUseCase();
      if (mounted) setState(() => _profilePhotoUrl = profile.photoUrl);
    } catch (_) {
      // biarkan null, fallback ke asset default
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  ImageProvider get _avatarImage {
    if (_profilePhotoUrl != null) {
      return NetworkImage(_profilePhotoUrl!);
    }
    return const AssetImage('assets/images/profil.jpg');
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? _primaryColor : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem() {
    final isSelected = _selectedIndex == 4;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundImage: _avatarImage,
              backgroundColor: Colors.grey.shade200,
              child: isSelected
                  ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryColor, width: 2),
                ),
              )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                  _buildNavItem(icon: Icons.history_rounded, label: 'History', index: 1),
                  const Expanded(child: SizedBox()), // ruang kosong untuk tombol presensi
                  _buildNavItem(icon: Icons.event_busy_rounded, label: 'Leave', index: 3),
                  _buildProfileItem(),
                ],
              ),
            ),
          ),
          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_accentColor, _primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Presensi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedIndex == 2 ? FontWeight.w700 : FontWeight.w500,
                      color: _selectedIndex == 2 ? _primaryColor : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}