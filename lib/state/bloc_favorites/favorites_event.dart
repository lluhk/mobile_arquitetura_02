// state/bloc_favorites/favorites_event.dart
abstract class FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final int index;
  ToggleFavoriteEvent(this.index);
}

class ToggleFilterEvent extends FavoritesEvent {}

class SetProductsEvent extends FavoritesEvent {
  final List<dynamic> products;
  SetProductsEvent(this.products);
}
