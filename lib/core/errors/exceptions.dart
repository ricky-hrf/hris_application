class AppException implements Exception{
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

// kredensial salah (email/password tidak cocok)
class InvalidCredentialsException extends AppException{
  const InvalidCredentialsException([super.message = 'Email/password salah']);
}

/// tidak ada koneksi internet / request gagal terkirim
class NetworkException extends AppException{
  const NetworkException([super.message = 'Tidak ada koneksi internet']);
}

/// error dari server
class ServerException extends AppException{
  const ServerException([super.message = 'Terjadi kesalahan pada server']);
}

/// validasi data yang diterima
class ValidationException extends AppException{
  const ValidationException([super.message = 'Data yang dikirim tidak valid']);
}