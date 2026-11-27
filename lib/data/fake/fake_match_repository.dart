import '../models/contact_share.dart';
import '../models/match_request.dart';
import '../models/pet.dart';
import '../models/spam_sender.dart';
import '../repositories/match_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_block_repository.dart';
import 'fake_store.dart';

/// Simplified: the 30-day wait and spam counting arrive with lib/domain/
/// in Phase 3.
class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository(this._s);

  final FakeStore _s;

  @override
  Stream<List<MatchRequest>> watchIncoming(String uid) => _s.watch(() => [
        for (final r in _s.matchRequests.values)
          if (r.toOwnerId == uid) r,
      ]);

  @override
  Stream<List<MatchRequest>> watchOutgoing(String uid) => _s.watch(() => [
        for (final r in _s.matchRequests.values)
          if (r.fromOwnerId == uid) r,
      ]);

  @override
  Future<void> sendRequest({required Pet fromPet, required Pet toPet}) async {
    final id = MatchRequest.idFor(fromPet.id, toPet.id);
    final existing = _s.matchRequests[id];
    final blocked = _s.blocks[toPet.ownerId]?.contains(fromPet.ownerId) ?? false;
    if (blocked ||
        existing?.status == MatchStatus.pending ||
        existing?.status == MatchStatus.accepted) {
      throw const RepositoryException('İstek gönderilemedi.');
    }
    final now = DateTime.now();
    _s.matchRequests[id] = MatchRequest(
      fromPetId: fromPet.id,
      toPetId: toPet.id,
      fromOwnerId: fromPet.ownerId,
      toOwnerId: toPet.ownerId,
      status: MatchStatus.pending,
      createdAt: now,
      resendAllowed: false,
      sendCount: 1,
      windowStart: now,
    );
    _s.notify();
  }

  void _update(String id, MatchRequest Function(MatchRequest r) change) {
    final r = _s.matchRequests[id];
    if (r == null) return;
    _s.matchRequests[id] = change(r);
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final r = _s.matchRequests[requestId];
    if (r == null) return;
    _s.matchRequests[requestId] = r.copyWith(status: MatchStatus.accepted);
    final share = ContactShare(
      userIds: ([r.fromOwnerId, r.toOwnerId]..sort()),
      matchRequestId: requestId,
      createdAt: DateTime.now(),
    );
    _s.contactShares[share.id] = share;
    _s.notify();
  }

  @override
  Future<void> rejectRequest(String requestId, {bool block = false}) async {
    final r = _s.matchRequests[requestId];
    if (r == null) return;
    _s.matchRequests[requestId] =
        r.copyWith(status: MatchStatus.rejected, rejectedAt: DateTime.now());
    if (block) blockInStore(_s, r.toOwnerId, r.fromOwnerId);
    _s.notify();
  }

  @override
  Future<void> withdrawRequest(String requestId) async {
    _update(requestId, (r) => r.copyWith(status: MatchStatus.withdrawn));
    _s.notify();
  }

  @override
  Future<void> allowResend(String requestId) async {
    _update(requestId, (r) => r.copyWith(resendAllowed: true));
    _s.notify();
  }

  @override
  Stream<List<SpamSender>> watchSpamSenders(String uid) =>
      _s.watch(() => (_s.spamSenders[uid] ?? {}).values.toList());

  @override
  Future<void> markNotSpam(String uid, String senderUid) async {
    _s.spamSenders[uid]?.remove(senderUid);
    _s.notify();
  }
}
