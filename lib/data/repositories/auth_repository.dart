abstract interface class AuthRepository {
  /// Emits the signed-in uid, or null when signed out.
  Stream<String?> authStateChanges();

  String? get currentUid;

  Future<void> signIn({required String email, required String password});

  /// Creates the auth account, `users/{uid}` (role owner, new share code)
  /// and `users/{uid}/private/contact`.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<void> signOut();
}
