class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // static const String baseUrl = 'http://10.18.29.55:8000/api/v1';

  static const String logout = '/logout';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String attendanceLocation = '/attendance/location';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceToday = '/attendance/today';
  static const String attendanceHistory = '/attendance/history';
  static const String leaveTypes = '/leave/leave-types';
  static const String leaveRequests = '/leave/requests';
  static const String emergencyCheckIn = '/attendance/emergency-check-in';
  static const String emergencyCheckInToday = '/attendance/emergency-check-in/today';
  static const String emergencyCheckInHistory = '/attendance/emergency-check-in/history';
}