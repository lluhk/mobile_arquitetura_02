// core/errors/app_error.dart
//
// Hierarquia de erros tipados da aplicação.
// Centralizar os erros aqui evita que strings de mensagem fiquem espalhadas
// pelo código e permite que a UI tome decisões com base no tipo do erro.

abstract class AppError implements Exception {
  final String message;
  const AppError(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Sem conectividade com a internet ou timeout.
class NetworkError extends AppError {
  const NetworkError([String message = 'Sem conexão com a internet.'])
      : super(message);
}

/// O servidor respondeu com status HTTP de erro.
class ServerError extends AppError {
  final int? statusCode;
  const ServerError({this.statusCode, String message = 'Erro no servidor.'})
      : super(message);
}

/// Falha ao desserializar o JSON recebido.
class ParseError extends AppError {
  const ParseError([String message = 'Erro ao processar os dados recebidos.'])
      : super(message);
}

/// Qualquer outro erro não mapeado.
class UnknownError extends AppError {
  const UnknownError([String message = 'Ocorreu um erro inesperado.'])
      : super(message);
}
