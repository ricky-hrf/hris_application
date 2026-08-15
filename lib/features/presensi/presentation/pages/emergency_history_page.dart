import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/emergency_status_entity.dart';
import '../../domain/usecases/get_my_emergency_history_usecase.dart';
import 'emergency_detail_page.dart';

class EmergencyHistoryPage extends StatefulWidget {
  const EmergencyHistoryPage({super.key});

  @override
  State<EmergencyHistoryPage> createState() => _EmergencyHistoryPageState();
}

class _EmergencyHistoryPageState extends State<EmergencyHistoryPage> {
  late final GetMyEmergencyHistoryUseCase _getMyEmergencyHistoryUseCase;

  List<EmergencyStatusEntity> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl);
    final repository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));
    _getMyEmergencyHistoryUseCase = GetMyEmergencyHistoryUseCase(repository);

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await _getMyEmergencyHistoryUseCase();
      if (mounted) setState(() => _history = history);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu HRD';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF0F5C48);
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xFFB45309);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text('Riwayat Presensi Darurat'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
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
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: _history.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                'Belum ada riwayat presensi darurat',
                style: TextStyle(color: Colors.grey.shade600),
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
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EmergencyDetailPage(checkInId: item.id),
                  ),
                );
              },
              child: Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statusColor(item.emergencyStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: _statusColor(item.emergencyStatus), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.checkedAt,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.emergencyReason,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor(item.emergencyStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(item.emergencyStatus),
                        style: TextStyle(color: _statusColor(item.emergencyStatus), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}