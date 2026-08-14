import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final SecureStorageService _storage;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
    SecureStorageService? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? SecureStorageService();

  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
        bool requireAuth = false,
      }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: await _buildHeaders(requireAuth),
        body: jsonEncode(body ?? {}),
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> get(
      String path, {
        bool requireAuth = false,
        Map<String, String>? queryParameters,
      }) async {
    try {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await _client.get(
        uri,
        headers: await _buildHeaders(requireAuth),
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, String>> _buildHeaders(bool requireAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _storage.getToken();
      if (token == null) {
        throw const InvalidCredentialsException('Sesi berakhir, silakan login ulang');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ServerException('Response server tidak valid');
    }

    final bool success = decoded['success'] == true;
    final String message = decoded['message']?.toString() ?? 'Terjadi kesalahan';

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return decoded;
    }

    if (response.statusCode == 401) {
      throw InvalidCredentialsException(message);
    }
    if (response.statusCode == 422) {
      throw ValidationException(message);
    }

    throw ServerException(message);
  }

  Future<Map<String, dynamic>> postMultipart(
      String path, {
        required Map<String, String> fields,
        String? filePath,
        String fileFieldName = 'photo',
        bool requireAuth = false,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.MultipartRequest('POST', uri);

      final headers = <String, String>{'Accept': 'application/json'};
      if (requireAuth) {
        final token = await _storage.getToken();
        if (token == null) {
          throw const InvalidCredentialsException('Sesi berakhir, silakan login ulang');
        }
        headers['Authorization'] = 'Bearer $token';
      }
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> postMultipartMultiFile(
      String path, {
        required Map<String, String> fields,
        required Map<String, String> files, // fieldName -> filePath
        bool requireAuth = false,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.MultipartRequest('POST', uri);

      final headers = <String, String>{'Accept': 'application/json'};
      if (requireAuth) {
        final token = await _storage.getToken();
        if (token == null) {
          throw const InvalidCredentialsException('Sesi berakhir, silakan login ulang');
        }
        headers['Authorization'] = 'Bearer $token';
      }
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (final entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }
}