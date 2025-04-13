import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/search_results.dart';

part 'search_state.dart';
part 'search_event.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchStateInitial()) {
    on<SearchEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
