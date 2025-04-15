part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class FavoritesEventLoad extends FavoritesEvent {
  const FavoritesEventLoad();

  @override
  List<Object?> get props => [];
}

final class FavoritesEventAdd extends FavoritesEvent {
  final PPToilet toilet;

  const FavoritesEventAdd(this.toilet);

  @override
  List<Object?> get props => [toilet];
}

final class FavoritesEventRemove extends FavoritesEvent {
  final PPToilet toilet;

  const FavoritesEventRemove(this.toilet);

  @override
  List<Object?> get props => [toilet];
}

final class FavoritesEventToggle extends FavoritesEvent {
  final PPToilet toilet;

  const FavoritesEventToggle(this.toilet);

  @override
  List<Object?> get props => [toilet];
}
