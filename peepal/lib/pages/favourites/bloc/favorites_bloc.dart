import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/favorites/model/favorite.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesStateInitial());

  bool getIsFavorite(PPToilet toilet) {
    if (state is FavoritesStateLoaded) {
      return (state as FavoritesStateLoaded)
          .favorites
          .any((favorite) => favorite.toilet.id == toilet.id);
    }

    return false;
  }

  void loadFavorites() async {
    emit(FavoritesStateLoading());

    try {
      final favorites = await PPClient.favorites.getFavourites();
      emit(FavoritesStateLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesStateError(message: e.toString()));
    }
  }

  void addFavorite(PPToilet toilet) async {
    try {
      await PPClient.favorites.addFavorite(toilet: toilet);
      emit(FavoritesStateLoaded(
          favorites: (state as FavoritesStateLoaded).favorites
            ..add(PPFavorite(toilet: toilet, createdAt: DateTime.now()))));
    } catch (e) {
      emit(FavoritesStateError(message: e.toString()));
    }
  }

  void removeFavorite(PPToilet toilet) async {
    try {
      await PPClient.favorites.removeFavorite(toilet: toilet);
    } catch (e) {
      emit(FavoritesStateError(message: e.toString()));
    }
  }
}
