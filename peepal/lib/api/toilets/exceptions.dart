class PPToiletNotFoundError extends Error {
  PPToiletNotFoundError();

  @override
  String toString() => 'Toilet with specified ID not found';
}

class PPToiletRouteNotFoundError extends Error {
  PPToiletRouteNotFoundError();

  @override
  String toString() =>
      'No route found from specified location to specified toilet';
}
