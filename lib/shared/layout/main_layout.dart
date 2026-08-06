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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3053B6),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 12,
          iconSize: 32,
          selectedFontSize: 14,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint_rounded),
              label: 'Presensi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.event_busy_rounded),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 12,
                backgroundImage: _avatarImage,
                backgroundColor: Colors.grey.shade200,
              ),
              activeIcon: CircleAvatar(
                radius: 12,
                backgroundImage: _avatarImage,
                backgroundColor: Colors.grey.shade200,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0E2DE8), width: 2),
                  ),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}