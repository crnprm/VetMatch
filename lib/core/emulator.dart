import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Set with `--dart-define=USE_EMULATOR=true`.
const bool useEmulator = bool.fromEnvironment('USE_EMULATOR');

/// The Android emulator reaches the host machine at 10.0.2.2; web uses localhost.
String get emulatorHost =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';

/// Must be called after `Firebase.initializeApp` and before any other
/// Auth or Firestore call.
Future<void> connectToEmulators() async {
  final host = emulatorHost;
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}
