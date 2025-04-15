part of 'app_bloc.dart';

@immutable
sealed class AppPageState extends Equatable {
  final int index;

  const AppPageState(this.index);

  @override
  List<Object> get props => [index];
}

class AppPageStateHome extends AppPageState {
  const AppPageStateHome() : super(0);
}

class AppPageStateSearch extends AppPageState {
  const AppPageStateSearch() : super(1);
}

class AppPageStateAdd extends AppPageState {
  const AppPageStateAdd() : super(2);
}

class AppPageStateFavorite extends AppPageState {
  const AppPageStateFavorite() : super(3);
}
