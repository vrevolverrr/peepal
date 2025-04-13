import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class PPImage extends Equatable {
  final String token;

  const PPImage({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}
