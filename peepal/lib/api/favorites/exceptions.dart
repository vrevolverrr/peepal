class PPFavoriteNotFoundError extends Error {
  PPFavoriteNotFoundError();

  @override
  String toString() => 'Favorite record not found';
}
