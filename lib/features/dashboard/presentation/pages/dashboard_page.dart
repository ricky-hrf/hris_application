import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/get_profile_usecase.dart';
import '../../../presensi/data/datasources/attendance_remote_datasource.dart';
import '../../../presensi/data/repositories/attendance_repository_impl.dart';
import '../../../presensi/domain/entities/attendance_today_entity.dart';
import '../../../presensi/domain/usecases/get_today_attendance_usecase.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/presensi_card.dart';
import '../widgets/dashboard/stat_grid.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const DashboardPage({super.key, this.onNavigateToProfile});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final GetTodayAttendanceUseCase _getTodayAttendanceUseCase;
  late final GetProfileUseCase _getProfileUseCase;

  bool _isLoading = true;
  AttendanceTodayEntity? _todayAttendance;
  UserEntity? _profile;

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);

    final attendanceRepository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(client),
      localDataSource: AuthLocalDataSourceImpl(storage),
    );

    _getTodayAttendanceUseCase = GetTodayAttendanceUseCase(attendanceRepository);
    _getProfileUseCase = GetProfileUseCase(authRepository);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _getTodayAttendanceUseCase(),
        _getProfileUseCase(),
      ]);

      if (mounted) {
        setState(() {
          _todayAttendance = results[0] as AttendanceTodayEntity?;
          _profile = results[1] as UserEntity;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _dateLabel {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get _statusLabel {
    if (_todayAttendance == null) return 'Belum Presensi';

    final apiStatus = _todayAttendance!.attendanceStatus;
    if (apiStatus != null) return apiStatus;

    if (_todayAttendance!.status == 'checked_in') return 'Sedang Bekerja';
    if (_todayAttendance!.status == 'checked_out') return 'Menunggu Penentuan Status';

    return 'Belum Presensi';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1E9C), Color(0xFF3395F1)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                DashboardHeader(
                  name: _profile?.name ?? _profile?.username ?? '-',
                  role: _profile?.position ?? _profile?.employmentStatus ?? 'Karyawan',
                  photoUrl: _profile?.photoUrl,
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : PresensiCard(
                  dateLabel: _dateLabel,
                  clockInTime: _todayAttendance?.checkInTime ?? '--:--',
                  clockOutTime: _todayAttendance?.checkOutTime ?? '--:--',
                  statusLabel: _statusLabel,
                ),
                const SizedBox(height: 16),
                const StatGrid(present: 0, late: 0, absent: 0, leave: 0),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}