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
import '../../../presensi/domain/usecases/get_attendance_history_usecase.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const DashboardPage({super.key, this.onNavigateToProfile});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final GetTodayAttendanceUseCase _getTodayAttendanceUseCase;
  late final GetProfileUseCase _getProfileUseCase;
  late final GetAttendanceHistoryUseCase _getAttendanceHistoryUseCase;

  bool _isLoading = true;
  AttendanceTodayEntity? _todayAttendance;
  UserEntity? _profile;
  int _presentCount = 0;
  int _lateCount = 0;
  int _earlyLeaveCount = 0;
  int _incompleteCount = 0;

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
    _getAttendanceHistoryUseCase = GetAttendanceHistoryUseCase(attendanceRepository);

    _loadData();
  }

  Map<String, int> _statusCounts = {};

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final startDate = firstDayOfMonth.toIso8601String().split('T').first;
      final endDate = now.toIso8601String().split('T').first;

      final results = await Future.wait([
        _getTodayAttendanceUseCase(),
        _getProfileUseCase(),
        _getAttendanceHistoryUseCase(startDate: startDate, endDate: endDate),
      ]);

      if (mounted) {
        final history = results[2] as List<AttendanceTodayEntity>;

        final counts = <String, int>{};
        for (final item in history) {
          if (item.attendanceStatus != null) {
            counts[item.attendanceStatus!] = (counts[item.attendanceStatus!] ?? 0) + 1;
          } else if (item.status == 'checked_in') {
            counts['Belum Checkout'] = (counts['Belum Checkout'] ?? 0) + 1;
          }
        }

        setState(() {
          _todayAttendance = results[0] as AttendanceTodayEntity?;
          _profile = results[1] as UserEntity;
          _statusCounts = counts;
        });
      }
    } catch (_) {
      // biarkan tetap default kalau gagal
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
                StatGrid(counts: _statusCounts),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}