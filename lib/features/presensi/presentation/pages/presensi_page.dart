import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/distance.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_location_entity.dart';
import '../../domain/entities/attendance_today_entity.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/check_out_usecase.dart';
import '../../domain/usecases/get_my_location_usecase.dart';
import '../../domain/usecases/get_today_attendance_usecase.dart';
import '../widgets/presensi/location_badge.dart';
import 'emergency_check_in_page.dart';
import 'emergency_history_page.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  late final GetMyLocationUseCase _getMyLocationUseCase;
  late final CheckInUseCase _checkInUseCase;
  late final CheckOutUseCase _checkOutUseCase;
  late final GetTodayAttendanceUseCase _getTodayAttendanceUseCase;
  final MapController _mapController = MapController();

  bool _isLoadingLocation = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  AttendanceLocationEntity? _officeLocation;
  Position? _currentPosition;
  File? _capturedPhoto;
  AttendanceTodayEntity? _todayAttendance;

  int? get _distance {
    if (_officeLocation == null || _currentPosition == null) return null;
    return distanceMeters(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _officeLocation!.latitude,
      _officeLocation!.longitude,
    );
  }

  bool get _isInRange {
    if (_distance == null || _officeLocation == null) return false;
    return _distance! <= _officeLocation!.radiusMeters;
  }

  bool get _isNotCheckedIn => _todayAttendance == null || _todayAttendance?.status == 'not_checked_in';
  bool get _isCheckedIn => _todayAttendance?.status == 'checked_in';
  bool get _isCheckedOut => _todayAttendance?.status == 'checked_out';

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_isCheckedOut) return false;
    return _isInRange && _capturedPhoto != null;
  }

  @override
  void initState() {
    super.initState();

    final storage = SecureStorageService();
    final client = ApiClient(baseUrl: ApiEndpoints.baseUrl, storage: storage);
    final repository = AttendanceRepositoryImpl(AttendanceRemoteDataSourceImpl(client));

    _getMyLocationUseCase = GetMyLocationUseCase(repository);
    _checkInUseCase = CheckInUseCase(repository);
    _checkOutUseCase = CheckOutUseCase(repository);
    _getTodayAttendanceUseCase = GetTodayAttendanceUseCase(repository);

    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final office = await _getMyLocationUseCase();
      final position = await _resolveCurrentPosition();
      final todayAttendance = await _getTodayAttendanceUseCase();

      setState(() {
        _officeLocation = office;
        _currentPosition = position;
        _todayAttendance = todayAttendance;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(LatLng(position.latitude, position.longitude), 17);
        }
      });
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Gagal mendapatkan lokasi: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
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

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      setState(() => _capturedPhoto = File(picked.path));
    }
  }

  Future<void> _refreshTodayAttendance() async {
    final todayAttendance = await _getTodayAttendanceUseCase();
    setState(() => _todayAttendance = todayAttendance);
  }

  Future<void> _openEmergencyCheckIn() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const EmergencyCheckInPage()),
    );
    if (result == true) {
      await _refreshTodayAttendance();
    }
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit || _currentPosition == null) return;

    setState(() => _isSubmitting = true);

    try {
      if (_isCheckedIn) {
        final result = await _checkOutUseCase(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          locationId: _officeLocation!.id,
          photoPath: _capturedPhoto!.path,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-out berhasil — jarak ${result.distanceMeters}m'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final result = await _checkInUseCase(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          locationId: _officeLocation!.id,
          photoPath: _capturedPhoto!.path,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in berhasil (${result.status}) — jarak ${result.distanceMeters}m'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() => _capturedPhoto = null);
      await _refreshTodayAttendance();
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(_isCheckedIn ? 'Gagal melakukan check-out' : 'Gagal melakukan check-in');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  String get _submitButtonLabel {
    if (_isSubmitting) return '';
    if (_isCheckedOut) return 'Presensi hari ini selesai';

    if (_capturedPhoto == null) {
      return _isCheckedIn ? 'Ambil foto untuk Check Out' : 'Ambil foto dulu';
    }

    if (!_isInRange) return 'Di luar jangkauan';

    return _isCheckedIn ? 'Check Out' : 'Check In';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi'),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Riwayat Presensi Darurat',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmergencyHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoadingLocation
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
              OutlinedButton(onPressed: _init, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      )
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hris.application',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(_officeLocation!.latitude, _officeLocation!.longitude),
                    radius: _officeLocation!.radiusMeters.toDouble(),
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.15),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_officeLocation!.latitude, _officeLocation!.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.business_rounded, color: Colors.blue, size: 32),
                  ),
                  Marker(
                    point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.person_pin_circle_rounded,
                      color: _isInRange ? Colors.green : Colors.red,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: LocationBadge(
                isLoading: false,
                isInRange: _isInRange,
                distanceMeters: _distance,
                radiusMeters: _officeLocation?.radiusMeters,
              ),
            ),
          ),

          Positioned(
            bottom: 190,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'refresh_location',
              backgroundColor: Colors.white,
              onPressed: _init,
              child: const Icon(Icons.my_location_rounded, color: Color(0xFF6B8E2F)),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isCheckedOut ? null : _openEmergencyCheckIn,
                      icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFB45309)),
                      label: const Text(
                        'Tidak bisa hadir tepat waktu di lokasi absensi?',
                        style: TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isCheckedOut ? null : _takePhoto,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            image: _capturedPhoto != null
                                ? DecorationImage(image: FileImage(_capturedPhoto!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _capturedPhoto == null
                              ? const Icon(Icons.camera_alt_rounded, color: Color(0xFF0F5C48), size: 28)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _canSubmit ? _handleSubmit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCheckedIn ? const Color(0xFFE85D04) : const Color(
                                  0xFF1B7758),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(
                              _submitButtonLabel,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}