import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/schedule_remote_datasource.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/entities/schedule_day_entity.dart';
import '../../domain/usecases/get_my_schedule_usecase.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _lime = Color(0xFFA9C23F);
  static const _cream = Color(0xFFF7FAF9);

  late final GetMyScheduleUseCase _getMyScheduleUseCase;

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isLoading = true;
  String? _error;
  List<ScheduleDayEntity> _days = [];

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = ScheduleRepositoryImpl(ScheduleRemoteDataSourceImpl(client));
    _getMyScheduleUseCase = GetMyScheduleUseCase(repository);

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final days = await _getMyScheduleUseCase(
        year: _visibleMonth.year,
        month: _visibleMonth.month,
      );
      if (mounted) setState(() => _days = days);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
    _load();
  }

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _teal,
        title: const Text('Jadwal Shift', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: _teal),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    style: const TextStyle(color: _teal, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: _teal),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _teal))
                  : _error != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _days.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _DayTile(day: _days[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final ScheduleDayEntity day;

  const _DayTile({required this.day});

  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _lime = Color(0xFFA9C23F);

  static const _dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  bool get _isToday {
    final now = DateTime.now();
    return day.date.year == now.year && day.date.month == now.month && day.date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final dayName = _dayNames[day.date.weekday - 1];
    final isWeekend = day.date.weekday == DateTime.saturday || day.date.weekday == DateTime.sunday;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (day.isLibur) {
      statusText = 'Libur';
      statusColor = const Color(0xFFE0654B);
      statusIcon = Icons.beach_access_rounded;
    } else if (day.shift == null) {
      statusText = 'Belum diatur';
      statusColor = Colors.grey.shade400;
      statusIcon = Icons.help_outline_rounded;
    } else {
      statusText = day.shift!.name;
      statusColor = _teal;
      statusIcon = Icons.wb_sunny_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _isToday ? Border.all(color: _lime, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: _teal.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Text(
                  '${day.date.day}',
                  style: const TextStyle(color: _teal, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  dayName.substring(0, 3),
                  style: TextStyle(
                    color: isWeekend ? const Color(0xFFE0654B) : _olive,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 34, color: _teal.withOpacity(0.08), margin: const EdgeInsets.symmetric(horizontal: 12)),
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                if (day.shift?.startTime != null && day.shift?.endTime != null)
                  Text(
                    '${day.shift!.startTime} - ${day.shift!.endTime}',
                    style: TextStyle(color: _olive.withOpacity(0.8), fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}