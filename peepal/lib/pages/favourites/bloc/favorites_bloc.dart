import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/favorites/model/favorite.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';

part 'favorites_state.dart';
part 'favorites_event.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final ToiletsBloc toiletsBloc;

  FavoritesBloc({required this.toiletsBloc}) : super(FavoritesStateInitial()) {
    on<FavoritesEventLoad>(_onLoadFavorites);
    on<FavoritesEventAdd>(_onAddFavorite);
    on<FavoritesEventRemove>(_onRemoveFavorite);
    on<FavoritesEventToggle>(_onToggleFavorite);
  }

  void _onLoadFavorites(
      FavoritesEventLoad event, Emitter<FavoritesState> emit) async {
    emit(FavoritesStateLoading());

    try {
      final List<PPFavorite> favorites =
          await PPClient.favorites.getFavourites();

      final favoriteIds = favorites.map((f) => f.toiletId).toList();

      toiletsBloc.add(ToiletEventFetchToiletById(toiletIds: favoriteIds));

      emit(FavoritesStateLoaded(favoriteIds: favoriteIds));
    } catch (e) {
      emit(FavoritesStateError(message: e.toString()));
    }
  }

  void _onAddFavorite(
      FavoritesEventAdd event, Emitter<FavoritesState> emit) async {
    try {
      await PPClient.favorites.addFavorite(toilet: event.toilet);

      emit(FavoritesStateLoaded(
          favoriteIds: {...state.favoriteIds, event.toilet.id}.toList()));
    } catch (e) {
      emit(FavoritesStateError(message: e.toString()));
    }
  }

  void _onRemoveFavorite(
      FavoritesEventRemove event, Emitter<FavoritesState> emit) async {
    try {
      await PPClient.favorites.removeFavorite(toilet: event.toilet);

      emit(FavoritesStateLoaded(
          favoriteIds:
              state.favoriteIds.where((id) => id != event.toilet.id).toList()));
    } catch (e) {
      emit(FavoritesStateError(message: e.toString()));
    }
  }

  void _onToggleFavorite(
      FavoritesEventToggle event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesStateLoaded) {
      final isFavorite = state.favoriteIds.contains(event.toilet.id);

      try {
        if (isFavorite) {
          await PPClient.favorites.removeFavorite(toilet: event.toilet);
          emit(FavoritesStateLoaded(
              favoriteIds: state.favoriteIds
                  .where((id) => id != event.toilet.id)
                  .toList()));
        } else {
          await PPClient.favorites.addFavorite(toilet: event.toilet);
          emit(FavoritesStateLoaded(
              favoriteIds: [...state.favoriteIds, event.toilet.id].toList()));
        }
      } catch (e) {
        emit(FavoritesStateError(message: e.toString()));
      }
    }
  }
}
