# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

# VetMatch — Projeye özel kurallar

Yukarıdaki genel kurallar her zaman geçerli. Aşağıdakiler bu projeye özel.

## Proje

Mobil Programlama dersi için iki kişilik ekibin Android uygulaması: yakındaki veteriner kliniklerini bulma + veteriner onaylı sağlık testlerine dayalı eşleştirme. Tüm veri kurgusal. Kararlar ve gerekçeler: `README.md` (proje raporu), `PLAN.md` (iş planı ve güncel veri modeli), `docs/adr/`. Bir karar bu dosyalarla çelişiyorsa uygulamadan önce sor.

## Teknoloji

- Flutter (stable), Dart 3. Hedef platformlar: Android (asıl), web (sadece geliştirme kolaylığı). iOS, Linux, Windows, macOS yapılandırması ekleme.
- State management: Riverpod, `flutter_riverpod` ile elle yazılmış provider'lar. `riverpod_generator`, `freezed`, `json_serializable` veya başka kod üretimi kullanma; modellerin `fromMap` / `toMap` metotları elle yazılır.
- Firebase: Auth (e-posta/şifre) ve Cloud Firestore. **Firebase Storage ve Cloud Functions kullanılmıyor** (bkz. ADR-001). Bunları gerektiren bir çözüm önerme.
- Harita: `flutter_map` + OpenStreetMap. Navigasyon: `go_router`.
- Yeni paket eklemeden önce sor.

## Komutlar

```bash
firebase emulators:start --import ./emulator-data      # emülatörler (Auth 9099, Firestore 8080, UI 4000)
flutter run --dart-define=USE_EMULATOR=true            # Android emülatöründe
flutter run -d web-server --web-port 3000 --dart-define=USE_EMULATOR=true   # web; 8080 Firestore emülatörüne ait
flutter analyze
flutter test
cd firestore-tests && npm test                         # güvenlik kuralı testleri
```

## Klasör yapısı

```
lib/
  main.dart, app.dart
  core/            # emülatör bağlantısı, tema, sabitler, yardımcılar (görsel sıkıştırma, mesafe)
  data/
    models/        # veri sınıfları
    repositories/  # soyut arayüzler
    firebase/      # Firestore implementasyonları
    fake/          # bellek içi sahte implementasyonlar
  domain/          # saf Dart iş mantığı (uygunluk, durum geçişleri)
  providers/       # Riverpod provider'ları
  features/<alan>/ # ekranlar ve widget'lar (auth, clinics, reviews, pets, health, matching, transfer)
firestore.rules
firestore-tests/   # Node, @firebase/rules-unit-testing
tools/seed/        # emülatöre demo verisi yazan Node script'i
emulator-data/     # dışa aktarılmış emülatör verisi (commit'lenir)
```

## Mimari kurallar

- Ekranlar Firebase'e doğrudan erişmez. `FirebaseFirestore` / `FirebaseAuth` sadece `lib/data/firebase/` ve `lib/core/` içinde kullanılır. Ekranlar veriye provider'lar üzerinden, provider'lar repository arayüzleri üzerinden ulaşır.
- Yeni bir repository metodu eklediğinde hem Firebase hem sahte implementasyona ekle.
- İş mantığı (uygunluk, durum geçişleri) `lib/domain/` altında, Flutter ve Firebase'den bağımsız saf Dart olarak yazılır.
- `dart:io` kullanma; kod web'de de derlenmelidir. Seçilen görseli `XFile.readAsBytes()` ile oku.
- Sağlık belgesi görselleri: `image_picker` ile `maxWidth: 1280`, `imageQuality: 70`; base64 metni 900 KB'ı geçerse yüklemeyi reddet ve kullanıcıdan daha küçük bir fotoğraf iste. Görsel `healthDocuments/{recordId}` belgesine yazılır, `healthRecords` belgesine asla.
- Hayvanlar silinmez: `active: false`. Pasif yaparken bekleyen eşleşme isteklerini aynı batch'te iptal et.
- Belge ID kuralları: yorum = yazarın uid'si; eşleşme isteği = `{fromPetId}_{toPetId}`; devir isteği = `petId`.
- Telefon numarası sadece `users/{uid}/private/contact` belgesinde tutulur.
- "Süresi doldu" durumu veritabanına yazılmaz; `validUntil` ile hesaplanır.
- Emülatör bağlantısı: Android'de `10.0.2.2`, web'de `localhost`.

## Güvenlik

- Servis hesabı anahtarı (`*-firebase-adminsdk-*.json`, `serviceAccount*.json`), `.env` ve benzeri dosyaları asla commit'leme; `.gitignore`'da olduklarını kontrol et. `google-services.json` ve `firebase_options.dart` commit'lenebilir.
- `firestore.rules` dosyasındaki her değişiklik `firestore-tests/` altında bir testle birlikte gelir. Test yazmadan kural değiştirme.
- Kullanıcı kendi `role` alanını `vet` yapamaz; veteriner hesapları sadece seed script'iyle oluşturulur.

## Test

- Test önce yazılır: `lib/domain/` altındaki mantık ve güvenlik kuralları için.
- Modeller için `toMap` → `fromMap` gidiş-dönüş testi yeterli.
- Ekranlar için widget testi zorunlu değil; ekranları elle, Android emülatöründe doğrula.

## Dil ve stil

- Kod, tanımlayıcılar ve kod yorumları İngilizce; kullanıcıya görünen metinler Türkçe.
- Commit mesajları Türkçe, kısa ve emir kipinde ("Klinik detay ekranını ekle").
- `main` dalına doğrudan commit atma; `feature/<kısa-ad>` dalında çalış.
