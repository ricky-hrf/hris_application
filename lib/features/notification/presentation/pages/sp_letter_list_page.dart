import 'package:flutter/material.dart';

import 'package:hris_application/core/network/api_client.dart';
import 'package:hris_application/core/network/api_endpoints.dart';
import 'package:hris_application/core/storage/secure_storage_service.dart';
import '../../data/datasources/sp_letter_remote_datasource.dart';
import '../../data/repositories/sp_letter_repository_impl.dart';
import '../../domain/entities/sp_letter_summary_entity.dart';
import '../../domain/usecases/get_my_sp_letters_usecase.dart';
import 'sp_letter_detail_page.dart';

class SpLetterListPage extends StatefulWidget {
  const SpLetterListPage({super.key});

  @override
  State<SpLetterListPage> createState() => _SpLetterListPageState();
}

class _SpLetterListPageState extends State<SpLetterListPage> {
  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _cream = Color(0xFFF7FAF9);
  static const _warn = Color(0xFFB3261E);

  late final GetMySpLettersUseCase _getMySpLettersUseCase;

  bool _isLoading = true;
  String? _error;
  List<SpLetterSummaryEntity> _letters = [];

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = SpLetterRepositoryImpl(SpLetterRemoteDataSourceImpl(client));
    _getMySpLettersUseCase = GetMySpLettersUseCase(repository);

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final letters = await _getMySpLettersUseCase();
      letters.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
      if (mounted) setState(() => _letters = letters);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _teal,
        title: const Text('Surat Peringatan', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _teal))
            : _error != null
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
          ],
        )
            : _letters.isEmpty
            ? ListView(
          children: const [
            Padding(
              padding: EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 48, color: _olive),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada surat peringatan.',
                    style: TextStyle(color: _olive, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _letters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final letter = _letters[index];
            return _SpLetterTile(
              letter: letter,
              dateLabel: _formatDate(letter.issuedAt),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SpLetterDetailPage(letterId: letter.id),
                  ),
                );
                _load();
              },
            );
          },
        ),
      ),
    );
  }
}

class _SpLetterTile extends StatelessWidget {
  final SpLetterSummaryEntity letter;
  final String dateLabel;
  final VoidCallback onTap;

  const _SpLetterTile({
    required this.letter,
    required this.dateLabel,
    required this.onTap,
  });

  static const _teal = Color(0xFF0F5C48);
  static const _olive = Color(0xFF6B8E2F);
  static const _warn = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: letter.isUnread ? Border.all(color: _warn.withOpacity(0.35), width: 1.2) : null,
          boxShadow: [
            BoxShadow(color: _teal.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surat Peringatan #${letter.spNumber}',
                    style: const TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Diterbitkan $dateLabel',
                    style: TextStyle(color: _olive.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (letter.isUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _warn,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Baru',
                  style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: _teal, size: 20),
          ],
        ),
      ),
    );
  }
}