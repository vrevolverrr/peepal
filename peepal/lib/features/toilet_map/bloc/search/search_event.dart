part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchEventSearch extends SearchEvent {
  final String query;

  const SearchEventSearch(this.query);

  @override
  List<Object?> get props => [query];
}
