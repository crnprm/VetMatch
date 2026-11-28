import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:vetmatch/data/models/app_user.dart';
import 'package:vetmatch/data/models/breed_rule.dart';
import 'package:vetmatch/data/models/clinic.dart';
import 'package:vetmatch/data/models/contact.dart';
import 'package:vetmatch/data/models/contact_share.dart';
import 'package:vetmatch/data/models/health_document.dart';
import 'package:vetmatch/data/models/health_record.dart';
import 'package:vetmatch/data/models/match_request.dart';
import 'package:vetmatch/data/models/pet.dart';
import 'package:vetmatch/data/models/request_stats.dart';
import 'package:vetmatch/data/models/review.dart';
import 'package:vetmatch/data/models/spam_sender.dart';
import 'package:vetmatch/data/models/species.dart';
import 'package:vetmatch/data/models/transfer_request.dart';

final t1 = DateTime.utc(2026, 11, 27, 10);
final t2 = DateTime.utc(2027, 11, 27, 10);

void main() {
  test('AppUser round trip (vet with clinic, owner without)', () {
    for (final u in [
      AppUser(id: 'u1', role: UserRole.vet, name: 'Dr. Ada', shareCode: 'VM-4K7Q', clinicId: 'c1'),
      AppUser(id: 'u2', role: UserRole.owner, name: 'Ali', shareCode: 'VM-9P2X'),
    ]) {
      final back = AppUser.fromMap(u.id, u.toMap());
      expect(back.toMap(), u.toMap());
      expect(back.id, u.id);
    }
  });

  test('Contact round trip', () {
    const c = Contact(uid: 'u1', phone: '+905551112233');
    expect(Contact.fromMap('u1', c.toMap()).toMap(), c.toMap());
  });

  test('ContactShare round trip and order-independent id', () {
    final s = ContactShare(userIds: ['a', 'b'], matchRequestId: 'p1_p2', createdAt: t1);
    expect(ContactShare.fromMap(s.toMap()).toMap(), s.toMap());
    expect(ContactShare.idFor('b', 'a'), 'a_b');
    expect(ContactShare.idFor('a', 'b'), 'a_b');
  });

  test('Clinic round trip', () {
    final c = Clinic(
      id: 'c1',
      name: 'Kayısı Veteriner',
      location: const LatLng(38.355, 38.309),
      species: [Species.cat, Species.dog],
      capabilities: ['echocardiography'],
    );
    final back = Clinic.fromMap('c1', c.toMap());
    expect(back.toMap(), c.toMap());
    expect(back.location, c.location);
  });

  test('Review round trip', () {
    final r = Review(clinicId: 'c1', authorId: 'u1', authorName: 'Ali', rating: 4, comment: 'İyi', createdAt: t1);
    final back = Review.fromMap('c1', 'u1', r.toMap());
    expect(back.toMap(), r.toMap());
    expect((back.clinicId, back.authorId), ('c1', 'u1'));
  });

  test('Pet round trip', () {
    final p = Pet(
      id: 'p1',
      ownerId: 'u1',
      name: 'Pamuk',
      species: Species.cat,
      breed: 'sphynx',
      sex: Sex.female,
      birthDate: DateTime.utc(2024, 3, 1),
      neutered: false,
      chipNo: '900000000000001',
      active: true,
    );
    expect(Pet.fromMap('p1', p.toMap()).toMap(), p.toMap());
  });

  test('HealthRecord round trip (pending and approved)', () {
    final pending = HealthRecord(
      id: 'h1',
      petId: 'p1',
      ownerId: 'u1',
      testType: 'hcm_echo',
      vetId: 'v1',
      clinicId: 'c1',
      status: HealthStatus.pending,
      createdAt: t1,
    );
    final approved = pending.copyWith(status: HealthStatus.approved, approvedAt: t1, validUntil: t2);
    final rejected = pending.copyWith(status: HealthStatus.rejected, rejectionReason: 'Bulanık');
    for (final r in [pending, approved, rejected]) {
      expect(HealthRecord.fromMap('h1', r.toMap()).toMap(), r.toMap());
    }
  });

  test('HealthDocument round trip', () {
    const d = HealthDocument(recordId: 'h1', ownerId: 'u1', vetId: 'v1', imageBase64: 'aGVsbG8=');
    expect(HealthDocument.fromMap('h1', d.toMap()).toMap(), d.toMap());
  });

  test('BreedRule round trip', () {
    const b = BreedRule(
      id: 'golden_retriever',
      species: Species.dog,
      breed: 'Golden Retriever',
      requiredTests: [
        RequiredTest(testType: 'hip_elbow', validityMonths: 24),
        RequiredTest(testType: 'eye_exam', validityMonths: 12),
      ],
      minAgeMonths: 24,
      maxAgeMonths: 96,
    );
    expect(BreedRule.fromMap(b.id, b.toMap()).toMap(), b.toMap());
  });

  test('MatchRequest round trip and id', () {
    final m = MatchRequest(
      fromPetId: 'p1',
      toPetId: 'p2',
      fromOwnerId: 'u1',
      toOwnerId: 'u2',
      status: MatchStatus.pending,
      createdAt: t1,
      resendAllowed: false,
      sendCount: 1,
      windowStart: t1,
    );
    final rejected = m.copyWith(status: MatchStatus.rejected, rejectedAt: t2);
    for (final r in [m, rejected]) {
      expect(MatchRequest.fromMap(r.toMap()).toMap(), r.toMap());
    }
    expect(m.id, 'p1_p2');
  });

  test('RequestStats round trip and directional id', () {
    final s = RequestStats(fromUid: 'u1', toUid: 'u2', sendCount: 3, windowStart: t1);
    expect(RequestStats.fromMap(s.toMap()).toMap(), s.toMap());
    expect(s.id, 'u1_u2');
  });

  test('SpamSender round trip', () {
    final s = SpamSender(senderUid: 'u1', flaggedAt: t1);
    expect(SpamSender.fromMap('u1', s.toMap()).toMap(), s.toMap());
  });

  test('TransferRequest round trip', () {
    final t = TransferRequest(
      petId: 'p1',
      fromOwnerId: 'u1',
      toOwnerId: 'u2',
      status: TransferStatus.pending,
      createdAt: t1,
    );
    expect(TransferRequest.fromMap('p1', t.toMap()).toMap(), t.toMap());
  });
}
