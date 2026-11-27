import '../models/breed_rule.dart';
import '../models/health_document.dart';
import '../models/health_record.dart';
import '../repositories/health_repository.dart';
import 'fake_store.dart';

class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository(this._s);

  final FakeStore _s;

  @override
  Stream<List<HealthRecord>> watchRecordsOfPets(List<String> petIds) =>
      _s.watch(() => [
            for (final r in _s.healthRecords.values)
              if (petIds.contains(r.petId)) r,
          ]);

  @override
  Stream<List<HealthRecord>> watchPendingRecordsOfVet(String vetId) =>
      _s.watch(() => [
            for (final r in _s.healthRecords.values)
              if (r.vetId == vetId && r.status == HealthStatus.pending) r,
          ]);

  @override
  Future<List<BreedRule>> getBreedRules() async => _s.breedRules.values.toList();

  @override
  Future<String> submitRecord({
    required String petId,
    required String ownerId,
    required String testType,
    required String vetId,
    required String clinicId,
    required String imageBase64,
  }) async {
    final id = _s.newId('record');
    _s.healthRecords[id] = HealthRecord(
      id: id,
      petId: petId,
      ownerId: ownerId,
      testType: testType,
      vetId: vetId,
      clinicId: clinicId,
      status: HealthStatus.pending,
      createdAt: DateTime.now(),
    );
    _s.healthDocuments[id] = HealthDocument(
      recordId: id,
      ownerId: ownerId,
      vetId: vetId,
      imageBase64: imageBase64,
    );
    _s.notify();
    return id;
  }

  void _update(String id, HealthRecord Function(HealthRecord r) change) {
    final r = _s.healthRecords[id];
    if (r == null) return;
    _s.healthRecords[id] = change(r);
    _s.notify();
  }

  @override
  Future<void> withdrawRecord(String recordId) async =>
      _update(recordId, (r) => r.copyWith(status: HealthStatus.withdrawn));

  @override
  Future<void> approveRecord(String recordId, {required DateTime validUntil}) async =>
      _update(
        recordId,
        (r) => r.copyWith(
          status: HealthStatus.approved,
          approvedAt: DateTime.now(),
          validUntil: validUntil,
        ),
      );

  @override
  Future<void> rejectRecord(String recordId, {required String reason}) async =>
      _update(
        recordId,
        (r) => r.copyWith(status: HealthStatus.rejected, rejectionReason: reason),
      );

  @override
  Future<HealthDocument?> getDocument(String recordId) async {
    final d = _s.healthDocuments[recordId];
    final me = _s.currentUid;
    if (d == null || (me != d.ownerId && me != d.vetId)) return null;
    return d;
  }
}
