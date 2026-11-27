import 'package:firebase_auth/firebase_auth.dart';

/// Phase 0 only: creates a throwaway user to prove the app reaches the
/// Auth emulator. Remove together with the placeholder home screen.
Future<String> createSmokeTestUser() async {
  final email = 'test-${DateTime.now().millisecondsSinceEpoch}@vetmatch.test';
  final credential = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: 'test1234');
  return credential.user!.email!;
}
