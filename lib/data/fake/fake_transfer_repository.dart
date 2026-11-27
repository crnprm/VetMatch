import '../models/health_document.dart';
import '../models/transfer_request.dart';
import '../repositories/repository_exception.dart';
import '../repositories/transfer_repository.dart';
import 'fake_store.dart';

class FakeTransferRepository implements TransferRepository {
  FakeTransferRepository(this._s);

  final FakeStore _s;

  @override
  Stream<List<TransferRequest>> watchIncoming(String uid) => _s.watch(() => [
        for (final t in _s.transferRequests.values)
          if (t.toOwnerId == uid) t,
      ]);

  @override
  Stream<List<TransferRequest>> watchOutgoing(String uid) => _s.watch(() => [
        for (final t in _s.transferRequests.values)
          if (t.fromOwnerId == uid) t,
      ]);

  @override
  Future<void> sendTransfer({
    required String petId,
    required String fromOwnerId,
    required String toOwnerId,
  }) async {
    if (_s.transferRequests[petId]?.status == TransferStatus.pending) {
      throw const RepositoryException('Bu hayvan için zaten bekleyen bir devir isteği var.');
    }
    _s.transferRequests[petId] = TransferRequest(
      petId: petId,
      fromOwnerId: fromOwnerId,
      toOwnerId: toOwnerId,
      status: TransferStatus.pending,
      createdAt: DateTime.now(),
    );
    _s.notify();
  }

  @override
  Future<void> acceptTransfer(String petId) async {
    final t = _s.transferRequests[petId];
    final pet = _s.pets[petId];
    if (t == null || pet == null) return;
    _s.transferRequests[petId] = t.copyWith(status: TransferStatus.accepted);
    _s.pets[petId] = pet.copyWith(ownerId: t.toOwnerId);
    for (final r in _s.healthRecords.values.toList()) {
      if (r.petId != petId) continue;
      _s.healthRecords[r.id] = r.copyWith(ownerId: t.toOwnerId);
      final d = _s.healthDocuments[r.id];
      if (d != null) {
        _s.healthDocuments[r.id] = HealthDocument(
          recordId: d.recordId,
          ownerId: t.toOwnerId,
          vetId: d.vetId,
          imageBase64: d.imageBase64,
        );
      }
    }
    _s.cancelPendingRequests((r) => r.fromPetId == petId || r.toPetId == petId);
    _s.notify();
  }

  void _setStatus(String petId, TransferStatus status) {
    final t = _s.transferRequests[petId];
    if (t == null) return;
    _s.transferRequests[petId] = t.copyWith(status: status);
    _s.notify();
  }

  @override
  Future<void> rejectTransfer(String petId) async =>
      _setStatus(petId, TransferStatus.rejected);

  @override
  Future<void> cancelTransfer(String petId) async =>
      _setStatus(petId, TransferStatus.cancelled);
}
