import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/emulator.dart';
import 'core/fake_mode.dart';
import 'firebase_options.dart';
import 'providers/fake_overrides.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (useFake) {
    runApp(ProviderScope(overrides: fakeOverrides(), child: const VetMatchApp()));
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useEmulator) {
    await connectToEmulators();
  }
  runApp(const ProviderScope(child: VetMatchApp()));
}
