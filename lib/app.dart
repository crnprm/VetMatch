import 'package:material_ui/material_ui.dart';

import 'core/emulator.dart';
import 'core/smoke_test.dart';

class VetMatchApp extends StatelessWidget {
  const VetMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetMatch',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const _PlaceholderHome(),
    );
  }
}

/// Phase 0 placeholder; replaced by go_router routes in Phase 4.
class _PlaceholderHome extends StatefulWidget {
  const _PlaceholderHome();

  @override
  State<_PlaceholderHome> createState() => _PlaceholderHomeState();
}

class _PlaceholderHomeState extends State<_PlaceholderHome> {
  String _status = '';

  Future<void> _createTestUser() async {
    setState(() => _status = 'Oluşturuluyor...');
    try {
      final email = await createSmokeTestUser();
      setState(() => _status = 'Test kullanıcısı oluşturuldu: $email');
    } catch (e) {
      setState(() => _status = 'Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VetMatch')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Text(useEmulator
                  ? 'Emülatöre bağlı ($emulatorHost)'
                  : 'Gerçek Firebase projesine bağlı'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _createTestUser,
                child: const Text('Test kullanıcısı oluştur'),
              ),
              const SizedBox(height: 16),
              Text(_status, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
