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
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));

    _getAttendanceHistoryUseCase = GetAttendanceHistoryUseCase(repository);

    _loadHistory();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadHistory();
  }

  void _goToNextMonth() {
    if (_isCurrentMonth) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      final data = await _getAttendanceHistoryUseCase(
        startDate: _formatIso(firstDay),
        endDate: _formatIso(lastDay),
      );

      if (mounted) setState(() => _history = data);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Gagal memuat riwayat presensi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatIso(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(String workDate) {
    final date = DateTime.parse(workDate);
    return '${_dayNames[date.weekday - 1]}, ${date.day} ${_monthNames[date.month - 1]} ${date.year}';
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
    return item.attendanceStatus ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: _isLoading
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
                      'Belum ada riwayat presensi bulan ini',
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
                itemBuilder: (context, index) => _HistoryCard(
                  item: _history[index],
                  dateLabel: _formatDate(_history[index].workDate),
                  statusColor: _statusColor(_history[index].status),
                  statusLabel: _statusLabel(_history[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            onPressed: _isCurrentMonth ? null : _goToNextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceTodayEntity item;
  final String dateLabel;
  final Color statusColor;
  final String statusLabel;

  const _HistoryCard({
    required this.item,
    required this.dateLabel,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
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
          // Baris 1: hari+tanggal (kiri) & status (kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Baris 2: foto + check in | foto + check out
          Row(
            children: [
              Expanded(
                child: _PhotoTimeBlock(
                  photoUrl: item.checkInPhotoUrl,
                  icon: Icons.login_rounded,
                  label: 'Check In',
                  time: item.checkInTime ?? '--:--',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoTimeBlock(
                  photoUrl: item.checkOutPhotoUrl,
                  icon: Icons.logout_rounded,
                  label: 'Check Out',
                  time: item.checkOutTime ?? '--:--',
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          if (item.shiftName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  item.shiftName!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoTimeBlock extends StatelessWidget {
  final String? photoUrl;
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _PhotoTimeBlock({
    required this.photoUrl,
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: photoUrl != null
              ? Image.network(
            photoUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          )
              : _fallbackIcon(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 44,
      height: 44,
      color: color.withOpacity(0.1),
      child: Icon(icon, size: 20, color: color),
    );
  }
}