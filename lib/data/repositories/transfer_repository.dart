import '../models/transfer_request.dart';

abstract interface class TransferRepository {
  Stream<List<TransferRequest>> watchIncoming(String uid);

  Stream<List<TransferRequest>> watchOutgoing(String uid);

  Future<void> sendTransfer({
    required String petId,
    required String fromOwnerId,
    required String toOwnerId,
  });

  /// Moves the pet, its health records and documents to the new owner and
  /// cancels the pet's pending match requests, in one batch.
  Future<void> acceptTransfer(String petId);

  Future<void> rejectTransfer(String petId);

  /// Sender takes back a pending transfer.
  Future<void> cancelTransfer(String petId);
}
