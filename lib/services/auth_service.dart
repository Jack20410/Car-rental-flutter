import 'dart:async';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUserEmail;
  static String? _currentUserName;

  // Demo credentials for testing
  static const Map<String, String> _demoCredentials = {
    'demo@example.com': 'password123',
    'test@test.com': 'test123',
    'admin@carrental.com': 'admin123',
  };

  // Mock user data
  static const Map<String, Map<String, String>> _userData = {
    'demo@example.com': {
      'name': 'Demo User',
      'email': 'demo@example.com',
      'avatar': '',
    },
    'test@test.com': {
      'name': 'Test User',
      'email': 'test@test.com',
      'avatar': '',
    },
    'admin@carental.com': {
      'name': 'Admin User',
      'email': 'admin@carental.com',
      'avatar': '',
    },
  };

  /// Login with email and password
  static Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    if (_demoCredentials.containsKey(email) &&
        _demoCredentials[email] == password) {
      _isLoggedIn = true;
      _currentUserEmail = email;
      _currentUserName = _userData[email]?['name'] ?? 'User';

      // In a real app, you would store auth tokens securely
      // await _storeAuthToken(token);

      return true;
    }

    return false;
  }

  /// Login with Google (Mock implementation)
  static Future<bool> loginWithGoogle() async {
    // Simulate Google login delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful Google login
    _isLoggedIn = true;
    _currentUserEmail = 'user@gmail.com';
    _currentUserName = 'Google User';

    return true;
  }

  /// Login with Apple (Mock implementation)
  static Future<bool> loginWithApple() async {
    // Simulate Apple login delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful Apple login
    _isLoggedIn = true;
    _currentUserEmail = 'user@icloud.com';
    _currentUserName = 'Apple User';

    return true;
  }

  /// Register new user
  static Future<bool> register(
    String email,
    String password,
    String name,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user already exists
    if (_demoCredentials.containsKey(email)) {
      return false; // User already exists
    }

    // In a real app, you would make an API call to register the user
    // For now, we'll just simulate success
    return true;
  }

  /// Logout user
  static Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;

    // In a real app, you would clear stored tokens
    // await _clearAuthToken();
  }

  /// Check if user is logged in
  static bool get isLoggedIn => _isLoggedIn;

  /// Get current user email
  static String? get currentUserEmail => _currentUserEmail;

  /// Get current user name
  static String? get currentUserName => _currentUserName;

  /// Get current user data
  static Map<String, String>? get currentUser {
    if (_currentUserEmail != null) {
      return _userData[_currentUserEmail!] ??
          {
            'name': _currentUserName ?? 'User',
            'email': _currentUserEmail!,
            'avatar': '',
          };
    }
    return null;
  }

  /// Reset password (Mock implementation)
  static Future<bool> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if email exists in our demo system
    if (_demoCredentials.containsKey(email)) {
      // In a real app, you would send a reset email
      return true;
    }

    return false;
  }

  /// Change password
  static Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (!_isLoggedIn || _currentUserEmail == null) {
      return false;
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Verify current password
    if (_demoCredentials[_currentUserEmail] != currentPassword) {
      return false;
    }

    // In a real app, you would make an API call to change the password
    // For now, we'll just simulate success
    return true;
  }

  /// Refresh authentication token
  static Future<bool> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would refresh the auth token
    // For now, just return true if logged in
    return _isLoggedIn;
  }

  /// Initialize auth service (check for stored tokens)
  static Future<void> initialize() async {
    // In a real app, you would check for stored auth tokens
    // and validate them with your backend

    // For demo purposes, we'll just set logged out state
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
  }

  // Private methods for token management (would be implemented in real app)

  // static Future<void> _storeAuthToken(String token) async {
  //   // Store token securely using flutter_secure_storage or similar
  // }

  // static Future<String?> _getStoredAuthToken() async {
  //   // Retrieve stored token
  //   return null;
  // }

  // static Future<void> _clearAuthToken() async {
  //   // Clear stored token
  // }
}
