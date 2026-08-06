import 'package:flutter/material.dart';

import '../../../presensi/data/datasources/attendance_remote_datasource.dart';
import '../../../presensi/data/repositories/attendance_repository_impl.dart';
import '../../../presensi/domain/entities/attendance_today_entity.dart';
import '../../../presensi/domain/usecases/get_attendance_history_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final GetAttendanceHistoryUseCase _getAttendanceHistoryUseCase;

  bool _isLoading = true;
  String? _errorMessage;
  List<AttendanceTodayEntity> _history = [];

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));

    _getAttendanceHistoryUseCase = GetAttendanceHistoryUseCase(repository);

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _getAttendanceHistoryUseCase();
      if (mounted) setState(() => _history = data);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Gagal memuat riwayat presensi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String workDate) {
    final date = DateTime.parse(workDate);
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'checked_out':
        return Colors.green;
      case 'checked_in':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(AttendanceTodayEntity item) {
    if (item.attendanceStatus != null) return item.attendanceStatus!;
    if (item.status == 'checked_in') return 'Belum Check Out';
    if (item.status == 'checked_out') return 'Selesai';
    return 'Tidak Hadir';
  }

  Widget _defaultPhotoIcon() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey.shade200,
      child: Icon(Icons.person_rounded, color: Colors.grey.shade400, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _loadHistory, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: _history.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Belum ada riwayat presensi',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        )
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _history[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.checkInPhotoUrl != null
                            ? Image.network(
                          item.checkInPhotoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultPhotoIcon(),
                        )
                            : _defaultPhotoIcon(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(item.workDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(item.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel(item),
                                style: TextStyle(
                                  color: _statusColor(item.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeBlock(
                          icon: Icons.login_rounded,
                          label: 'Check In',
                          time: item.checkInTime ?? '--:--',
                          color: Colors.blue,
                          photoUrl: item.checkInPhotoUrl,
                        ),
                      ),
                      Expanded(
                        child: _TimeBlock(
                          icon: Icons.logout_rounded,
                          label: 'Check Out',
                          time: item.checkOutTime ?? '--:--',
                          color: Colors.indigo,
                          photoUrl: item.checkOutPhotoUrl,
                        ),
                      ),
                    ],
                  ),
                  if (item.shiftName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.shiftName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  final String? photoUrl;

  const _TimeBlock({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        photoUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.network(
            photoUrl!,
            width: 18,
            height: 18,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(icon, size: 18, color: color),
          ),
        )
            : Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Text(time, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}