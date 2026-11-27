import '../models/contact_share.dart';
import '../repositories/block_repository.dart';
import 'fake_store.dart';

class FakeBlockRepository implements BlockRepository {
  FakeBlockRepository(this._s);

  final FakeStore _s;

  @override
  Stream<Set<String>> watchBlocked(String uid) =>
      _s.watch(() => {...?_s.blocks[uid]});

  @override
  Future<void> block(String uid, String otherUid) async {
    blockInStore(_s, uid, otherUid);
    _s.notify();
  }

  @override
  Future<void> unblock(String uid, String otherUid) async {
    _s.blocks[uid]?.remove(otherUid);
    _s.notify();
  }
}

/// Shared with "reject and block". Does not notify.
void blockInStore(FakeStore s, String uid, String otherUid) {
  (s.blocks[uid] ??= {}).add(otherUid);
  s.cancelPendingRequests((r) =>
      (r.fromOwnerId == uid && r.toOwnerId == otherUid) ||
      (r.fromOwnerId == otherUid && r.toOwnerId == uid));
  s.contactShares.remove(ContactShare.idFor(uid, otherUid));
  s.spamSenders[uid]?.remove(otherUid);
}
