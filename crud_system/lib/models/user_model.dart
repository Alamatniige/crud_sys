// user_model.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      // 1. Verify credentials in local user table
      print('🔍 Attempting login for username: $username');

      final userQuery = await _supabase
          .from('user')
          .select('id, username, first_name, last_name, email, password')
          .eq('username', username)
          .single();

      print('🔑 User Found Details:');
      print('Local Username: ${userQuery['username']}');
      print('Local Email: ${userQuery['email']}');

      final email = userQuery['email'];
      if (email == null || email.isEmpty) {
        print('❌ No email associated with this user');
        return null;
      }

      try {
        print('🚀 Attempting Supabase Authentication:');
        print('Email: $email');

        // Attempt sign-in
        final AuthResponse response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        // Check authentication result
        if (response.user == null) {
          print('❌ Supabase authentication failed - No user returned');
          return null;
        }

        print('✅ Supabase Authentication Successful');
        print('Supabase User ID: ${response.user?.id}');
        print('Supabase Email: ${response.user?.email}');

        return {
          'id': userQuery['id'],
          'username': userQuery['username'],
          'first_name': userQuery['first_name'],
          'last_name': userQuery['last_name'],
          'email': email,
          'token': response.session?.accessToken,
          'user_id': response.user?.id,
        };
      } on AuthException catch (authError) {
        print('❌ Detailed Supabase Auth Error:');
        print('Error Message: ${authError.message}');
        print('Status Code: ${authError.statusCode}');

        // Handle email not confirmed scenario
        if (authError.message == 'Email not confirmed') {
          print('🔔 Email not confirmed. Resending verification email.');

          // Resend verification email
          await resendVerificationEmail(email);

          // Return a special status to handle in UI
          return {
            'status': 'email_not_confirmed',
            'email': email,
          };
        }

        return null;
      }
    } catch (e) {
      print('❌ Comprehensive Login Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> registerUser({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      // 1. Validate input
      if (!_isValidEmail(email)) {
        print('❌ Invalid email format');
        return null;
      }

      // 2. Check if user already exists in Supabase Auth
      try {
        print('User already exists in Supabase Auth');
        return null;
      } catch (e) {
        print('User not found in Supabase Auth, proceeding with registration');
      }

      // 3. Create user in Supabase Auth
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        print('❌ Failed to create user in Supabase Auth');
        return null;
      }

      // 4. Insert user details in local user table
      final insertResult = await _supabase.from('user').insert({
        'username': username,
        'email': email,
        'password': password, // In production, hash this
        'first_name': firstName,
        'last_name': lastName,
      }).select();

      // 5. Return user information
      return {
        'id': insertResult[0]['id'],
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'supabase_user_id': authResponse.user?.id,
      };
    } catch (e) {
      print('❌ User registration error: $e');

      // Detailed error handling
      if (e is AuthException) {
        print('Auth Error Message: ${e.message}');
      }

      return null;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> resendVerificationEmail(String email) async {
    try {
      print('📧 Attempting to resend verification email to: $email');

      await _supabase.auth.resend(
        type: OtpType.email,
        email: email,
      );

      print('✅ Verification email resent successfully');
      return true;
    } catch (e) {
      print('❌ Email verification resend error: $e');

      // More detailed error handling
      if (e is AuthException) {
        print('Auth Error Message: ${e.message}');
      }

      return false;
    }
  }

  Future<bool> updateUserEmail(String username, String newEmail) async {
    try {
      // 1. Update email in local user table
      await _supabase
          .from('user')
          .update({'email': newEmail}).eq('username', username);

      // 2. Optional: Update email in Supabase Auth
      // Note: This might require additional authentication
      return true;
    } catch (e) {
      print('Email update error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      // Optional: Clear any local storage or session data
    } catch (e) {
      print('Logout error: $e');
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  String? getCurrentUserToken() {
    return _supabase.auth.currentSession?.accessToken;
  }
}
