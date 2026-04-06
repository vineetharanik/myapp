import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String email;
  final String password;
  final DateTime createdAt;

  User({required this.email, required this.password, required this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // Email validation regex
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Check if email already exists
  static Future<bool> emailExists(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final usersList = json.decode(usersJson) as List;

    return usersList.any((user) => user['email'] == email);
  }

  // Register new user
  static Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Validate email format
    if (!isValidEmail(email)) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
      };
    }

    // Validate password
    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters long',
      };
    }

    // Check if passwords match
    if (password != confirmPassword) {
      return {'success': false, 'message': 'Passwords do not match'};
    }

    // Check if email already exists
    if (await emailExists(email)) {
      return {
        'success': false,
        'message': 'An account with this email already exists',
      };
    }

    // Create new user
    final newUser = User(
      email: email,
      password: password, // In real app, hash this password
      createdAt: DateTime.now(),
    );

    // Save user to storage
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final usersList = json.decode(usersJson) as List;
    usersList.add(newUser.toJson());

    await prefs.setString(_usersKey, json.encode(usersList));

    // Set as current user
    await prefs.setString(_currentUserKey, email);

    return {
      'success': true,
      'message': 'Registration successful!',
      'user': newUser,
    };
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    // Validate email format
    if (!isValidEmail(email)) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
      };
    }

    // Get users from storage
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final usersList = json.decode(usersJson) as List;

    // Find user by email
    final userMap = usersList.firstWhere(
      (user) => user['email'] == email,
      orElse: () => null,
    );

    if (userMap == null) {
      return {'success': false, 'message': 'No account found with this email'};
    }

    // Check password
    if (userMap['password'] != password) {
      return {'success': false, 'message': 'Incorrect password'};
    }

    // Set as current user
    await prefs.setString(_currentUserKey, email);

    return {
      'success': true,
      'message': 'Login successful!',
      'user': User.fromJson(userMap),
    };
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString(_currentUserKey);

    if (currentUserEmail == null) return null;

    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final usersList = json.decode(usersJson) as List;

    final userMap = usersList.firstWhere(
      (user) => user['email'] == currentUserEmail,
      orElse: () => null,
    );

    return userMap != null ? User.fromJson(userMap) : null;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  // Get all registered users (for admin purposes)
  static Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final usersList = json.decode(usersJson) as List;

    return usersList.map((user) => User.fromJson(user)).toList();
  }
}
