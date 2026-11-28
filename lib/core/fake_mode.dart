/// Set with `--dart-define=USE_FAKE=true`: the app runs on in-memory fake
/// repositories and never touches Firebase.
const bool useFake = bool.fromEnvironment('USE_FAKE');
