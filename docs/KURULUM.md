# Yeni bir bilgisayarda kurulum

Proje iki farklı ortamda geliştiriliyor: Toprak Linux'ta, Ceren Windows'ta. Bu belge, repoyu yeni klonlayan birinin (ya da onun Claude Code ajanının) projeyi çalıştırması için gerekenleri anlatır. Hangi terminal, editör ve tarayıcının kullanılacağı kişiye kalmıştır; aşağıdaki komutlar Linux terminalinde, PowerShell'de ve Git Bash'te aynı şekilde çalışır.

## Faz 0 tamamlandı, tekrarlanmaz

Flutter projesi, Firebase bağlantısı ve emülatör ayarları repoda hazır. Şunları **çalıştırma**:

- `flutter create` (mevcut dosyaların üzerine yazar)
- `flutterfire configure` (`lib/firebase_options.dart` ve `android/app/google-services.json` repoda; yeniden çalıştırmak Firebase projesinde gereksiz yeni uygulama kayıtları açar)
- `firebase init` (`firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json` repoda)

## Gerekenler

| Araç | Not |
|---|---|
| Flutter (stable) | Dart 3.14 veya üstü. `flutter doctor` ile kontrol et; sadece "Flutter" ve "Android toolchain" satırlarının yeşil olması yeterli. |
| Android Studio | Android SDK, lisanslar (`flutter doctor --android-licenses`) ve en az bir Android emülatörü (AVD). |
| Node.js | 20 veya üstü. `firebase-tools` ve ileride `firestore-tests/`, `tools/seed/` için. |
| Firebase CLI | `npm install -g firebase-tools` |
| Java (JDK) | 21 veya üstü. Firestore emülatörü Java ile çalışır; `java -version` ile kontrol et. |
| Tarayıcı | Herhangi biri. Web, sadece günlük arayüz işi için. |

`flutterfire` CLI gerekmez.

## İlk çalıştırma

```sh
flutter pub get
firebase emulators:start --import ./emulator-data
```

`emulator-data/` henüz yoksa (Faz 2'deki seed'den önce) `--import ./emulator-data` kısmını çıkar. Emülatörleri başlatmak için Firebase projesine erişim gerekmeyebilir; komut giriş isterse `firebase login` çalıştır (proje sahibi seni Firebase projesine eklemiş olmalı).

Ayrı bir terminalde:

```sh
flutter run --dart-define=USE_EMULATOR=true
```

Android emülatörü açıkken bu komut uygulamayı orada açar. Web için:

```sh
flutter run -d web-server --web-port 3000 --dart-define=USE_EMULATOR=true
```

Sonra tarayıcıda `localhost:3000` adresini aç. Emulator UI: `localhost:4000`.

## Sahte veriyle çalıştırma

Ekran geliştirirken emülatör gerekmez:

```sh
flutter run --dart-define=USE_FAKE=true
```

Uygulama bellekte tutulan kurgusal veriyle açılır, Firebase'e bağlanmaz; uygulama kapanınca yapılan değişiklikler silinir. Hesapların hepsinin şifresi `test1234`:

| E-posta | Kim | Senaryodaki yeri |
|---|---|---|
| `sahip1@vetmatch.test` | Ayşe (sahip) | Sfenks Pamuk, uygun; gelen bir eşleşme isteği var; spam kutusunda bir kişi var |
| `sahip2@vetmatch.test` | Mehmet (sahip) | Sfenks Duman, uygun; Pamuk'a istek göndermiş |
| `sahip3@vetmatch.test` | Zeynep (sahip) | Golden Retriever Altın; göz muayenesi onay bekliyor |
| `vet1@vetmatch.test` | Dr. Ece Kaya (veteriner) | Kayısı Veteriner Kliniği |
| `vet2@vetmatch.test` | Dr. Can Demir (veteriner) | Fırat Hayvan Hastanesi; bekleyen bir belgesi var |

Veri `lib/data/fake/fake_seed.dart` dosyasında.

## Windows notları

- Emülatörler ilk açılışta Windows Güvenlik Duvarı izni isteyebilir (Java ve Node için). "Özel ağlar" için izin vermek yeterli; emülatörler sadece bu bilgisayardan (`127.0.0.1`) erişilir.
- Android emülatörü için donanım hızlandırma (Windows Hypervisor Platform) açık olmalı; Android Studio'nun SDK Manager'ı bunu kontrol eder.
- `cd firestore-tests && npm test` gibi `&&` içeren komutlar PowerShell 7'de ve Git Bash'te çalışır, eski Windows PowerShell 5.1'de çalışmaz. 5.1 kullanıyorsan iki komutu ayrı satırlarda çalıştır.
- Git satır sonlarını kendisi dönüştürür (`core.autocrlf`); dosyalardaki satır sonlarını elle değiştirme.

## Kontrol

Kurulum tamamsa `flutter analyze` sorun bulmaz ve uygulama emülatöre bağlanır: geçici ana ekranda "Emülatöre bağlı" yazar, "Test kullanıcısı oluştur" düğmesiyle oluşturulan kullanıcı `localhost:4000/auth` adresinde görünür. (`flutter test` ilk testler Faz 1'de eklenene kadar "test dosyası yok" der; bu bir hata değildir.)
