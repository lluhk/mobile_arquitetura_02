// state/bloc_favorites/favorites_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesBlocState> {
  FavoritesBloc() : super(FavoritesBlocState(products: [])) {
    on<SetProductsEvent>((event, emit) {
      final favIds = state.products
          .where((p) => p.favorite)
          .map((p) => p.id)
          .toSet();
      final updated = (event.products as List<Product>).map((p) {
        p.favorite = favIds.contains(p.id);
        return p;
      }).toList();
      emit(FavoritesBlocState(
        products: updated,
        showFavoritesOnly: state.showFavoritesOnly,
      ));
    });

    on<ToggleFavoriteEvent>((event, emit) {
      final updated = List<Product>.from(state.products);
      updated[event.index].favorite = !updated[event.index].favorite;
      emit(FavoritesBlocState(
        products: updated,
        showFavoritesOnly: state.showFavoritesOnly,
      ));
    });

    on<ToggleFilterEvent>((event, emit) {
      emit(FavoritesBlocState(
        products: state.products,
        showFavoritesOnly: !state.showFavoritesOnly,
      ));
    });
  }
}
