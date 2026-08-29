import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hris_application/core/network/api_client.dart';
import 'package:hris_application/core/network/api_endpoints.dart';
import 'package:hris_application/core/storage/secure_storage_service.dart';
import '../../data/datasources/sp_letter_remote_datasource.dart';
import '../../data/repositories/sp_letter_repository_impl.dart';
import '../../domain/entities/sp_letter_detail_entity.dart';
import '../../domain/usecases/get_sp_letter_detail_usecase.dart';

class SpLetterDetailPage extends StatefulWidget {
  final int letterId;

  const SpLetterDetailPage({super.key, required this.letterId});

  @override
  State<SpLetterDetailPage> createState() => _SpLetterDetailPageState();
}

class _SpLetterDetailPageState extends State<SpLetterDetailPage> {
  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _cream = Color(0xFFF7FAF9);
  static const _warn = Color(0xFFB3261E);

  late final GetSpLetterDetailUseCase _getSpLetterDetailUseCase;

  bool _isLoading = true;
  String? _error;
  SpLetterDetailEntity? _letter;

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = SpLetterRepositoryImpl(SpLetterRemoteDataSourceImpl(client));
    _getSpLetterDetailUseCase = GetSpLetterDetailUseCase(repository);

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Memanggil detail ini otomatis menandai surat sebagai sudah dibaca
      // di backend (SpLetterService::getMyLetterDetail -> markViewed()).
      final letter = await _getSpLetterDetailUseCase(widget.letterId);
      if (mounted) setState(() => _letter = letter);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka file surat.')),
      );
    }
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.day} ${months[date.month - 1]} ${date.year}, $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _teal,
        title: const Text('Detail Surat', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      )
          : _letter == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: _teal.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _warn.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.warning_amber_rounded, color: _warn, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Surat Peringatan #${_letter!.spNumber}',
                          style: const TextStyle(color: _teal, fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Diterbitkan', value: _formatDateTime(_letter!.issuedAt)),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Status',
                    value: _letter!.viewedAt != null ? 'Sudah dibaca' : 'Baru dibuka',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_letter!.isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  _letter!.fileUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(color: _teal)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Gagal memuat gambar surat.'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openFile(_letter!.fileUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Buka Surat', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: _olive.withOpacity(0.85), fontSize: 12.5, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}