import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _userRole;
  bool _isDemoMode = false; // For testing without database
  String? _demoSalonId; // For admin salon selection

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get userRole => _userRole;
  bool get isLoggedIn => _currentUser != null || _isDemoMode;
  String? get demoSalonId => _demoSalonId;

  AuthService() {
    _init();
  }

  void _init() {
    _currentUser = SupabaseService.currentUser;
    _loadUserRole();
    
    // Listen to auth state changes
    SupabaseService.authStateChanges.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _loadUserRole();
      } else {
        _userRole = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString('user_role');
      
      // If not in shared preferences, try to get from database
      if (_userRole == null && _currentUser != null) {
        try {
          final response = await SupabaseService.client
              .from('users')
              .select('role')
              .eq('id', _currentUser!.id)
              .single();
          
          _userRole = response['role'];
          await _saveUserRole(_userRole!);
        } catch (e) {
          // If user doesn't exist in users table, create them with customer role
          await _createUserProfile();
        }
      }
    } catch (e) {
      // If user doesn't exist in users table, create them with customer role
      await _createUserProfile();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _createUserProfile() async {
    if (_currentUser != null) {
      try {
        // Try to insert the user profile
        await SupabaseService.client.from('users').insert({
          'id': _currentUser!.id,
          'email': _currentUser!.email,
          'role': 'customer',
          'full_name': _currentUser!.userMetadata?['full_name'] ?? '',
          'phone': _currentUser!.userMetadata?['phone'] ?? '',
        });
        _userRole = 'customer';
        await _saveUserRole(_userRole!);
      } catch (e) {
        debugPrint('Error creating user profile: $e');
        // Even if we can't create the profile due to RLS, set default role
        _userRole = 'customer';
        await _saveUserRole(_userRole!);
      }
    }
  }

  Future<void> _saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  Future<void> _clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'customer',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if we're in demo mode
      if (email.contains('demo')) {
        // Demo mode - simulate successful signup
        _isDemoMode = true;
        _userRole = role;
        await _saveUserRole(role);
        return null; // Success
      }

      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone ?? '',
        },
      );

      if (response.user != null) {
        try {
          // Create user profile in users table
          await SupabaseService.client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'phone': phone ?? '',
            'role': role,
          });

          _userRole = role;
          await _saveUserRole(role);
        } catch (e) {
          debugPrint('Error creating user profile during signup: $e');
          // Set role locally even if we can't create the profile due to RLS
          _userRole = role;
          await _saveUserRole(role);
        }
      }

      return null; // Success
    } catch (e) {
      debugPrint('SignUp error: $e');
      if (e is PostgrestException) {
        if (e.code == '42501') {
          // RLS violation - user might still be able to login
          return 'Account created but profile setup restricted. Please try logging in.';
        }
        return e.message ?? 'An error occurred during signup';
      }
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if we're in demo mode for specific salons
      if (email == 'anura-admin@snipsyncs.com') {
        // Salon Anura admin
        _isDemoMode = true;
        _userRole = 'admin';
        _demoSalonId = '1'; // Salon Anura
        await _saveUserRole('admin');
        return null; // Success
      } else if (email == 'kandy-admin@snipsyncs.com') {
        // Kandy Salon admin
        _isDemoMode = true;
        _userRole = 'admin';
        _demoSalonId = '2'; // Kandy Salon
        await _saveUserRole('admin');
        return null; // Success
      } else if (email == 'shire-admin@snipsyncs.com') {
        // Shire Design admin
        _isDemoMode = true;
        _userRole = 'admin';
        _demoSalonId = '3'; // Shire Design
        await _saveUserRole('admin');
        return null; // Success
      } else if (email == 'anura-staff@snipsyncs.com') {
        // Salon Anura staff
        _isDemoMode = true;
        _userRole = 'staff';
        _demoSalonId = '1'; // Salon Anura
        await _saveUserRole('staff');
        return null; // Success
      } else if (email == 'kandy-staff@snipsyncs.com') {
        // Kandy Salon staff
        _isDemoMode = true;
        _userRole = 'staff';
        _demoSalonId = '2'; // Kandy Salon
        await _saveUserRole('staff');
        return null; // Success
      } else if (email == 'shire-staff@snipsyncs.com') {
        // Shire Design staff
        _isDemoMode = true;
        _userRole = 'staff';
        _demoSalonId = '3'; // Shire Design
        await _saveUserRole('staff');
        return null; // Success
      } else if (email.contains('admin') && email.contains('demo')) {
        // Generic demo admin
        _isDemoMode = true;
        _userRole = 'admin';
        _demoSalonId = '1'; // Default to Salon Anura
        await _saveUserRole('admin');
        return null; // Success
      } else if (email.contains('staff') && email.contains('demo')) {
        // Generic demo staff
        _isDemoMode = true;
        _userRole = 'staff';
        _demoSalonId = '1'; // Default to Salon Anura
        await _saveUserRole('staff');
        return null; // Success
      } else if (email.contains('demo')) {
        // Demo customer mode
        _isDemoMode = true;
        _userRole = 'customer';
        await _saveUserRole('customer');
        return null; // Success
      }

      await SupabaseService.signIn(
        email: email,
        password: password,
      );

      return null; // Success
    } catch (e) {
      debugPrint('SignIn error: $e');
      if (e is PostgrestException) {
        if (e.code == '42501') {
          // RLS violation
          return 'Access restricted due to security policies.';
        }
        return e.message ?? 'An error occurred during signin';
      } else if (e is AuthApiException) {
        if (e.code == 'invalid_credentials') {
          return 'Invalid email or password. Please check your credentials and try again.';
        } else if (e.code == 'email_not_confirmed') {
          return 'Please check your email and confirm your account before signing in.';
        }
        return e.message ?? 'Authentication error occurred';
      }
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if we're in demo mode
      if (_isDemoMode) {
        _isDemoMode = false;
        _userRole = null;
        _demoSalonId = null;
        await _clearUserRole();
        return;
      }

      await SupabaseService.signOut();
      _userRole = null;
      _demoSalonId = null;
      await _clearUserRole();
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email);
      return null; // Success
    } catch (e) {
      debugPrint('Reset password error: $e');
      if (e is AuthApiException) {
        return e.message ?? 'An error occurred while resetting password';
      }
      return e.toString();
    }
  }

  // Add the missing resendConfirmationEmail method
  Future<String?> resendConfirmationEmail(String email) async {
    try {
      await SupabaseService.client.auth.resend(
        email: email,
        type: OtpType.signup,
      );
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Helper method to fix email issues
  Future<bool> verifyUserExists(String email) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select('id')
          .eq('email', email)
          .single();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }
  
  // Method to enable demo mode for testing
  void enableDemoMode(String role, [String? salonId]) {
    _isDemoMode = true;
    _userRole = role;
    _demoSalonId = salonId;
    notifyListeners();
  }
}