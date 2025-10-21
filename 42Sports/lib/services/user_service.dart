import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class UserService {
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> updateTokens(String userId, int tokens) async {
    final user = await getUser();
    if (user == null || user.id != userId) return;

    final updatedUser = user.copyWith(
      tokens: tokens.clamp(AppConstants.minTokens, AppConstants.maxTokens),
    );
    await saveUser(updatedUser);
  }

  Future<bool> canCreateEvent(String userId) async {
    final user = await getUser();
    if (user == null || user.id != userId) return false;
    return user.tokens > 0;
  }

  Future<void> spendToken(String userId) async {
    final user = await getUser();
    if (user == null || user.id != userId) return;
    await updateTokens(userId, user.tokens - 1);
  }

  Future<void> refundToken(String userId) async {
    final user = await getUser();
    if (user == null || user.id != userId) return;
    await updateTokens(userId, user.tokens + 1);
  }

  Future<void> rewardToken(String userId) async {
    final user = await getUser();
    if (user == null || user.id != userId) return;
    await updateTokens(userId, user.tokens + 2);
  }

  Future<bool> hasCompletedQuiz(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quiz_completed_$userId') ?? false;
  }

  Future<void> markQuizCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_completed_$userId', true);
  }

  Future<void> setQuizFailedTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_failed_time_$userId', DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> canRetakeQuiz(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final failedTime = prefs.getInt('quiz_failed_time_$userId');
    
    if (failedTime == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - failedTime;
    const cooldownDuration = 30 * 1000; // 30 seconds in milliseconds
    
    return difference >= cooldownDuration;
  }

  Future<int> getRemainingCooldownSeconds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final failedTime = prefs.getInt('quiz_failed_time_$userId');
    
    if (failedTime == null) return 0;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - failedTime;
    const cooldownDuration = 30 * 1000; // 30 seconds
    
    final remaining = cooldownDuration - difference;
    return remaining > 0 ? (remaining / 1000).ceil() : 0;
  }
}
