# VetMatch

**[Türkçe](#türkçe) · [English](#english)**

---

<a id="türkçe"></a>

## Türkçe

> Yakındaki veteriner klinikleri bulmayı ve veteriner onaylı sağlık testlerine dayalı, güvenli bir eşleştirme sistemini tek uygulamada birleştiren Android uygulaması.

**Durum:** Proje Raporu · 6 Kasım 2026 · Hazırlayanlar: Toprak Budunoğlu 02230202066 / Ceren Parmaksız 02230202070

### İçindekiler

1. [Proje Özeti](#1-proje-özeti)
2. [Teknolojiler](#2-teknolojiler)
3. [Kapsam](#3-kapsam)
4. [Kullanıcı Rolleri](#4-kullanıcı-rolleri)
5. [Veri Modeli](#5-veri-modeli)
6. [Akışlar ve Durum Geçişleri](#6-akışlar-ve-durum-geçişleri)
7. [Haftalık Plan ve İş Bölümü](#7-haftalık-plan-ve-iş-bölümü)

### 1. Proje Özeti

Mobil Programlama dersi için, iki kişilik ekiple, yaklaşık 6 haftada geliştirilecek bir Android uygulaması. Uygulama iki modülden oluşur:

- **Veteriner bulucu:** Kullanıcı yakınındaki klinikleri harita üzerinde görür, bakılan türlere ve kliniğin imkânlarına (ör. ekokardiyografi, egzotik hayvan muayenesi) göre filtreler, klinikleri puanlar ve yorumlar.
- **Sağlık kontrollü eşleştirme:** Çiftleştirme için uygunluk, ırka özgü sağlık testlerinin veteriner onaylı belgelerle kanıtlanmasına bağlıdır. Uygun hayvanların sahipleri karşılıklı onayla iletişime geçer.

Ders kapsamında tüm veriler (klinikler, veteriner hesapları, demo hayvanlar) sahte ve kurgusal olacaktır; gerçek klinik isimleri kullanılmayacaktır.

### 2. Teknolojiler

Arayüz Flutter, sunucu tarafı Firebase; hedef platform yalnızca Android.

| Katman | Seçim |
|---|---|---|
| Arayüz | **Flutter** (Dart) | 
| Kimlik doğrulama | **Firebase Auth** | 
| Veritabanı | **Cloud Firestore** | 
| Dosya depolama | **Firebase Storage** | 
| Harita | **flutter_map** (OpenStreetMap) | 
| İletişim | **url_launcher** | 
| Sürüm kontrolü | **Git + GitHub** |

- Cloud Functions kullanılmayacak. Uygunluk süresi, sorgularda geçerlilik tarihine bakılarak kontrol edilecek. Mesafe hesabı telefonda yapılacak.
- Demo Android emülatöründe yapılacak.

### 3. Kapsam

#### Ders için yapılacaklar
- Hayvan sahibi ve veteriner rolleriyle kayıt/giriş (veteriner hesapları demo için önceden oluşturulur)
- Harita üzerinde klinikler; bakılan tür ve kliniğin imkânlarına göre filtreleme
- Klinik detay sayfası, yıldız puanı ve yorum
- Hayvan profili (tür, ırk, cinsiyet, doğum tarihi, kısırlaştırma durumu, 15 haneli çip numarası)
- Sağlık belgesi yükleme ve veteriner onayı/reddi
- İki ırkla sınırlı kural seti: sfenks kedi + bir köpek ırkı
- Süreli uygunluk durumu (süresi dolan hayvan havuzdan düşer)
- Uygun aday listesi; eşleşme isteği gönderme/kabul/red
- Kabulden sonra iletişim bilgisi paylaşımı
- Hayvan kaydını kaldırma ve sahiplendirme (devir)

#### Kapsam dışı
Ödeme, gerçek veteriner kimlik doğrulaması, PETVET entegrasyonu, reklam sistemi.

### 4. Kullanıcı Rolleri

Ders kapsamında iki rol var; her veteriner hesabı bir kliniğe bağlıdır.

| Rol | Yapabildikleri |
|---|---|
| **Hayvan sahibi** | Klinik arama ve yorumlama, hayvan profili yönetimi, belge yükleme ve bekleyen belgeyi geri çekme, eşleşme isteği gönderme/kabul/red, kullanıcı engelleme, hayvan devri |
| **Veteriner** | Kendisine gönderilen belgeleri onaylama veya red sebebi yazarak reddetme, kullanıcı engelleme |

### 5. Veri Modeli

| Koleksiyon | Temel alanlar |
|---|---|
| `users` | rol, ad, telefon, (veteriner ise) bağlı klinik, engellenen kullanıcılar |
| `clinics` | ad, konum, bakılan türler, imkânlar |
| `clinics/reviews` | yazan kullanıcı, puan, yorum, tarih |
| `pets` | sahip, tür, ırk, cinsiyet, doğum tarihi, kısırlaştırılmış mı, çip no, aktif mi |
| `healthRecords` | hayvan, test türü, belge yolu, seçilen veteriner, durum, red sebebi, geçerlilik tarihi |
| `breedRules` | ırk, zorunlu testler, testlerin geçerlilik süresi, yaş sınırları |
| `matchRequests` | gönderen hayvan, alan hayvan, durum, tarih |

Hayvanlar veritabanından silinmez; "aktif mi" alanı kapatılır (soft delete). Böylece bağlı sağlık kayıtları ve istekler bozulmaz.

**Güvenlik kuralları:**
- Bir sağlık belgesini yalnızca hayvanın sahibi ve seçilen veteriner okuyabilir.
- Telefon numarası yalnızca kabul edilmiş bir istekten sonra karşı tarafa görünür.

### 6. Akışlar ve Durum Geçişleri

Her akış kullanıcı hatasına izin verecek şekilde tasarlandı; kötü niyet varsayılmıyor.

#### Sağlık belgesi
`beklemede` → `onaylandı` veya `reddedildi`; `onaylandı` → `süresi doldu`

- Sahip belgeyi yükler ve onaylayacak kliniği/veterineri seçer.
- Sahip, beklemedeki belgeyi geri çekebilir (ör. yanlış klinik seçildiyse).
- Veteriner onaylar ya da kısa bir red sebebi yazarak reddeder; sahip sebebi görür ve yeniden yükleyebilir.
- Onaylanan belge, kural setindeki geçerlilik süresi bitince "süresi doldu" durumuna geçer ve hayvan havuzdan düşer.

#### Uygunluk
Hayvan aktif, kısırlaştırılmamış, yaş sınırları içinde ve ırkının zorunlu testleri geçerliyse eşleştirme havuzuna girer.

#### Eşleşme isteği
`beklemede` → `kabul edildi` veya `reddedildi`

- Kabulde iki taraf da birbirinin iletişim bilgisini görür.
- Kötüye kullanım için ayrıca kullanıcı engelleme seçeneği vardır.

#### Hayvan kaydını kaldırma
Arayüzde "kaydı kaldır" düğmesi; arka planda hayvan pasif yapılır, bekleyen istekleri iptal edilir.

#### Sahiplendirme (devir)
Önceki sahip devir isteği gönderir, yeni sahip kendi hesabından onaylar.

- **Değişen:** hayvanın kayıtlı olduğu kullanıcı
- **Hayvanla kalan:** sağlık kayıtları
- **İptal edilen:** bekleyen eşleşme istekleri
- **Ekranda not:** Uygulama içi devir, PETVET'teki yasal sahip değişikliği bildiriminin yerine geçmez.

### 7. Haftalık Plan ve İş Bölümü

| Hafta | İş |
|---|---|
| 1 | Flutter + Firebase kurulumu, giriş/kayıt, roller, veri modeli, demo klinik verisi (birlikte) |
| 2 | Harita, filtreler, klinik detay sayfası |
| 3 | Yorumlar, hayvan profili, belge yükleme |
| 4 | Veteriner onay/red ekranı, kural kontrolü, geçerlilik süresi |
| 5 | Aday listesi, istek/kabul/red, iletişim paylaşımı, kayıt kaldırma ve devir |
| 6 | Tampon: hata düzeltme, demo verisi, rapor, sunum |

**İş bölümü:** Bir kişi veteriner bulma tarafını (harita, filtre, klinik, yorum), diğeri hayvan ve eşleştirme tarafını (profil, belge, onay, kurallar, istekler) üstlenir.

**Demo senaryosu:** Sfenks sahibi ekokardiyografi yapan bir klinik bulur, raporunu yükler, veteriner onaylar, kedi havuza düşer, uygun bir adaya istek gönderilir ve kabul edilir.
---

<a id="english"></a>

## English

> An Android app that combines finding nearby veterinary clinics with a safe breeding-match system based on vet-approved health tests.

**Status:**Project Report · 6 November 2026 · Prepared by: Toprak Budunoğlu 02230202066 / Ceren Parmaksız 02230202070

### Contents

1. [Overview](#1-overview)
2. [Technologies](#2-technologies)
3. [Scope](#3-scope)
4. [User Roles](#4-user-roles)
5. [Data Model](#5-data-model)
6. [Flows and State Transitions](#6-flows-and-state-transitions)
7. [Weekly Plan and Division of Work](#7-weekly-plan-and-division-of-work)

### 1. Overview

An Android app to be built for the Mobile Programming course by a two-person team in about 6 weeks. The app has two modules:

- **Vet finder:** Users see nearby clinics on a map, filter them by species treated and clinic capabilities (e.g. echocardiography, exotic animal examination), and rate and review clinics.
- **Health-checked matching:** Eligibility for breeding depends on breed-specific health tests being proven with vet-approved documents. Owners of eligible animals get in touch by mutual consent.

For the course, all data (clinics, vet accounts, demo animals) will be fake and fictional; no real clinic names will be used.

### 2. Technologies

Flutter for the UI, Firebase for the backend; Android is the only target platform.

| Layer | Choice | 
|---|---|---|
| UI | **Flutter** (Dart) | 
| Authentication | **Firebase Auth** | 
| Database | **Cloud Firestore** | 
| File storage | **Firebase Storage** | 
| Maps | **flutter_map** (OpenStreetMap) | 
| Contact | **url_launcher** | 
| Version control | **Git + GitHub** |

- Cloud Functions will not be used. Eligibility expiry will be checked in queries by looking at the validity date. Distance will be calculated on the phone.
- The demo will run on the Android emulator.
>

### 3. Scope

#### In scope for the course
- Sign-up/sign-in with pet owner and vet roles (vet accounts are pre-created for the demo)
- Clinics on a map; filtering by species treated and clinic capabilities
- Clinic detail page, star rating and reviews
- Pet profile (species, breed, sex, date of birth, neuter status, 15-digit microchip number)
- Health document upload and vet approval/rejection
- Rule set limited to two breeds: Sphynx cat + one dog breed
- Time-limited eligibility (an animal whose eligibility expires drops out of the pool)
- List of eligible candidates; sending/accepting/rejecting match requests
- Sharing contact details after acceptance
- Removing a pet's listing and transferring ownership

#### Out of scope
Payments, real vet identity verification, PETVET integration, advertising.

### 4. User Roles

There are two roles for the course; every vet account is linked to a clinic.

| Role | What they can do |
|---|---|
| **Pet owner** | Search and review clinics, manage pet profiles, upload documents and withdraw pending ones, send/accept/reject match requests, block users, transfer a pet |
| **Vet** | Approve documents sent to them, or reject them with a written reason; block users |

### 5. Data Model

| Collection | Key fields |
|---|---|
| `users` | role, name, phone, linked clinic (if vet), blocked users |
| `clinics` | name, location, species treated, capabilities |
| `clinics/reviews` | author, rating, comment, date |
| `pets` | owner, species, breed, sex, date of birth, neutered, chip no., active |
| `healthRecords` | pet, test type, document path, selected vet, status, rejection reason, valid until |
| `breedRules` | breed, required tests, test validity periods, age limits |
| `matchRequests` | sending pet, receiving pet, status, date |

Pets are never deleted from the database; the "active" field is switched off (soft delete). This keeps linked health records and requests intact.

**Security rules:**
- A health document can only be read by the pet's owner and the selected vet.
- A phone number becomes visible to the other party only after a request has been accepted.

### 6. Flows and State Transitions

Every flow is designed to tolerate user mistakes; bad intent is not assumed.

#### Health document
`pending` → `approved` or `rejected`; `approved` → `expired`

- The owner uploads the document and chooses the clinic/vet who will approve it.
- The owner can withdraw a pending document (e.g. if the wrong clinic was chosen).
- The vet approves, or rejects with a short reason; the owner sees the reason and can upload again.
- An approved document moves to "expired" when the validity period in the rule set ends, and the pet drops out of the pool.

#### Eligibility
A pet enters the matching pool if it is active, not neutered, within the age limits, and its breed's required tests are valid.

#### Match request
`pending` → `accepted` or `rejected`

- On acceptance, both sides see each other's contact details.
- A separate option to block users exists for abuse.

#### Removing a pet's listing
A "remove listing" button in the UI; behind the scenes the pet is set to inactive and its pending requests are cancelled.

#### Ownership transfer
The previous owner sends a transfer request; the new owner approves it from their own account.

- **Changes:** the user the pet is registered to
- **Stays with the pet:** health records
- **Cancelled:** pending match requests
- **On-screen note:** An in-app transfer does not replace the legal change-of-ownership notification in PETVET.

### 7. Weekly Plan and Division of Work

| Week | Work |
|---|---|
| 1 | Flutter + Firebase setup, sign-in/sign-up, roles, data model, demo clinic data (together) |
| 2 | Map, filters, clinic detail page |
| 3 | Reviews, pet profile, document upload |
| 4 | Vet approval/rejection screen, rule checks, validity periods |
| 5 | Candidate list, request/accept/reject, contact sharing, listing removal and transfer |
| 6 | Buffer: bug fixes, demo data, report, presentation |

**Division of work:** One person takes the vet finder side (map, filters, clinics, reviews); the other takes the pet and matching side (profiles, documents, approvals, rules, requests).

**Demo scenario:** A Sphynx owner finds a clinic that offers echocardiography, uploads the report, the vet approves it, the cat enters the pool, a request is sent to an eligible candidate and is accepted.

