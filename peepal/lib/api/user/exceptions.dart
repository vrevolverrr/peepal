class PPUserNotFoundError extends Error {
  PPUserNotFoundError();

  @override
  String toString() => 'User not found';
}

class PPUserCredentialsNotAvailableError extends Error {
  PPUserCredentialsNotAvailableError();

  @override
  String toString() => 'User credentials not available';
}
