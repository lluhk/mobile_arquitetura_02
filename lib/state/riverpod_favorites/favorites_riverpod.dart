// state/riverpod_favorites/favorites_riverpod.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';

class FavoritesState {
  final List<Product> products;
  final bool showFavoritesOnly;

  FavoritesState({required this.products, this.showFavoritesOnly = false});

  List<Product> get displayed => showFavoritesOnly
      ? products.where((p) => p.favorite).toList()
      : List.unmodifiable(products);

  int get favoriteCount => products.where((p) => p.favorite).length;

  FavoritesState copyWith({List<Product>? products, bool? showFavoritesOnly}) {
    return FavoritesState(
      products: products ?? this.products,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(FavoritesState(products: []));

  void setProducts(List<Product> products) {
    final favIds = state.products
        .where((p) => p.favorite)
        .map((p) => p.id)
        .toSet();
    final updated = products.map((p) {
      p.favorite = favIds.contains(p.id);
      return p;
    }).toList();
    state = state.copyWith(products: updated);
  }

  void toggleFavorite(int index) {
    final updated = List<Product>.from(state.products);
    updated[index].favorite = !updated[index].favorite;
    state = state.copyWith(products: updated);
  }

  void toggleFilter() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>(
  (ref) => FavoritesNotifier(),
);
