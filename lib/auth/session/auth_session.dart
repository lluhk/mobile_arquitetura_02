// auth/session/auth_session.dart
//
// Gerencia a sessão do usuário autenticado em memória e em disco.
//
// Responsabilidades:
//   - Manter o usuário logado acessível via [currentUser]
//   - Persistir o JSON do usuário com shared_preferences (Desafio Extra — item 1)
//   - Verificar sessão ativa na inicialização do app (Desafio Extra — item 4)
//   - Notificar ouvintes via ChangeNotifier ao logar/deslogar

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

const _kUserKey = 'auth_user';

class AuthSession extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Inicializa a sessão lendo o cache salvo em disco.
  /// Chamado uma vez em [main] antes de runApp.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserKey);
    if (raw != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(raw));
      } catch (_) {
        await prefs.remove(_kUserKey);
      }
    }
  }

  /// Salva o usuário autenticado em memória e em disco.
  Future<void> login(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
    notifyListeners();
  }

  /// Remove o usuário da memória e do disco.
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
    notifyListeners();
  }
}
