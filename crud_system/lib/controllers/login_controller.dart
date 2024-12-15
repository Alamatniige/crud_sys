// login_controller.dart
import '../models/user_model.dart';
import '../middleware/middleware.dart';

class LoginController {
  final UserModel _userModel = UserModel();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final result = await _userModel.login(email, password);

    if (result != null) {
      // Validate token after login
      final isValidToken = await AuthMiddleware.validateToken(result['token']);
      if (!isValidToken) {
        return null;
      }
    }

    return result;
  }

  void logout() {
    _userModel.logout();
  }

  bool isLoggedIn() {
    return _userModel.isLoggedIn();
  }

  Future<void> refreshToken() async {
    await AuthMiddleware.refreshToken();
  }
}
