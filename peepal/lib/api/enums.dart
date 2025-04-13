enum PPSortOrder {
  asc('asc'),
  desc('desc');

  final String value;
  const PPSortOrder(this.value);
}

enum PPSortField {
  date('date'),
  rating('rating');

  final String value;
  const PPSortField(this.value);
}
