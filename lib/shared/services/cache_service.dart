import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/reflection/data/models/reflection_model.dart';

class CacheService {
  static const String _userReflectionsKey = 'user_reflections_';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Cache user's reflections
  Future<void> cacheUserReflections(
      String userId,
      List<ReflectionModel> reflections,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = reflections.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString('$_userReflectionsKey$userId', jsonString);
      print('💾 Cached ${reflections.length} reflections for user $userId');
    } catch (e) {
      print('❌ Error caching reflections: $e');
    }
  }

  // Get cached reflections
  Future<List<ReflectionModel>> getCachedReflections(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_userReflectionsKey$userId');

      if (jsonString == null) {
        print('💾 No cached reflections found');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final reflections = jsonList
          .map((json) => ReflectionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('💾 Loaded ${reflections.length} cached reflections');
      return reflections;
    } catch (e) {
      print('❌ Error loading cached reflections: $e');
      return [];
    }
  }

  // Cache user profile data
  Future<void> cacheUserProfile(String name, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
      print('💾 Cached user profile');
    } catch (e) {
      print('❌ Error caching profile: $e');
    }
  }

  // Get cached user profile
  Future<Map<String, String>> getCachedUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_userNameKey) ?? '';
      final email = prefs.getString(_userEmailKey) ?? '';

      if (name.isEmpty && email.isEmpty) {
        print('💾 No cached profile found');
        return {};
      }

      print('💾 Loaded cached profile');
      return {'name': name, 'email': email};
    } catch (e) {
      print('❌ Error loading cached profile: $e');
      return {};
    }
  }

  // Clear all cache (for logout)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('💾 Cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}