export 'auth_service.dart';

import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const String _boxName = 'auth';
  static const String _userKey = 'current_user';
  static const String _usersBoxName = 'users';
  late Box<Map<dynamic, dynamic>> _box;
  late Box<Map<dynamic, dynamic>> _usersBox;

  Future<void> init() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    _usersBox = await Hive.openBox<Map<dynamic, dynamic>>(_usersBoxName);
  }

  Future<bool> signup(String name, String email, String password) async {
    // Check if email already exists
    final existingUser = _usersBox.values.any((user) => user['email'] == email);
    if (existingUser) {
      return false;
    }

    final userId = email.split('@')[0];
    final user = <String, dynamic>{
      'id': userId,
      'name': name,
      'email': email,
      'password': password, // In a real app, this should be hashed
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _usersBox.put(userId, Map<dynamic, dynamic>.from(user));
    await login(email, password); // Automatically log in after signup
    return true;
  }

  Future<bool> login(String email, String password) async {
    try {
      // Find user by email and validate password
      final user = _usersBox.values.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => <dynamic, dynamic>{},
      );

      if (user.isNotEmpty) {
        final sessionUser = <String, dynamic>{
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'lastLogin': DateTime.now().toIso8601String(),
        };
        
        await _box.put(_userKey, Map<dynamic, dynamic>.from(sessionUser));
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    // Clear the current user from Hive
    await _box.delete(_userKey);
    
    // Clear any other user-related data if needed
    await _box.clear();
  }

  Future<void> logout() => signOut();

  bool isLoggedIn() {
    return _box.get(_userKey) != null;
  }

  Map<String, dynamic>? getCurrentUser() {
    final userData = _box.get(_userKey);
    if (userData == null) return null;
    return Map<String, dynamic>.from(userData);
  }

  String? getCurrentUserId() {
    final user = getCurrentUser();
    return user?['id']?.toString();
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    // Check if email is already taken by another user
    final existingUser = _usersBox.values.any(
      (user) => user['email'] == email && user['id'] != userId,
    );
    if (existingUser) {
      throw Exception('Email is already in use');
    }

    // Update user data
    final userData = _usersBox.get(userId);
    if (userData != null) {
      userData['name'] = name;
      userData['email'] = email;
      await _usersBox.put(userId, userData);

      // Update session data
      final sessionUser = getCurrentUser();
      if (sessionUser != null) {
        sessionUser['name'] = name;
        sessionUser['email'] = email;
        await _box.put(_userKey, sessionUser);
      }
    }
  }
} 