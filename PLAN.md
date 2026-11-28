# VetMatch — İş Planı

Bu dosya, proje raporundaki (README) kararların koda dökülme sırasını tanımlar. Kararların gerekçeleri README'de ve `docs/adr/` altındadır. Claude Code ile çalışırken her fazın başında bu dosyayı ve `CLAUDE.md`'yi okut.

## Raporla farkı olan kararlar (26 Kasım 2026)

| Konu | Rapordaki hâl | Güncel karar |
|---|---|---|
| Dosya depolama | Firebase Storage | Firestore'da base64 görsel (ADR-001) |
| State management | Belirsiz | Riverpod (kod üretimi yok, elle yazılmış provider'lar) |
| Köpek ırkı | "Bir köpek ırkı" | Golden Retriever |
| Reddedilen istek | Belirsiz | Aynı hayvan çiftine 30 gün tekrar istek gönderilemez; reddeden kişi bu süreyi erken kaldırabilir (belge ID'si `{gönderenPet}_{alanPet}`, yeni istek aynı belgenin üzerine yazılır) |
| İptal edilen / geri çekilen istek | Belirsiz | Gönderen bekleyen isteğini geri çekebilir. İptal ve geri çekme engel oluşturmaz; aynı çifte istediği an tekrar istek gönderilebilir |
| İstek spam'i | — | Aynı hayvana 3 dakikada 5 ya da aynı kişinin hayvanlarına 10 dakikada 15 gönderim yapan kişi, alıcının spam kutusuna düşer. Alıcı "spam değil" diyene ya da engelleyene kadar orada kalır. Gönderen bunu görmez. Alıcı, bekleyen istek olmasa da spam kutusundan engelleyebilir |
| Engelleme | Ayrı bir seçenek | Her yerden erişilebilir; ayrıca reddederken "Reddet ve engelle" kısayolu. Engel kaldırılabilir. Engel listesi sadece sahibine görünür |
| Telefon gizliliği | `users` belgesinde | `users/{uid}/private/contact` alt belgesinde; okuma izni `contactShares` belgesine bağlı (27 Kasım) |
| Geliştirme ortamı | — | Firebase Emulator Suite; günlük arayüz işi web'de (`web-server`), doğrulama Android emülatöründe |

## Veri modeli (güncel)

| Yol | Alanlar | Not |
|---|---|---|
| `users/{uid}` | `role` (`owner`/`vet`), `name`, `clinicId?`, `shareCode` | İstemci yalnızca `role: owner` ile oluşturabilir. `shareCode`: profilde gösterilen kısa kod (ör. `VM-4K7Q`); devirde alıcı bu kodla bulunur |
| `users/{uid}/private/contact` | `phone` | Sahibi okur; başkası sadece ikisi arasında bir `contactShares` belgesi varsa okur |
| `users/{uid}/private/blocks` | `userIds[]` | Sadece sahibi okur/yazar. Kurallar `get()` ile okuyup engellenen kişinin istek oluşturmasını reddeder |
| `contactShares/{uidA}_{uidB}` | `userIds[]`, `matchRequestId`, `createdAt` | ID: iki uid alfabetik sırayla. İstek kabul edilirken aynı batch'te oluşturulur (kural `getAfter` ile isteğin `accepted` olduğunu doğrular); engellemede silinir. Kullanıcı çifti başına tek belge |
| `clinics/{clinicId}` | `name`, `location` (GeoPoint), `species[]`, `capabilities[]` | Sadece seed script yazar |
| `clinics/{clinicId}/reviews/{uid}` | `rating`, `comment`, `authorName`, `createdAt` | Belge ID'si = yazarın uid'si → kullanıcı başına tek yorum |
| `pets/{petId}` | `ownerId`, `name`, `species`, `breed`, `sex`, `birthDate`, `neutered`, `chipNo`, `active` | Silinmez, `active: false` yapılır |
| `healthRecords/{recordId}` | `petId`, `ownerId`, `testType`, `vetId`, `clinicId`, `status`, `rejectionReason?`, `approvedAt?`, `validUntil?`, `createdAt` | Oturum açmış herkes okuyabilir (uygunluk hesabı için); hassas veri içermez |
| `healthDocuments/{recordId}` | `ownerId`, `vetId`, `imageBase64` | Sadece `ownerId` ve `vetId` okuyabilir; oluşturulduktan sonra değişmez |
| `breedRules/{breedId}` | `species`, `breed`, `requiredTests[]` (`testType`, `validityMonths`), `minAgeMonths`, `maxAgeMonths` | Sadece seed script yazar |
| `matchRequests/{fromPetId}_{toPetId}` | `fromPetId`, `toPetId`, `fromOwnerId`, `toOwnerId`, `status`, `createdAt`, `rejectedAt?`, `resendAllowed`, `sendCount`, `windowStart` | `resendAllowed`'ı sadece `toOwnerId` `true` yapabilir; yeniden gönderimde `false`'a döner. `sendCount` / `windowStart`: bu hayvan çifti için 3 dakikalık spam penceresi |
| `requestStats/{fromUid}_{toUid}` | `fromUid`, `toUid`, `sendCount`, `windowStart` | Yönlüdür (sıralanmaz). Gönderen kişinin alıcının tüm hayvanlarına yaptığı gönderimler için 10 dakikalık pencere. Her gönderimle aynı batch'te güncellenir; iki taraf da okur, sadece `fromUid` yazar |
| `users/{uid}/spamSenders/{fromUid}` | `flaggedAt` | Eşik aşıldığında gönderenin batch'i oluşturur. Gönderen yazabilir ama okuyamaz; sadece alıcı okur ve siler ("spam değil") |
| `transferRequests/{petId}` | `petId`, `fromOwnerId`, `toOwnerId`, `status`, `createdAt` | Hayvan başına tek açık devir isteği |

Durumlar:
- `healthRecords.status`: `pending` → `approved` / `rejected` / `withdrawn`. "Süresi doldu" saklanmaz; `validUntil < şimdi` ise ekranda süresi dolmuş sayılır.
- `matchRequests.status`: `pending` → `accepted` / `rejected` / `cancelled` / `withdrawn`
  - `withdrawn`: gönderen bekleyen isteğini geri çekti.
  - `cancelled` (hayvan pasif yapıldı, devredildi ya da sahipler arasında engelleme oldu) ve `withdrawn` → gönderen istediği an tekrar `pending` yapabilir (engel yoksa).
  - `rejected` → gönderen, `rejectedAt + 30 gün` geçtiyse ya da `resendAllowed == true` ise tekrar `pending` yapabilir (engel yoksa).
  - `accepted` kalıcıdır.
- Spam sayımı (her gönderim, yani ilk istek ve yeniden gönderim, tek batch): 
  - İstek belgesinde `windowStart + 3 dk` geçmediyse `sendCount + 1`; geçtiyse `sendCount = 1`, `windowStart = şimdi`. `requestStats`'ta aynısı 10 dakikalık pencereyle yapılır.
  - İstek belgesinde `sendCount >= 5` ya da `requestStats`'ta `sendCount >= 15` olursa aynı batch `users/{toUid}/spamSenders/{fromUid}` belgesini yazar. Kurallar sayacın doğru artırıldığını ve eşikte bu belgenin yazıldığını (`getAfter` / `existsAfter`) denetler.
  - Alıcının gelen kutusu: göndereni `spamSenders`'ta olan bekleyen istekler spam kutusunda gösterilir, diğerleri normal listede. İstek belgesinde spam alanı yoktur; gönderen için istek normal "beklemede" görünür.
  - Spam kutusu ayrıca `spamSenders`'taki kişileri bekleyen istekleri olmasa da listeler. Alıcı buradan "spam değil" der (belge silinir) ya da engeller.
- Engelleme (tek batch): engellenen uid `private/blocks`'a eklenir, iki kullanıcı arasındaki bekleyen istekler `cancelled` yapılır, `contactShares` ve varsa `spamSenders` belgesi silinir. "Reddet ve engelle" aynı batch'e reddi de ekler.
- Engeli kaldırma: uid listeden çıkarılır. İptal edilen istekler ve silinen iletişim paylaşımı geri gelmez; reddedilen isteklerde 30 gün kuralı geçerliliğini korur.
- `transferRequests.status`: `pending` → `accepted` / `rejected` / `cancelled`

Uygunluk (telefonda hesaplanır): hayvan `active`, `neutered == false`, yaşı ırk kuralının sınırları içinde ve ırkın her zorunlu testi için `approved` ve `validUntil > şimdi` olan bir kayıt var. Aday listesi: aynı ırk, karşı cinsiyet, uygun, sahibi kullanıcının engel listesinde değil. (Engel listesi gizli olduğu için engellenen kişi, kendisini engelleyenin hayvanını listede görmeye devam eder; istek gönderirse "İstek gönderilemedi" gibi genel bir mesaj alır.)

## Fazlar

Her fazın "bitti sayılır" maddeleri doğrulanabilir olmalı. Biri tutmuyorsa faz bitmemiştir.

### Faz 0 — Proje iskeleti (Toprak) ✅ Tamamlandı (27 Kasım 2026)

> Bu faz bitti; adımlar kayıt için duruyor. Yeni bilgisayarda kurulum için `docs/KURULUM.md`.

1. Firebase konsolunda Spark planında proje aç. Authentication'da e-posta/şifre girişini etkinleştir, Firestore'u oluştur. Storage'ı açma.
2. Repo kökünde Flutter projesi:
   ```sh
   flutter create --org com.vetmatch --platforms android,web --project-name vetmatch .
   ```
3. `flutter create`'in ürettiği `.gitignore`'a gizli anahtar kalıplarını ekle (`*-firebase-adminsdk-*.json`, `serviceAccount*.json`, `.env*`). Firebase araçları çalışmadan önce yapılmalı.
4. Paketler:
   ```sh
   flutter pub add flutter_riverpod go_router firebase_core firebase_auth cloud_firestore flutter_map latlong2 geolocator image_picker url_launcher intl
   ```
5. `flutterfire configure`: Android ve web'i seç.
6. `firebase init`: Firestore (rules + indexes) ve Emulators (Auth, Firestore, Emulator UI). Portları varsayılan bırak (Auth 9099, Firestore 8080, UI 4000).
7. `main.dart`: `--dart-define=USE_EMULATOR=true` verilirse emülatörlere bağlan. Host Android'de `10.0.2.2`, web'de `localhost`.
8. Android debug derlemesi için `10.0.2.2` adresine açık metin (cleartext) trafiğine izin veren network security config ekle. Bu olmadan Auth emülatörü Android'de bağlanamaz.
9. Klasör yapısını oluştur (bkz. `CLAUDE.md`).

**Bitti sayılır:** `flutter analyze` temiz; boş uygulama hem Android emülatöründe hem `flutter run -d web-server --web-port 3000` ile tarayıcıda açılıyor; Emulator UI'da (`localhost:4000`) uygulamadan oluşturulan bir test kullanıcısı görünüyor.

### Faz 1 — Veri katmanı (Toprak) → Ceren'e devir noktası

1. `lib/data/models/`: tablodaki her koleksiyon için model sınıfı, elle yazılmış `fromMap` / `toMap`. Modeller Firebase tiplerine bağlı değildir: tarih `DateTime`, konum `LatLng`; `Timestamp` / `GeoPoint` dönüşümü Faz 2'de `lib/data/firebase/` içinde yapılır.
2. `lib/data/repositories/`: her alan için soyut repository arayüzü (`AuthRepository`, `UserRepository`, `ClinicRepository`, `ReviewRepository`, `PetRepository`, `HealthRepository`, `MatchRepository`, `TransferRepository`, `BlockRepository`).
3. `lib/data/fake/`: her arayüz için sahte veri döndüren implementasyon (bellek içi, stream destekli). Durum geçişleri basit tutulur; 30 gün kuralı, spam sayımı ve uygunluk Faz 3'te `lib/domain/`'e gelir.
4. `lib/providers/`: repository provider'ları. Varsayılan Firebase implementasyonu; `--dart-define=USE_FAKE=true` ile uygulama sahte implementasyonlarla açılır ve Firebase'e bağlanmaz.

**Bitti sayılır:** model testleri (`toMap` → `fromMap` gidiş-dönüşü) geçiyor; arayüzler ve sahte implementasyonlar `main`'e birleşti. Bu noktadan sonra Ceren ekranlara başlayabilir.

### Faz 2 — Firebase implementasyonları, güvenlik kuralları ve seed (Toprak)

1. `lib/data/firebase/`: repository arayüzlerinin Firestore implementasyonları.
2. `firestore.rules`: tablodaki erişim kuralları.
3. `firestore-tests/`: `@firebase/rules-unit-testing` ile kural testleri. En az şu durumlar:
   - Kullanıcı kendini `vet` rolüyle oluşturamaz.
   - Üçüncü bir kullanıcı `healthDocuments` belgesini okuyamaz; sahip ve seçilen veteriner okuyabilir.
   - Telefon, `contactShares` belgesi yokken karşı tarafa görünmez; kabulden sonra görünür; engellemeden sonra yine görünmez.
   - `contactShares` belgesi, ilgili istek aynı batch'te `accepted` olmadan oluşturulamaz.
   - Veteriner sadece kendisine atanmış kaydı onaylayabilir/reddedebilir.
   - Kullanıcı bir kliniğe ikinci yorum yazamaz.
   - Bekleyen ya da kabul edilmiş bir istek varken aynı hayvan çifti için yeni istek oluşturulamaz.
   - Reddedilen istek 30 gün dolmadan yeniden gönderilemez; `resendAllowed == true` ise gönderilebilir; `resendAllowed`'ı sadece alıcı açabilir.
   - İptal edilen ya da geri çekilen istek hemen yeniden gönderilebilir; isteği sadece gönderen geri çekebilir.
   - Spam sayacı yanlış artırılırsa (ör. pencere içinde sıfırlanırsa) gönderim reddedilir; eşik aşılırken `spamSenders` belgesi yazılmazsa gönderim reddedilir.
   - Gönderen `spamSenders` belgesini okuyamaz ve silemez; alıcı okuyup silebilir.
   - Engellenen kullanıcı engelleyene istek gönderemez; başka bir kullanıcı `private/blocks` belgesini okuyamaz.
4. `tools/seed/`: Admin SDK ile emülatöre demo verisi yazan Node script'i. İçerik: Malatya koordinatlarında ~12 kurgusal klinik, 2 veteriner hesabı, 3 hayvan sahibi, sfenks ve Golden Retriever kuralları, demo senaryosunu oynatacak hayvanlar.
5. Seed sonrası `firebase emulators:export ./emulator-data` ile veriyi dışa aktar ve commit'le. Ceren `firebase emulators:start --import ./emulator-data` ile aynı veriyle çalışır.

**Bitti sayılır:** `cd firestore-tests && npm test` yeşil; seed verisi Emulator UI'da görünüyor; Firebase implementasyonu ile uygulama emülatöre bağlanıp klinik listesini okuyabiliyor.

### Faz 3 — İş mantığı (Toprak)

1. `lib/domain/eligibility.dart`: uygunluk hesabı, saf Dart (Firebase'e bağımlı değil).
2. Durum geçişleri: belge geri çekme, onay/red, eşleşme isteği kabul (`contactShares` ile tek batch)/red/geri çekme/yeniden gönderim (30 gün ve `resendAllowed` kontrolü), spam sayacı ve pencere hesabı (`lib/domain/` altında saf Dart, birim testli), hayvanı pasif yapınca bekleyen isteklerin iptali (tek batch), engelleme ve engel kaldırma (tek batch).
3. Devir akışı: alıcının devri kabul etmesi tek batch'te `pets.ownerId`'yi, o hayvanın `healthRecords` ve `healthDocuments` belgelerindeki `ownerId`'yi günceller ve bekleyen eşleşme isteklerini iptal eder.

**Bitti sayılır:** uygunluk ve durum geçişleri için birim testleri geçiyor; devir akışı için kural testi geçiyor.

> Devir, kuralları en karmaşık akış. Zaman sıkışırsa ilk ertelenecek iş budur; raporda "kapsam dışı bırakıldı" diye belirtilir.

### Faz 4 — Arayüz (paylaşılır)

Ceren Faz 1'den sonra sahte verilerle başlar; Toprak Faz 2–3 bitince katılır.

**A tarafı (veteriner bulma):**
- Uygulama kabuğu: tema, `go_router` ile rol bazlı yönlendirme (sahip / veteriner ana ekranları)
- Giriş/kayıt ekranları
- Harita (konum izni, yakındaki klinikler, mesafe telefonda hesaplanır)
- Tür ve imkân filtreleri (telefonda filtrelenir; Firestore sorgusu tek `array-contains` destekler)
- Klinik detayı, yıldız puanı, yorum yazma (ortalama puan telefonda hesaplanır)

**B tarafı (hayvan ve eşleştirme):**
- Hayvan profili ekleme/düzenleme, kaydı kaldırma
- Belge yükleme (fotoğraf seç, sıkıştır, boyut kontrolü, klinik/veteriner seç), bekleyen belgeyi geri çekme
- Veteriner ekranı: bekleyen belgeler, görseli görüntüleme, onay / sebepli red
- Uygun adaylar, istek gönderme/kabul/red ("Reddet" ve "Reddet ve engelle"), kabulden sonra telefon ve WhatsApp bağlantısı
- Gönderilen istekler listesi: bekleyen isteği geri çekme
- Reddedilen istekler listesi: alıcı için "tekrar istek göndermesine izin ver" düğmesi
- Spam kutusu: spam'e düşen istekler ve kişiler; "spam değil" ve "engelle"
- Kullanıcı engelleme ve engellenenler listesi (engeli kaldırma)
- Devir isteği gönderme/kabul

B tarafı daha büyük; A tarafını alan kişi kabuğu ve giriş ekranlarını da üstlenir.

**Bitti sayılır:** her ekran Android emülatöründe gerçek Firebase implementasyonuyla (emülatör verisi üzerinde) çalışıyor.

### Faz 5 — Entegrasyon, demo ve rapor (birlikte)

1. Sahte implementasyon override'larını kaldır.
2. Demo senaryosunu Android emülatöründe baştan sona oynat: sfenks sahibi ekokardiyografi yapan kliniği bulur → raporu yükler → veteriner onaylar → kedi havuza girer → uygun adaya istek → kabul → iletişim bilgisi görünür.
3. Demo için `emulator-data`'yı temiz senaryo verisiyle yeniden üret.
4. README düzeltmeleri: Teknolojiler tablosu (Storage çıkar, Riverpod ekle), bozuk tablo ayırıcıları, `---` öncesi boş satır, öğrenci numaralarını kaldır.
5. Rapor ve sunum.

## Çalışma düzeni

- `main` dalına doğrudan push yok. Her iş `feature/<kısa-ad>` dalında, PR ile birleşir; PR'ı diğer kişi inceler.
- Her PR öncesi: `flutter analyze` ve `flutter test`; kural değiştiyse `firestore-tests` da.
- Haftada en az bir kez ve her PR birleşmeden önce Android emülatöründe dene; web'de çalışması yeterli değil.
- Claude Code ile her fazın başında: "PLAN.md'deki Faz N'i uygula, önce planını çıkar ve onayımı bekle" diye başla.

## Açık konular

- [x] Devirde alıcı nasıl bulunacak? Karar (27 Kasım): profilde gösterilen kısa paylaşım kodu (`users/{uid}.shareCode`). E-postayla arama, e-postaları diğer kullanıcılara açacağı için seçilmedi.
- [ ] Sfenks (HCM taraması) ve Golden Retriever (kalça/dirsek skorlaması, göz muayenesi) testlerinin geçerlilik süreleri ve yaş sınırları kaynağından doğrulanacak. Seed'e girene kadar demo değeri olarak işaretli kalır.
- [ ] Demo Firebase emülatöründe mi, gerçek projede mi? Öneri: emülatör. İnternet ve kota riski yok, her sunumda temiz veri, servis hesabı anahtarı hiç gerekmez. Gerçek projeye geçilirse composite index'ler (`firestore.indexes.json`) eklenmeli; emülatör index eksikliğini hata olarak göstermez.
