// presentation/providers/product_provider.dart
//
// ViewModel da aplicação — coordena o ESTADO da UI.
//
// POR QUE O VIEWMODEL NÃO FAZ HTTP DIRETAMENTE?
// O ViewModel não deve fazer chamadas HTTP porque isso violaria a separação de
// responsabilidades: ele ficaria acoplado à infraestrutura de rede, impossibilitando
// testar o estado da UI de forma isolada. Se a API mudar, o ViewModel também mudaria,
// quebrando o princípio de responsabilidade única.
//
// Estados representados explicitamente:
//   initial   → app recém aberto, nenhuma ação ainda
//   loading   → requisição em andamento
//   loaded    → dados disponíveis (da API)
//   error     → falha sem dados de fallback
//   stale     → falha mas com dados antigos do cache disponíveis

import 'package:flutter/foundation.dart';
import '../../core/errors/app_error.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// Estado explícito da interface — cada tela sabe exatamente o que renderizar.
enum ProductStatus { initial, loading, loaded, error, stale }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductRepositoryImpl? get _repoImpl =>
      _repository is ProductRepositoryImpl
          ? _repository as ProductRepositoryImpl
          : null;

  ProductProvider({required ProductRepository repository})
      : _repository = repository;

  ProductStatus _status = ProductStatus.initial;
  List<Product> _products = [];
  AppError? _error;
  bool _usingCache = false;
  String? _cacheAge;

  ProductStatus get status => _status;
  List<Product> get products => _products;
  AppError? get error => _error;
  bool get usingCache => _usingCache;
  String? get cacheAge => _cacheAge;

  String get errorMessage {
    if (_error == null) return '';
    return switch (_error) {
      NetworkError() =>
        'Sem conexão com a internet.\nVerifique sua rede e tente novamente.',
      ServerError(statusCode: final code) =>
        'O servidor retornou um erro${code != null ? " ($code)" : ""}.\nTente novamente mais tarde.',
      ParseError() => 'Não foi possível processar os dados recebidos.',
      _ => _error!.message,
    };
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (forceRefresh) _repoImpl?.invalidateCache();

    _status = ProductStatus.loading;
    _error = null;
    _usingCache = false;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
      _usingCache = false;
      _cacheAge = null;
      _status = ProductStatus.loaded;
    } on AppError catch (e) {
      _error = e;
      final stale = _repoImpl?.cachedProducts;
      if (stale != null && stale.isNotEmpty) {
        _products = stale;
        _cacheAge = _repoImpl?.cacheAge;
        _usingCache = true;
        _status = ProductStatus.stale;
      } else {
        _products = [];
        _status = ProductStatus.error;
      }
    }

    notifyListeners();
  }
}
