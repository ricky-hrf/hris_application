class ApiEndpoints {
  ApiEndpoints._();

  // url helper untuk pengembangan di perangkat hp
  static const String baseUrl = 'http://10.18.13.4:8000/api/v1';

  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String logout = '/logout';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String attendanceLocation = '/attendance/location';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceToday = '/attendance/today';
  static const String attendanceHistory = '/attendance/history';
}