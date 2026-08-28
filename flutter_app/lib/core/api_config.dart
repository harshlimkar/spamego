class ApiConfig {
  // Use 10.0.2.2 for Android emulator pointing to localhost, or real IP for physical device
  static const String host = '10.0.2.2:8000';
  
  static const String baseUrl = 'http://$host';
  static const String wsBaseUrl = 'ws://$host';
  
  static String get analyzeEndpoint => '$baseUrl/api/intel/analyze';
  static String campaignAlertsWs(String userId) => '$wsBaseUrl/ws/campaign-alerts/$userId';
}
