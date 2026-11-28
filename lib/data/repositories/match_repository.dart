import '../models/match_request.dart';
import '../models/pet.dart';
import '../models/spam_sender.dart';

abstract interface class MatchRepository {
  Stream<List<MatchRequest>> watchIncoming(String uid);

  Stream<List<MatchRequest>> watchOutgoing(String uid);

  /// Sends a new request or resends over an old one for the same pet pair.
  /// Throws [RepositoryException] if sending is not allowed.
  Future<void> sendRequest({required Pet fromPet, required Pet toPet});

  /// Accepts and creates the contact share in the same batch.
  Future<void> acceptRequest(String requestId);

  /// With [block], also blocks the sender in the same batch.
  Future<void> rejectRequest(String requestId, {bool block = false});

  /// Sender takes back a pending request.
  Future<void> withdrawRequest(String requestId);

  /// Receiver lifts the 30-day wait on a rejected request.
  Future<void> allowResend(String requestId);

  Stream<List<SpamSender>> watchSpamSenders(String uid);

  Future<void> markNotSpam(String uid, String senderUid);
}
