import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true;
  int _userRol = 3; // 3 = Comprador por defecto, 2 = Vendedor

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  int get userRol => _userRol; // Exponemos el rol

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isAuthenticated = await _authService.hasValidToken();
    if (_isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      _userRol = prefs.getInt('user_rol') ?? 3; // Leemos el rol guardado
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      // Si el login es correcto, descargamos el perfil para saber el rol
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userRol = user.rol;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          'user_rol',
          _userRol,
        ); // Guardamos el rol en el teléfono
      }
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_rol'); // Borramos el rol al salir
    _isAuthenticated = false;
    notifyListeners();
  }

  // Exponemos el método register que ya tenías
  Future<bool> register(Map<String, dynamic> userData) async {
    return await _authService.register(userData);
  }
}
