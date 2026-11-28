import '../models/app_user.dart';
import '../models/contact_share.dart';
import '../repositories/user_repository.dart';
import 'fake_store.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository(this._s);

  final FakeStore _s;

  @override
  Stream<AppUser?> watchUser(String uid) => _s.watch(() => _s.users[uid]);

  @override
  Future<AppUser?> findByShareCode(String shareCode) async {
    final code = shareCode.trim().toUpperCase();
    for (final u in _s.users.values) {
      if (u.shareCode == code) return u;
    }
    return null;
  }

  @override
  Stream<List<AppUser>> watchVetsOfClinic(String clinicId) => _s.watch(() => [
        for (final u in _s.users.values)
          if (u.role == UserRole.vet && u.clinicId == clinicId) u,
      ]);

  @override
  Future<String?> getPhone(String uid) async {
    final me = _s.currentUid;
    if (me == null) return null;
    final allowed =
        me == uid || _s.contactShares.containsKey(ContactShare.idFor(me, uid));
    return allowed ? _s.phones[uid] : null;
  }
}
