import 'package:flutter_riverpod/misc.dart';

import '../data/fake/fake_auth_repository.dart';
import '../data/fake/fake_block_repository.dart';
import '../data/fake/fake_clinic_repository.dart';
import '../data/fake/fake_health_repository.dart';
import '../data/fake/fake_match_repository.dart';
import '../data/fake/fake_pet_repository.dart';
import '../data/fake/fake_review_repository.dart';
import '../data/fake/fake_seed.dart';
import '../data/fake/fake_transfer_repository.dart';
import '../data/fake/fake_user_repository.dart';
import 'repository_providers.dart';

/// Swaps every repository for its fake, all sharing one seeded store.
List<Override> fakeOverrides() {
  final s = seedFakeStore();
  return [
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(s)),
    userRepositoryProvider.overrideWithValue(FakeUserRepository(s)),
    clinicRepositoryProvider.overrideWithValue(FakeClinicRepository(s)),
    reviewRepositoryProvider.overrideWithValue(FakeReviewRepository(s)),
    petRepositoryProvider.overrideWithValue(FakePetRepository(s)),
    healthRepositoryProvider.overrideWithValue(FakeHealthRepository(s)),
    matchRepositoryProvider.overrideWithValue(FakeMatchRepository(s)),
    blockRepositoryProvider.overrideWithValue(FakeBlockRepository(s)),
    transferRepositoryProvider.overrideWithValue(FakeTransferRepository(s)),
  ];
}
