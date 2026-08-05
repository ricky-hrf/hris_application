class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.18.7.101:8000/api/v1';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/profile';
  static const String attendanceLocation = '/attendance/location';
  static const String checkIn = '/attendance/check-in';
  static const String attendanceToday = '/attendance/today';
  static const String attendanceHistory = '/attendance/history';
}