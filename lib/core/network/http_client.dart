// core/network/http_client.dart
//
// Abstração do cliente HTTP — toda comunicação de rede passa por aqui.
// Converter exceções do pacote `http` em AppError é responsabilidade desta classe,
// garantindo que as camadas superiores nunca precisem importar `dart:io` ou `http`.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/app_error.dart';

class AppHttpClient {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  AppHttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw ServerError(
        statusCode: response.statusCode,
        message: 'Servidor retornou status ${response.statusCode}.',
      );
    } on SocketException {
      throw const NetworkError('Sem conexão com a internet.');
    } on TimeoutException {
      throw const NetworkError('A requisição demorou demais. Tente novamente.');
    } on ServerError {
      rethrow;
    } on FormatException {
      throw const ParseError('Resposta da API em formato inválido.');
    } catch (e) {
      throw UnknownError('Erro inesperado: $e');
    }
  }
}
