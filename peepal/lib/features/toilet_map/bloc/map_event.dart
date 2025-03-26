part of 'map_bloc.dart';

@immutable
sealed class ToiletMapEvent extends Equatable {
  const ToiletMapEvent();

  @override
  List<Object> get props => [];
}

final class ToiletMapEventInit extends ToiletMapEvent {
  const ToiletMapEventInit();
}

final class ToiletMapEventReady extends ToiletMapEvent {
  const ToiletMapEventReady();
}

final class ToiletMapEventLoaded extends ToiletMapEvent {
  const ToiletMapEventLoaded();
}

final class ToiletMapSearchQueryChanged extends ToiletMapEvent {
  final String query;

  const ToiletMapSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}
