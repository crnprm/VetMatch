import '../models/breed_rule.dart';
import '../models/health_document.dart';
import '../models/health_record.dart';

abstract interface class HealthRepository {
  Stream<List<HealthRecord>> watchRecordsOfPets(List<String> petIds);

  Stream<List<HealthRecord>> watchPendingRecordsOfVet(String vetId);

  Future<List<BreedRule>> getBreedRules();

  /// Writes `healthRecords/{id}` (pending) and `healthDocuments/{id}` in one
  /// batch. Returns the record id.
  Future<String> submitRecord({
    required String petId,
    required String ownerId,
    required String testType,
    required String vetId,
    required String clinicId,
    required String imageBase64,
  });

  Future<void> withdrawRecord(String recordId);

  Future<void> approveRecord(String recordId, {required DateTime validUntil});

  Future<void> rejectRecord(String recordId, {required String reason});

  /// Only the owner and the selected vet can read it.
  Future<HealthDocument?> getDocument(String recordId);
}
