import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true; // Para mostrar pantalla de carga al inicio

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    checkAuthStatus();
  }

  // Al abrir la app, revisa si ya iniciaste sesión antes
  Future<void> checkAuthStatus() async {
    _isAuthenticated = await _authService.hasValidToken();
    _isLoading = false;
    notifyListeners(); // Avisa a la app para que actualice la pantalla
  }

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    return await _authService.register(userData);
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
