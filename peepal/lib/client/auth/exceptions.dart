class PPNotAuthenticatedError extends Error {
  PPNotAuthenticatedError();

  @override
  String toString() => 'User is not authenticated';
}

class PPInvalidCredentialsError extends Error {
  PPInvalidCredentialsError();

  @override
  String toString() => 'Invalid credentials';
}

class PPUnexpectedServerError extends Error {
  final String message;
  PPUnexpectedServerError({required this.message});

  @override
  String toString() => 'Unexpected server error: $message';
}

class PPBadRequestError extends Error {
  final String message;
  PPBadRequestError({required this.message});

  @override
  String toString() => message;
}

class PPUnexpectedError extends Error {
  final String message;
  PPUnexpectedError({required this.message});

  @override
  String toString() => 'Unexpected error: $message';
}

class PPUserAlreadyExistsError extends Error {
  PPUserAlreadyExistsError();

  @override
  String toString() => 'User already exists';
}
