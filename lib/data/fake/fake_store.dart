import 'dart:async';

import '../models/app_user.dart';
import '../models/breed_rule.dart';
import '../models/clinic.dart';
import '../models/contact_share.dart';
import '../models/health_document.dart';
import '../models/health_record.dart';
import '../models/match_request.dart';
import '../models/pet.dart';
import '../models/review.dart';
import '../models/spam_sender.dart';
import '../models/transfer_request.dart';

/// In-memory database shared by all fake repositories.
class FakeStore {
  String? currentUid;

  /// email -> (uid, password)
  final accounts = <String, ({String uid, String password})>{};
  final users = <String, AppUser>{};
  final phones = <String, String>{};
  final blocks = <String, Set<String>>{};
  final contactShares = <String, ContactShare>{};
  final clinics = <String, Clinic>{};

  /// clinicId -> authorId -> review
  final reviews = <String, Map<String, Review>>{};
  final pets = <String, Pet>{};
  final healthRecords = <String, HealthRecord>{};
  final healthDocuments = <String, HealthDocument>{};
  final breedRules = <String, BreedRule>{};
  final matchRequests = <String, MatchRequest>{};

  /// receiverUid -> senderUid -> flag
  final spamSenders = <String, Map<String, SpamSender>>{};
  final transferRequests = <String, TransferRequest>{};

  final _changes = StreamController<void>.broadcast();
  int _idCounter = 0;

  String newId(String prefix) => '$prefix${++_idCounter}';

  /// Call after every write so open streams emit again.
  void notify() => _changes.add(null);

  /// Emits [read] now and again after every change.
  Stream<T> watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  /// Cancels pending match requests matching [test].
  void cancelPendingRequests(bool Function(MatchRequest r) test) {
    for (final r in matchRequests.values.toList()) {
      if (r.status == MatchStatus.pending && test(r)) {
        matchRequests[r.id] = r.copyWith(status: MatchStatus.cancelled);
      }
    }
  }
}
