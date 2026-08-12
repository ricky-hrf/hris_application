import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/datasources/leave_remote_datasource.dart';
import '../../data/repositories/leave_repository_impl.dart';
import '../../domain/entities/leave_request_entity.dart';
import '../../domain/usecases/get_my_leave_requests_usecase.dart';
import '../../domain/usecases/cancel_leave_request_usecase.dart';
import 'leave_request_form_page.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final GetMyLeaveRequestsUseCase _getMyLeaveRequestsUseCase;
  late final CancelLeaveRequestUseCase _cancelLeaveRequestUseCase;

  List<LeaveRequestEntity> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const _ongoingStatuses = ['pending_supervisor', 'pending_hr'];
  static const _historyStatuses = ['approved', 'rejected', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl);
    final remoteDataSource = LeaveRemoteDataSourceImpl(client);
    final repository = LeaveRepositoryImpl(remoteDataSource);
    _getMyLeaveRequestsUseCase = GetMyLeaveRequestsUseCase(repository);
    _cancelLeaveRequestUseCase = CancelLeaveRequestUseCase(repository);

    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _getMyLeaveRequestsUseCase();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LeaveRequestFormPage()),
    );

    if (result == true) {
      _loadRequests();
    }
  }

  Future<void> _cancelRequest(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Pengajuan'),
        content: const Text('Yakin ingin membatalkan pengajuan cuti ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _cancelLeaveRequestUseCase(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dibatalkan.')),
      );
      _loadRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending_supervisor':
        return 'Menunggu Atasan';
      case 'pending_hr':
        return 'Menunggu HRD';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ongoing = _requests.where((r) => _ongoingStatuses.contains(r.status)).toList();
    final history = _requests.where((r) => _historyStatuses.contains(r.status)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuti'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Diproses'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Cuti'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList(
            ongoing,
            showProgress: true,
            emptyText: 'Tidak ada pengajuan yang sedang diproses.',
          ),
          _buildList(
            history,
            showProgress: false,
            emptyText: 'Belum ada riwayat cuti.',
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<LeaveRequestEntity> requests, {
        required bool showProgress,
        required String emptyText,
      }) {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: requests.isEmpty
          ? ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              emptyText,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final req = requests[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      req.leaveTypeName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(req.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(req.status),
                        style: TextStyle(
                          color: _statusColor(req.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${req.startDate}  s/d  ${req.endDate}  (${req.totalDays} hari)',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  req.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  _buildProgressSteps(req.status),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _cancelRequest(req.id),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Batalkan'),
                    ),
                  ),
                ],
                if (!showProgress &&
                    (req.supervisorNote != null || req.hrNote != null)) ...[
                  const SizedBox(height: 8),
                  if (req.hrNote != null)
                    Text(
                      'Catatan HRD: ${req.hrNote}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  if (req.supervisorNote != null)
                    Text(
                      'Catatan Atasan: ${req.supervisorNote}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSteps(String status) {
    final steps = ['Diajukan', 'Atasan', 'HRD'];
    int activeStep;
    switch (status) {
      case 'pending_supervisor':
        activeStep = 1;
        break;
      case 'pending_hr':
        activeStep = 2;
        break;
      default:
        activeStep = 0;
    }

    return Row(
      children: List.generate(steps.length, (i) {
        final isDone = i < activeStep;
        final isActive = i == activeStep;
        final color = isDone
            ? Colors.green
            : isActive
            ? Colors.orange
            : Colors.grey.shade300;

        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundColor: color,
                child: isDone
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 4),
              Text(
                steps[i],
                style: TextStyle(
                  fontSize: 10,
                  color: isDone || isActive ? Colors.black87 : Colors.grey,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (i != steps.length - 1)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 2,
                    color: i < activeStep ? Colors.green : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}