import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  String get _redirectUri =>
      kIsWeb ? AppConstants.redirectUriWeb : AppConstants.redirectUriMobile;

  Future<void> login() async {
    final authUrl = Uri.parse(
      '${AppConstants.authorizationEndpoint}?'
      'client_id=${AppConstants.clientId}&'
      'redirect_uri=$_redirectUri&'
      'response_type=code&'
      'scope=public',
    );

    try {
      // Try to launch with platformDefault mode which should open the default browser
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.platformDefault,
      );
      
      if (!launched) {
        print('Failed to launch URL: $authUrl');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<bool> handleCallback(String code) async {
    try {
      print('Exchanging code for token: $code');
      final response = await http.post(
        Uri.parse(AppConstants.tokenEndpoint),
        body: {
          'grant_type': 'authorization_code',
          'client_id': AppConstants.clientId,
          'client_secret': AppConstants.clientSecret,
          'code': code,
          'redirect_uri': _redirectUri,
        },
      );

      print('Token response status: ${response.statusCode}');
      print('Token response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(
          key: AppConstants.keyAccessToken,
          value: data['access_token'],
        );
        await _storage.write(
          key: AppConstants.keyRefreshToken,
          value: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      print('Auth error: $e');
    }
    return false;
  }

  Future<User?> getCurrentUser() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        await _storage.write(key: AppConstants.keyUser, value: jsonEncode(user.toJson()));
        return user;
      }
    } catch (e) {
      print('Get user error: $e');
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    return token != null;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }
}
