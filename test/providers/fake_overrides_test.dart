import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetmatch/data/fake/fake_seed.dart';
import 'package:vetmatch/data/models/match_request.dart';
import 'package:vetmatch/providers/fake_overrides.dart';
import 'package:vetmatch/providers/repository_providers.dart';

// Smoke test of the fake wiring that screens will use with USE_FAKE=true.
void main() {
  late ProviderContainer c;
  setUp(() => c = ProviderContainer(overrides: fakeOverrides()));
  tearDown(() => c.dispose());

  test('seeded clinics are visible', () async {
    final clinics = await c.read(clinicRepositoryProvider).watchClinics().first;
    expect(clinics, isNotEmpty);
  });

  test('accepting a request reveals the phone to the other side', () async {
    await c.read(authRepositoryProvider).signIn(email: 'sahip1@vetmatch.test', password: fakePassword);
    final users = c.read(userRepositoryProvider);
    expect(await users.getPhone('owner2'), isNull);

    final match = c.read(matchRepositoryProvider);
    final incoming = await match.watchIncoming('owner1').first;
    await match.acceptRequest(incoming.single.id);

    expect(await users.getPhone('owner2'), isNotNull);
  });

  test('blocking cancels pending requests and hides the phone again', () async {
    await c.read(authRepositoryProvider).signIn(email: 'sahip1@vetmatch.test', password: fakePassword);
    final match = c.read(matchRepositoryProvider);
    await match.rejectRequest('pet2_pet1', block: true);

    final blocked = await c.read(blockRepositoryProvider).watchBlocked('owner1').first;
    expect(blocked, {'owner2'});
    final incoming = await match.watchIncoming('owner1').first;
    expect(incoming.single.status, MatchStatus.rejected);
    expect(await c.read(userRepositoryProvider).getPhone('owner2'), isNull);
  });
}
