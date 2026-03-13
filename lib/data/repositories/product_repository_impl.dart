// data/repositories/product_repository_impl.dart
//
// Implementação concreta do contrato definido no domínio.
//
// DECISÃO DE CACHE: o repositório é o lugar correto para decidir de onde os dados
// vêm — rede ou cache. A UI não sabe (nem precisa saber) essa lógica.
// O ViewModel também não deve tomar essa decisão: ele coordena estado, não IO.

import '../../core/cache/product_cache.dart';
import '../../core/errors/app_error.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductCache _cache;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    ProductCache? cache,
  })  : _remoteDataSource = remoteDataSource,
        _cache = cache ?? ProductCache();

  @override
  Future<List<Product>> getProducts() async {
    // 1. Cache válido (dentro do TTL)? Retorna direto sem bater na API.
    final cached = _cache.products;
    if (cached != null) return cached;

    try {
      // 2. Busca na API e atualiza o cache.
      final models = await _remoteDataSource.getProducts();
      final entities = models.map((m) => m.toEntity()).toList();
      _cache.save(entities);
      return entities;
    } on AppError {
      // 3. API falhou — se tiver dados antigos (stale), usa como fallback.
      final stale = _cache.staleProducts;
      if (stale != null && stale.isNotEmpty) {
        // Propaga o erro mas com os dados antigos disponíveis.
        // O provider vai usar staleProducts para mostrar cache + banner de aviso.
        rethrow;
      }
      // 4. Sem cache e sem rede — propaga o erro normalmente.
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      final model = await _remoteDataSource.getProductById(id);
      return model.toEntity();
    } on AppError {
      rethrow;
    }
  }

  /// Expõe o cache para o provider saber se há dados de fallback disponíveis.
  bool get hasCachedData => _cache.hasData;
  List<Product>? get cachedProducts => _cache.staleProducts;
  String? get cacheAge => _cache.cacheAge;

  /// Invalida o cache forçando uma nova requisição na próxima chamada.
  void invalidateCache() => _cache.invalidate();
}
