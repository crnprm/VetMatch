import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/block_repository.dart';
import '../data/repositories/clinic_repository.dart';
import '../data/repositories/health_repository.dart';
import '../data/repositories/match_repository.dart';
import '../data/repositories/pet_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/transfer_repository.dart';
import '../data/repositories/user_repository.dart';

// Defaults become the Firebase implementations in Phase 2. Until then run
// with --dart-define=USE_FAKE=true (see fake_overrides.dart).
Never _notYet() => throw UnimplementedError(
    'Firebase implementasyonu Faz 2\'de gelecek; USE_FAKE=true ile çalıştırın.');

final authRepositoryProvider = Provider<AuthRepository>((ref) => _notYet());
final userRepositoryProvider = Provider<UserRepository>((ref) => _notYet());
final clinicRepositoryProvider = Provider<ClinicRepository>((ref) => _notYet());
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => _notYet());
final petRepositoryProvider = Provider<PetRepository>((ref) => _notYet());
final healthRepositoryProvider = Provider<HealthRepository>((ref) => _notYet());
final matchRepositoryProvider = Provider<MatchRepository>((ref) => _notYet());
final blockRepositoryProvider = Provider<BlockRepository>((ref) => _notYet());
final transferRepositoryProvider = Provider<TransferRepository>((ref) => _notYet());

/// The signed-in uid, or null.
final authStateProvider = StreamProvider<String?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
