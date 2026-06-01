// auth/services/auth_service.dart
//
// Responsável pelas chamadas HTTP de autenticação à DummyJSON:
//   POST /auth/login  → login com credenciais
//   GET  /auth/me     → perfil do usuário autenticado (desafio extra)
//
// Classe auxiliar HttpHeaders centraliza a montagem de cabeçalhos com token.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// Classe auxiliar que monta cabeçalhos HTTP com ou sem token JWT.
/// (Desafio Extra — item 5)
class AppHeaders {
  static Map<String, String> json() => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> withToken(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}

class AuthService {
  static const _baseUrl = 'https://dummyjson.com';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Autentica o usuário com username e password.
  /// Lança [AuthException] em caso de credenciais inválidas.
  /// Lança [Exception] em caso de falha de rede ou servidor.
  Future<UserModel> login(String username, String password) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: AppHeaders.json(),
          body: jsonEncode({
            'username': username,
            'password': password,
            'expiresInMins': 60,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    }

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw AuthException('Usuário ou senha inválidos.');
    }

    throw Exception('Erro ao autenticar: ${response.statusCode}');
  }

  /// Busca os dados do perfil do usuário autenticado via token.
  /// (Desafio Extra — item 2)
  Future<UserModel> fetchProfile(String token) async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/auth/me'),
          headers: AppHeaders.withToken(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // /auth/me não retorna token — preservamos o existente
      final merged = {...data, 'accessToken': token, 'refreshToken': ''};
      return UserModel.fromJson(merged);
    }

    throw Exception('Erro ao buscar perfil: ${response.statusCode}');
  }
}

/// Exceção lançada quando as credenciais são inválidas.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
