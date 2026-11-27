abstract interface class BlockRepository {
  Stream<Set<String>> watchBlocked(String uid);

  /// Also cancels pending requests between the two users and removes their
  /// contact share and spam flag, in one batch.
  Future<void> block(String uid, String otherUid);

  Future<void> unblock(String uid, String otherUid);
}
