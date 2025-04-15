part of 'favorites_bloc.dart';

sealed class FavoritesState extends Equatable {
  final List<PPFavorite> favorites;
  const FavoritesState({this.favorites = const []});

  @override
  List<Object?> get props => [favorites];
}

final class FavoritesStateInitial extends FavoritesState {
  const FavoritesStateInitial();

  @override
  List<Object?> get props => [];
}

final class FavoritesStateError extends FavoritesState {
  final String message;

  const FavoritesStateError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class FavoritesStateLoading extends FavoritesState {
  const FavoritesStateLoading();

  @override
  List<Object?> get props => [];
}

final class FavoritesStateLoaded extends FavoritesState {
  const FavoritesStateLoaded({
    required super.favorites,
  });
}
