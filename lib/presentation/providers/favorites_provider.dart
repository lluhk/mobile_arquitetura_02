// presentation/providers/favorites_provider.dart
//
// Gerenciamento de favoritos com Provider (Atividade 05).
// Recebe a lista de produtos já carregados da API e gerencia
// o estado de favorito de cada um localmente.

import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _showFavoritesOnly = false;

  /// Inicializa o provider com os produtos vindos da API
  void setProducts(List<Product> products) {
    // Preserva o estado de favorito ao recarregar
    final favIds = _products.where((p) => p.favorite).map((p) => p.id).toSet();
    _products = products.map((p) {
      p.favorite = favIds.contains(p.id);
      return p;
    }).toList();
    notifyListeners();
  }

  /// Lista completa (para cálculo de índice original)
  List<Product> get allProducts => List.unmodifiable(_products);

  /// Lista exibida conforme o filtro ativo
  List<Product> get displayed => _showFavoritesOnly
      ? _products.where((p) => p.favorite).toList()
      : List.unmodifiable(_products);

  int get favoriteCount => _products.where((p) => p.favorite).length;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get hasProducts => _products.isNotEmpty;

  void toggleFavorite(int originalIndex) {
    _products[originalIndex].favorite = !_products[originalIndex].favorite;
    notifyListeners();
  }

  void toggleFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }
}
