part of 'favorites_bloc.dart';

sealed class FavoritesState extends Equatable {
  final List<String> favoriteIds;
  const FavoritesState({this.favoriteIds = const []});

  @override
  List<Object?> get props => [favoriteIds];
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
  const FavoritesStateLoaded({required super.favoriteIds});

  FavoritesStateLoaded copyWith({List<String>? favoriteIds}) =>
      FavoritesStateLoaded(favoriteIds: favoriteIds ?? this.favoriteIds);
}
