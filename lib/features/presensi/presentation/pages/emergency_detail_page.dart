import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/emergency_detail_entity.dart';
import '../../domain/usecases/get_emergency_detail_usecase.dart';

class EmergencyDetailPage extends StatefulWidget {
  final int checkInId;

  const EmergencyDetailPage({super.key, required this.checkInId});

  @override
  State<EmergencyDetailPage> createState() => _EmergencyDetailPageState();
}

class _EmergencyDetailPageState extends State<EmergencyDetailPage> {
  late final GetEmergencyDetailUseCase _getEmergencyDetailUseCase;

  EmergencyDetailEntity? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl);
    final repository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));
    _getEmergencyDetailUseCase = GetEmergencyDetailUseCase(repository);

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _getEmergencyDetailUseCase(widget.checkInId);
      if (mounted) setState(() => _detail = detail);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan HRD';
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

  Widget _photoTile(String label, String? url) {
    return Expanded(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: url != null
                ? Image.network(url, height: 140, width: double.infinity, fit: BoxFit.cover)
                : Container(
              height: 140,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text('Detail Presensi Darurat'),
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor(_detail!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: _statusColor(_detail!.status), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusLabel(_detail!.status),
                      style: TextStyle(color: _statusColor(_detail!.status), fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Diajukan', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 2),
            Text(_detail!.checkedAt, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            Text('Keterangan', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 2),
            Text(_detail!.reason, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
            const SizedBox(height: 20),
            Row(
              children: [
                _photoTile('Selfie', _detail!.selfiePhotoUrl),
                const SizedBox(width: 12),
                _photoTile('Bukti Kendala', _detail!.proofPhotoUrl),
              ],
            ),
            if (_detail!.decisionNote != null) ...[
              const SizedBox(height: 20),
              Text('Catatan HRD', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(_detail!.decisionNote!, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
            ],
            if (_detail!.decidedAt != null) ...[
              const SizedBox(height: 8),
              Text('Diproses pada ${_detail!.decidedAt}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ],
        ),
      ),
    );
  }
}