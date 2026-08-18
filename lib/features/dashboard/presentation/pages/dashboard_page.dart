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
import '../../../presensi/domain/usecases/get_attendance_history_usecase.dart';
import '../../../leave/data/datasources/leave_remote_datasource.dart';
import '../../../leave/data/repositories/leave_repository_impl.dart';
import '../../../leave/domain/entities/leave_request_entity.dart';
import '../../../leave/domain/usecases/get_my_leave_requests_usecase.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/presensi_card.dart';
import '../widgets/dashboard/stat_grid.dart';
import '../widgets/dashboard/leave_status_card.dart';
import '../widgets/dashboard/shift_schedule_card.dart';
import '../../../presensi/domain/entities/emergency_status_entity.dart';
import '../../../presensi/domain/usecases/get_today_emergency_status_usecase.dart';
import '../widgets/dashboard/emergency_status_card.dart';
import '../../../presensi/presentation/pages/emergency_detail_page.dart';

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
  late final GetMyLeaveRequestsUseCase _getMyLeaveRequestsUseCase;
  late final GetTodayEmergencyStatusUseCase _getTodayEmergencyStatusUseCase;

  bool _isLoading = true;
  AttendanceTodayEntity? _todayAttendance;
  UserEntity? _profile;
  LeaveRequestEntity? _ongoingLeave;
  EmergencyStatusEntity? _emergencyStatus;
  Map<String, int> _statusCounts = {};

  static const _ongoingLeaveStatuses = ['pending'];

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
    final leaveRepository = LeaveRepositoryImpl(LeaveRemoteDataSourceImpl(client));

    _getTodayAttendanceUseCase = GetTodayAttendanceUseCase(attendanceRepository);
    _getProfileUseCase = GetProfileUseCase(authRepository);
    _getAttendanceHistoryUseCase = GetAttendanceHistoryUseCase(attendanceRepository);
    _getMyLeaveRequestsUseCase = GetMyLeaveRequestsUseCase(leaveRepository);
    _getTodayEmergencyStatusUseCase = GetTodayEmergencyStatusUseCase(attendanceRepository);

    _loadData();
  }

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
        _getMyLeaveRequestsUseCase(),
      ]);

      if (mounted) {
        final history = results[2] as List<AttendanceTodayEntity>;
        final leaveRequests = results[3] as List<LeaveRequestEntity>;

        final counts = <String, int>{};
        for (final item in history) {
          if (item.attendanceStatus != null) {
            counts[item.attendanceStatus!] = (counts[item.attendanceStatus!] ?? 0) + 1;
          } else if (item.status == 'checked_in') {
            counts['Belum Checkout'] = (counts['Belum Checkout'] ?? 0) + 1;
          }
        }

        LeaveRequestEntity? ongoing;
        for (final req in leaveRequests) {
          if (_ongoingLeaveStatuses.contains(req.status)) {
            ongoing = req;
            break;
          }
        }

        setState(() {
          _todayAttendance = results[0] as AttendanceTodayEntity?;
          _profile = results[1] as UserEntity;
          _statusCounts = counts;
          _ongoingLeave = ongoing;
        });
      }
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    try {
      final emergency = await _getTodayEmergencyStatusUseCase();
      if (mounted) setState(() => _emergencyStatus = emergency);
    } catch (e) {
      debugPrint('Emergency status load error: $e');
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

  String _leaveStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      default:
        return status;
    }
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
                if (!_isLoading && _ongoingLeave != null) ...[
                  const SizedBox(height: 16),
                  LeaveStatusCard(
                    leaveTypeName: _ongoingLeave!.leaveTypeName,
                    startDate: _ongoingLeave!.startDate,
                    endDate: _ongoingLeave!.endDate,
                    statusLabel: _leaveStatusLabel(_ongoingLeave!.status),
                  ),
                ],
                if (!_isLoading &&
                    _emergencyStatus != null &&
                    _emergencyStatus!.emergencyStatus == 'pending') ...[
                  const SizedBox(height: 16),
                  EmergencyStatusCard(
                    checkedAt: _emergencyStatus!.checkedAt,
                    reason: _emergencyStatus!.emergencyReason,
                    status: _emergencyStatus!.emergencyStatus,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EmergencyDetailPage(checkInId: _emergencyStatus!.id),
                        ),
                      );
                    },
                  ),
                ],
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