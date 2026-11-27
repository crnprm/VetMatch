/// Thrown by repositories for expected failures. [message] is Turkish and
/// can be shown to the user as is.
class RepositoryException implements Exception {
  const RepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
