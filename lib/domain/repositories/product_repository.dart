// domain/repositories/product_repository.dart
// Contrato (interface) que define o que o repositório de produtos deve oferecer.
// A camada de domínio depende apenas desta abstração, nunca da implementação concreta.

import '../entities/product.dart';

abstract class ProductRepository {
  /// Retorna a lista de todos os produtos disponíveis.
  Future<List<Product>> getProducts();

  /// Retorna um único produto pelo [id].
  Future<Product> getProductById(int id);
}
