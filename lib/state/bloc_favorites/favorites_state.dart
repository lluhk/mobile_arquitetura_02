// state/bloc_favorites/favorites_state.dart
import '../../domain/entities/product.dart';

class FavoritesBlocState {
  final List<Product> products;
  final bool showFavoritesOnly;

  FavoritesBlocState({required this.products, this.showFavoritesOnly = false});

  List<Product> get displayed => showFavoritesOnly
      ? products.where((p) => p.favorite).toList()
      : List.unmodifiable(products);

  int get favoriteCount => products.where((p) => p.favorite).length;
}
