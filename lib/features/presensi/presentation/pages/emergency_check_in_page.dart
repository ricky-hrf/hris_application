import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/usecases/submit_emergency_check_in_usecase.dart';

class EmergencyCheckInPage extends StatefulWidget {
  const EmergencyCheckInPage({super.key});

  @override
  State<EmergencyCheckInPage> createState() => _EmergencyCheckInPageState();
}

class _EmergencyCheckInPageState extends State<EmergencyCheckInPage> {
  late final SubmitEmergencyCheckInUseCase _submitEmergencyCheckInUseCase;

  final _reasonController = TextEditingController();
  File? _selfiePhoto;
  File? _proofPhoto;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));

    _submitEmergencyCheckInUseCase = SubmitEmergencyCheckInUseCase(repository);
  }

  Future<void> _takeSelfie() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _selfiePhoto = File(picked.path));
  }

  Future<void> _takeProofPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) setState(() => _proofPhoto = File(picked.path));
  }

  Future<Position> _resolveCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('GPS tidak aktif. Aktifkan lokasi di pengaturan HP.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  bool get _canSubmit {
    return !_isSubmitting &&
        _selfiePhoto != null &&
        _proofPhoto != null &&
        _reasonController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final position = await _resolveCurrentPosition();

      await _submitEmergencyCheckInUseCase(
        latitude: position.latitude,
        longitude: position.longitude,
        reason: _reasonController.text.trim(),
        selfiePhotoPath: _selfiePhoto!.path,
        proofPhotoPath: _proofPhoto!.path,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presensi darurat berhasil dikirim, menunggu persetujuan HRD.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Gagal mengirim presensi darurat: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Widget _photoBox({
    required String label,
    required File? photo,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: _isSubmitting ? null : onTap,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8E5)),
                image: photo != null
                    ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover)
                    : null,
              ),
              child: photo == null
                  ? const Icon(Icons.camera_alt_rounded, color: Color(0xFF0F5C48), size: 30)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text('Presensi Darurat'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gunakan ini hanya jika Anda benar-benar berhalangan hadir di lokasi presensi (mis. kendaraan rusak). Status presensi akan ditentukan oleh HRD.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _photoBox(label: 'Foto Selfie', photo: _selfiePhoto, onTap: _takeSelfie),
                const SizedBox(width: 12),
                _photoBox(label: 'Foto Bukti Kendala', photo: _proofPhoto, onTap: _takeProofPhoto),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan kendala yang Anda alami...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF0F5C48), width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5C48),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Text('Kirim Presensi Darurat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}