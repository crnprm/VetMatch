import 'package:latlong2/latlong.dart';

import '../models/app_user.dart';
import '../models/breed_rule.dart';
import '../models/clinic.dart';
import '../models/health_document.dart';
import '../models/health_record.dart';
import '../models/match_request.dart';
import '../models/pet.dart';
import '../models/review.dart';
import '../models/spam_sender.dart';
import '../models/species.dart';
import 'fake_store.dart';

/// Password of every fake account.
const fakePassword = 'test1234';

/// A 1x1 PNG, so the vet screen has an image to show.
const _tinyImage =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

/// Fills [store] with fictional demo data. Accounts:
/// - sahip1@vetmatch.test  Ayşe   (Sfenks Pamuk, eligible; incoming request)
/// - sahip2@vetmatch.test  Mehmet (Sfenks Duman, eligible; sent the request)
/// - sahip3@vetmatch.test  Zeynep (Golden Altın, one pending test; in Ayşe's spam box)
/// - vet1@vetmatch.test    Dr. Ece Kaya  (Kayısı Veteriner Kliniği)
/// - vet2@vetmatch.test    Dr. Can Demir (Fırat Hayvan Hastanesi)
FakeStore seedFakeStore({DateTime? now}) {
  final t = now ?? DateTime.now();
  final s = FakeStore();

  void account(String email, AppUser user, String phone) {
    s.accounts[email] = (uid: user.id, password: fakePassword);
    s.users[user.id] = user;
    s.phones[user.id] = phone;
  }

  account('sahip1@vetmatch.test',
      const AppUser(id: 'owner1', role: UserRole.owner, name: 'Ayşe Yılmaz', shareCode: 'VM-A1B2'),
      '+905550000001');
  account('sahip2@vetmatch.test',
      const AppUser(id: 'owner2', role: UserRole.owner, name: 'Mehmet Öz', shareCode: 'VM-C3D4'),
      '+905550000002');
  account('sahip3@vetmatch.test',
      const AppUser(id: 'owner3', role: UserRole.owner, name: 'Zeynep Ak', shareCode: 'VM-E5F6'),
      '+905550000003');
  account('vet1@vetmatch.test',
      const AppUser(id: 'vet1', role: UserRole.vet, name: 'Dr. Ece Kaya', shareCode: 'VM-V1V1', clinicId: 'clinic1'),
      '+905550000011');
  account('vet2@vetmatch.test',
      const AppUser(id: 'vet2', role: UserRole.vet, name: 'Dr. Can Demir', shareCode: 'VM-V2V2', clinicId: 'clinic2'),
      '+905550000012');

  for (final c in [
    const Clinic(
      id: 'clinic1',
      name: 'Kayısı Veteriner Kliniği',
      location: LatLng(38.3554, 38.3335),
      species: [Species.cat, Species.dog],
      capabilities: ['echocardiography', 'ultrasound', 'xray'],
    ),
    const Clinic(
      id: 'clinic2',
      name: 'Fırat Hayvan Hastanesi',
      location: LatLng(38.3401, 38.2853),
      species: [Species.cat, Species.dog],
      capabilities: ['xray', 'surgery', 'emergency_24h', 'eye_exam'],
    ),
    const Clinic(
      id: 'clinic3',
      name: 'Patiler Veteriner Polikliniği',
      location: LatLng(38.3682, 38.3101),
      species: [Species.cat],
      capabilities: ['ultrasound'],
    ),
    const Clinic(
      id: 'clinic4',
      name: 'Beydağı Egzotik Hayvan Kliniği',
      location: LatLng(38.3297, 38.3418),
      species: [Species.cat, Species.dog],
      capabilities: ['exotic', 'xray'],
    ),
  ]) {
    s.clinics[c.id] = c;
  }

  s.reviews['clinic1'] = {
    'owner2': Review(
      clinicId: 'clinic1',
      authorId: 'owner2',
      authorName: 'Mehmet Öz',
      rating: 5,
      comment: 'Ekokardiyografi için randevu hızlı verildi.',
      createdAt: t.subtract(const Duration(days: 20)),
    ),
  };

  // Demo values; see the open issue in PLAN.md about verifying them.
  s.breedRules['sphynx'] = const BreedRule(
    id: 'sphynx',
    species: Species.cat,
    breed: 'Sfenks',
    requiredTests: [RequiredTest(testType: 'hcm_echo', validityMonths: 12)],
    minAgeMonths: 12,
    maxAgeMonths: 84,
  );
  s.breedRules['golden_retriever'] = const BreedRule(
    id: 'golden_retriever',
    species: Species.dog,
    breed: 'Golden Retriever',
    requiredTests: [
      RequiredTest(testType: 'hip_elbow', validityMonths: 96),
      RequiredTest(testType: 'eye_exam', validityMonths: 12),
    ],
    minAgeMonths: 24,
    maxAgeMonths: 96,
  );

  for (final p in [
    Pet(
      id: 'pet1',
      ownerId: 'owner1',
      name: 'Pamuk',
      species: Species.cat,
      breed: 'sphynx',
      sex: Sex.female,
      birthDate: DateTime(t.year - 2, 3, 1),
      neutered: false,
      chipNo: '900000000000001',
      active: true,
    ),
    Pet(
      id: 'pet2',
      ownerId: 'owner2',
      name: 'Duman',
      species: Species.cat,
      breed: 'sphynx',
      sex: Sex.male,
      birthDate: DateTime(t.year - 3, 6, 15),
      neutered: false,
      chipNo: '900000000000002',
      active: true,
    ),
    Pet(
      id: 'pet3',
      ownerId: 'owner3',
      name: 'Altın',
      species: Species.dog,
      breed: 'golden_retriever',
      sex: Sex.female,
      birthDate: DateTime(t.year - 4, 1, 10),
      neutered: false,
      chipNo: '900000000000003',
      active: true,
    ),
  ]) {
    s.pets[p.id] = p;
  }

  void record(HealthRecord r) {
    s.healthRecords[r.id] = r;
    s.healthDocuments[r.id] = HealthDocument(
      recordId: r.id,
      ownerId: r.ownerId,
      vetId: r.vetId,
      imageBase64: _tinyImage,
    );
  }

  HealthRecord approved(String id, String petId, String ownerId, String test, String vetId, String clinicId, int months) {
    final approvedAt = t.subtract(const Duration(days: 30));
    return HealthRecord(
      id: id,
      petId: petId,
      ownerId: ownerId,
      testType: test,
      vetId: vetId,
      clinicId: clinicId,
      status: HealthStatus.approved,
      createdAt: approvedAt.subtract(const Duration(days: 2)),
      approvedAt: approvedAt,
      validUntil: DateTime(approvedAt.year, approvedAt.month + months, approvedAt.day),
    );
  }

  record(approved('record1', 'pet1', 'owner1', 'hcm_echo', 'vet1', 'clinic1', 12));
  record(approved('record2', 'pet2', 'owner2', 'hcm_echo', 'vet1', 'clinic1', 12));
  record(approved('record3', 'pet3', 'owner3', 'hip_elbow', 'vet2', 'clinic2', 96));
  record(HealthRecord(
    id: 'record4',
    petId: 'pet3',
    ownerId: 'owner3',
    testType: 'eye_exam',
    vetId: 'vet2',
    clinicId: 'clinic2',
    status: HealthStatus.pending,
    createdAt: t.subtract(const Duration(days: 1)),
  ));

  final sent = t.subtract(const Duration(hours: 5));
  final request = MatchRequest(
    fromPetId: 'pet2',
    toPetId: 'pet1',
    fromOwnerId: 'owner2',
    toOwnerId: 'owner1',
    status: MatchStatus.pending,
    createdAt: sent,
    resendAllowed: false,
    sendCount: 1,
    windowStart: sent,
  );
  s.matchRequests[request.id] = request;

  s.spamSenders['owner1'] = {
    'owner3': SpamSender(senderUid: 'owner3', flaggedAt: t.subtract(const Duration(hours: 2))),
  };

  return s;
}
