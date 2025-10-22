import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AppConstants {
  // 42 OAuth credentials
  static const String clientId = 'Your UID Here';
  static const String clientSecret = 'Your Secret Here';
  
  // Redirect URIs
  static const String redirectUriWeb = 'http://localhost:8080';
  static const String redirectUriMobile = 'com.sports42://oauth/callback';
  
  static const String authorizationEndpoint = 'https://api.intra.42.fr/oauth/authorize';
  static const String tokenEndpoint = 'https://api.intra.42.fr/oauth/token';
  static const String apiBaseUrl = 'https://api.intra.42.fr/v2';

  // Backend API - dynamically detects current network IP
  static Future<String> getBackendUrl() async {
    // First try to get saved custom IP from preferences
    final prefs = await SharedPreferences.getInstance();
    final customIp = prefs.getString('custom_backend_ip');
    if (customIp != null && customIp.isNotEmpty) {
      return 'http://$customIp:3000/api';
    }

    // Otherwise, try to detect current WiFi IP and assume backend is on same subnet
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    
    if (wifiIP != null) {
      // Extract subnet (e.g., 192.168.178.x) and try common backend IPs
      final parts = wifiIP.split('.');
      if (parts.length == 4) {
        final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
        // Try common development machine IPs on the same subnet
        final commonIps = ['82', '1', '100', '101', '102'];
        for (final ip in commonIps) {
          final testUrl = 'http://$subnet.$ip:3000/api';
          if (await _testBackendConnection(testUrl)) {
            return testUrl;
          }
        }
      }
    }
    
    // Fallback to last known working IP
    return 'http://192.168.178.82:3000/api';
  }

  // Test if backend is reachable
  static Future<bool> _testBackendConnection(String url) async {
    try {
      final uri = Uri.parse(url.replaceAll('/api', ''));
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Set custom backend IP
  static Future<void> setCustomBackendIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_backend_ip', ip);
  }
  
  // Set to true to use backend API, false to use local storage only
  static const bool useBackend = true;

  // Token limits
  static const int minTokens = 0;
  static const int maxTokens = 5;
  static const int initialTokens = 0; // No tokens on signup, must complete quiz
  static const int quizRewardTokens = 3; // Reward for completing the welcome quiz
  
  // Token costs for creating events/tournaments
  static const int eventCreationCost = 1;
  static const int eventTokenCost = 1; // Alias for backward compatibility
  static const int tournamentCreationCost = 3;
  static const int tournamentTokenCost = 3; // Alias for backward compatibility
  
  // Event completion reward
  static const int eventCompletionReward = 1;

  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyEvents = 'events';
}
