// core/cache/product_cache.dart
//
// Cache em memória simples para produtos.
// Fica na camada `core` porque é um utilitário de infraestrutura reutilizável,
// sem conhecimento de regras de negócio.
//
// A decisão de usar o cache pertence ao REPOSITORY (camada data), não à UI.

import '../../domain/entities/product.dart';

class ProductCache {
  // Singleton leve — uma única instância por execução do app.
  static final ProductCache _instance = ProductCache._internal();
  factory ProductCache() => _instance;
  ProductCache._internal();

  List<Product>? _products;
  DateTime? _cachedAt;

  /// Tempo máximo que o cache é considerado válido (5 minutos).
  static const _ttl = Duration(minutes: 5);

  /// Retorna os produtos em cache se ainda forem válidos, senão `null`.
  List<Product>? get products {
    if (_products == null || _cachedAt == null) return null;
    final expired = DateTime.now().difference(_cachedAt!) > _ttl;
    return expired ? null : _products;
  }

  /// Retorna os dados em cache independente da validade (fallback de erro).
  List<Product>? get staleProducts => _products;

  bool get hasData => _products != null && _products!.isNotEmpty;

  /// Salva os produtos no cache e registra o horário.
  void save(List<Product> products) {
    _products = List.unmodifiable(products);
    _cachedAt = DateTime.now();
  }

  /// Invalida o cache manualmente (ex: ao forçar atualização).
  void invalidate() {
    _products = null;
    _cachedAt = null;
  }

  /// Informa há quanto tempo os dados foram salvos (para exibir na UI).
  String? get cacheAge {
    if (_cachedAt == null) return null;
    final diff = DateTime.now().difference(_cachedAt!);
    if (diff.inMinutes < 1) return 'há menos de 1 minuto';
    if (diff.inMinutes == 1) return 'há 1 minuto';
    return 'há ${diff.inMinutes} minutos';
  }
}
