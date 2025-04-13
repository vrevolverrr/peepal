part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  final List<PPSearchResult> results;

  const SearchState({this.results = const []});

  @override
  List<Object?> get props => [results];
}

final class SearchStateInitial extends SearchState {
  const SearchStateInitial();
}

final class SearchStateLoading extends SearchState {
  const SearchStateLoading();
}

final class SearchStateError extends SearchState {
  final String error;

  const SearchStateError({required this.error});
}
