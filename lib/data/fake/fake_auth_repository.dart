import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_store.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._s);

  final FakeStore _s;

  @override
  Stream<String?> authStateChanges() => _s.watch(() => _s.currentUid);

  @override
  String? get currentUid => _s.currentUid;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final account = _s.accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const RepositoryException('E-posta ya da şifre hatalı.');
    }
    _s.currentUid = account.uid;
    _s.notify();
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final key = email.trim().toLowerCase();
    if (_s.accounts.containsKey(key)) {
      throw const RepositoryException('Bu e-posta adresiyle zaten bir hesap var.');
    }
    final uid = _s.newId('user');
    _s.accounts[key] = (uid: uid, password: password);
    _s.users[uid] = AppUser(
      id: uid,
      role: UserRole.owner,
      name: name,
      shareCode: 'VM-${uid.toUpperCase()}',
    );
    _s.phones[uid] = phone;
    _s.currentUid = uid;
    _s.notify();
  }

  @override
  Future<void> signOut() async {
    _s.currentUid = null;
    _s.notify();
  }
}
