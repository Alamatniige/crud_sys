// middleware.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMiddleware {
  static Future<bool> validateToken(String? token) async {
    if (token == null) return false;

    try {
      // Verify the token's validity
      final SupabaseClient supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      return user != null;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  static Future<void> refreshToken() async {
    final SupabaseClient supabase = Supabase.instance.client;
    try {
      await supabase.auth.refreshSession();
    } catch (e) {
      print('Token refresh error: $e');
    }
  }
}
