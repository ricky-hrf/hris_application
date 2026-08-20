import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/datasources/leave_remote_datasource.dart';
import '../../data/repositories/leave_repository_impl.dart';
import '../../domain/entities/leave_type_entity.dart';
import '../../domain/usecases/get_leave_types_usecase.dart';
import '../../domain/usecases/submit_leave_request_usecase.dart';

class LeaveRequestFormPage extends StatefulWidget {
  const LeaveRequestFormPage({super.key});

  @override
  State<LeaveRequestFormPage> createState() => _LeaveRequestFormPageState();
}

class _LeaveRequestFormPageState extends State<LeaveRequestFormPage> {
  static const _allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
  static const _maxFileSizeBytes = 2 * 1024 * 1024; // 2MB

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  late final ApiClient _apiClient;
  late final GetLeaveTypesUseCase _getLeaveTypesUseCase;
  late final SubmitLeaveRequestUseCase _submitLeaveRequestUseCase;

  List<LeaveTypeEntity> _leaveTypes = [];
  LeaveTypeEntity? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;

  File? _attachmentFile;
  String? _attachmentFileName;
  int? _attachmentFileSize;

  bool _isLoadingTypes = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);
    final remoteDataSource = LeaveRemoteDataSourceImpl(_apiClient);
    final repository = LeaveRepositoryImpl(remoteDataSource);
    _getLeaveTypesUseCase = GetLeaveTypesUseCase(repository);
    _submitLeaveRequestUseCase = SubmitLeaveRequestUseCase(repository);

    _loadLeaveTypes();
  }

  Future<void> _loadLeaveTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _errorMessage = null;
    });

    try {
      final types = await _getLeaveTypesUseCase();
      setState(() {
        _leaveTypes = types;
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat jenis cuti: ${e.toString()}';
        _isLoadingTypes = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;

    if (picked.path == null) {
      setState(() => _errorMessage = 'Gagal membaca file yang dipilih.');
      return;
    }

    if (picked.size > _maxFileSizeBytes) {
      setState(() => _errorMessage = 'Ukuran lampiran maksimal 2MB.');
      return;
    }

    setState(() {
      _attachmentFile = File(picked.path!);
      _attachmentFileName = picked.name;
      _attachmentFileSize = picked.size;
      _errorMessage = null;
    });
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
      _attachmentFileName = null;
      _attachmentFileSize = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLeaveType == null) {
      setState(() => _errorMessage = 'Pilih jenis cuti terlebih dahulu.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      setState(() => _errorMessage = 'Pilih tanggal cuti terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _submitLeaveRequestUseCase(
        leaveTypeId: _selectedLeaveType!.id,
        startDate: _formatDate(_startDate!),
        endDate: _formatDate(_endDate!),
        reason: _reasonController.text,
        attachmentPath: _attachmentFile?.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan cuti berhasil dikirim.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
      return;
    }

    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Cuti')),
      body: _isLoadingTypes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              const Text('Jenis Cuti', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<LeaveTypeEntity>(
                value: _selectedLeaveType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _leaveTypes.map((type) {
                  final quotaLabel = type.requiresQuota
                      ? ' (sisa ${type.remainingQuota ?? 0} hari)'
                      : '';
                  return DropdownMenuItem(
                    value: type,
                    child: Text('${type.name}$quotaLabel'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedLeaveType = value),
                validator: (value) => value == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              const Text('Tanggal Cuti', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDateRange,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Text(
                    _startDate != null && _endDate != null
                        ? '${_formatDate(_startDate!)}  s/d  ${_formatDate(_endDate!)}'
                        : 'Pilih tanggal',
                    style: TextStyle(
                      color: _startDate != null ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Alasan', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tuliskan alasan pengajuan cuti...',
                ),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Alasan wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              const Text('Lampiran (opsional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                'Format: PDF, Word, atau gambar (JPG/PNG). Maks 2MB.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              if (_attachmentFile == null)
                InkWell(
                  onTap: _pickAttachment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, size: 20, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Pilih file lampiran',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _attachmentFileName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (_attachmentFileSize != null)
                              Text(
                                _formatFileSize(_attachmentFileSize!),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _removeAttachment,
                        tooltip: 'Hapus lampiran',
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Kirim Pengajuan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}