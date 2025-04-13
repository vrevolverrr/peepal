part of 'toilet_map_bloc.dart';

final class ToiletMapState extends Equatable {
  final Set<Marker> toiletMarkers;
  final PPToilet? selectedToilet;
  final Set<Polyline> activePolylines;
  final PPRoute? activeRoute;

  const ToiletMapState({
    this.toiletMarkers = const {},
    this.selectedToilet,
    this.activePolylines = const {},
    this.activeRoute,
  });

  ToiletMapState copyWith(
      {required PPToilet? selectedToilet,
      Set<Marker>? toiletMarkers,
      Set<Polyline>? activePolylines,
      PPRoute? activeRoute}) {
    return ToiletMapState(
      selectedToilet: selectedToilet,
      toiletMarkers: toiletMarkers ?? this.toiletMarkers,
      activePolylines: activePolylines ?? this.activePolylines,
      activeRoute: activeRoute ?? this.activeRoute,
    );
  }

  @override
  List<Object> get props =>
      [toiletMarkers, selectedToilet ?? const {}, activePolylines];
}
