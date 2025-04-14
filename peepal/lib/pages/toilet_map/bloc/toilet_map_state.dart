part of 'toilet_map_bloc.dart';

final class ToiletMapState extends Equatable {
  final Set<Annotation> toiletMarkers;
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
      Set<Annotation>? toiletMarkers,
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
      [toiletMarkers, selectedToilet ?? 0, activePolylines, activeRoute ?? 0];
}
