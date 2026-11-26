# ADR-001: Sağlık belgelerinin depolanması

**Durum:** Kabul edildi
**Tarih:** 26 Kasım 2026
**Karar verenler:** Toprak Budunoğlu, Ceren Parmaksız

## Bağlam

Proje raporunda sağlık belgeleri (ör. sfenks kedi için ekokardiyografi raporu) için Firebase Storage seçilmişti. Uygulamaya geçmeden önce yapılan kontrolde, Firebase'in 30 Ekim 2024'ten beri yeni bir Storage bucket'ı açmak için projenin Blaze (kullandıkça öde) planında olmasını şart koştuğu görüldü. Blaze planında ücretsiz kullanım kotası devam ediyor, ancak plana geçmek için faturalandırma hesabına kart bağlamak gerekiyor. Ekip olarak kart bağlamadan ilerlemek istiyoruz.

Kısıtlar:
- Ders projesi; demo Android emülatöründe, sahte verilerle yapılacak.
- Cloud Functions kullanılmıyor; tüm mantık istemcide ve güvenlik kurallarında.
- Raporda tanımlı güvenlik kuralı korunmalı: bir sağlık belgesini yalnızca hayvanın sahibi ve seçilen veteriner okuyabilir.
- Demo senaryosunda veteriner, yüklenen raporun görüntüsüne bakarak onay veriyor; PDF zorunlu değil.

## Karar

Sağlık belgeleri, istemcide sıkıştırılmış JPEG görseller olarak **base64 metni hâlinde Cloud Firestore'da** tutulacak. Görseller, `healthRecords` belgelerinden ayrı bir koleksiyonda (`healthDocuments/{recordId}`) saklanacak.

## Değerlendirilen seçenekler

### Seçenek A: Firebase Storage (Blaze planı)
| Boyut | Değerlendirme |
|---|---|
| Karmaşıklık | Düşük |
| Maliyet | Kotada ücretsiz, ama kart bağlamak zorunlu |
| Ölçeklenebilirlik | Yüksek |
| Ekip aşinalığı | Orta |

**Artıları:** Gerçek dosya depolama, PDF desteği, raporla birebir uyumlu.
**Eksileri:** Kart bağlamadan kullanılamıyor.

### Seçenek B: Firestore'da base64 (seçilen)
| Boyut | Değerlendirme |
|---|---|
| Karmaşıklık | Düşük |
| Maliyet | Ücretsiz (Spark planı) |
| Ölçeklenebilirlik | Düşük (belge başına 1 MiB sınırı) |
| Ekip aşinalığı | Yüksek (zaten Firestore kullanılıyor) |

**Artıları:** Yeni servis veya SDK yok. Güvenlik kuralları `healthRecords` ile aynı yerde yazılıyor. Firebase Emulator Suite'te sorunsuz çalışıyor.
**Eksileri:** Sadece sıkıştırılmış görsel, PDF yok. Okuma maliyeti görsel boyutuyla artıyor. Gerçek ürüne geçişte değiştirilmesi gerekecek.

### Seçenek C: Supabase Storage (Firebase Auth ile third-party auth)
| Boyut | Değerlendirme |
|---|---|
| Karmaşıklık | Yüksek |
| Maliyet | Ücretsiz plan (1 GB) |
| Ölçeklenebilirlik | Orta |
| Ekip aşinalığı | Düşük |

**Artıları:** Gerçek dosya depolama, PDF desteği, kart gerekmiyor.
**Eksileri:** İkinci bir backend ve SDK, SQL ile yazılan RLS politikaları, iki ayrı yerde güvenlik kuralı. Ücretsiz projeler 1 hafta hareketsiz kalınca duraklatılıyor; demo öncesi risk.

### Seçenek D: Cloudinary vb. görsel servisleri
Sunucu olmadan yükleme yapmak için imzasız (unsigned) yükleme gerekiyor; bu durumda URL'yi bilen herkes dosyaya erişebilir. Sağlık belgesi gizlilik kuralıyla çeliştiği için elendi.

## Ödünleşim analizi

B ve C arasındaki fark, "gerçek dosya depolama" ile "sistem karmaşıklığı" arasındaki ödünleşim. Demo senaryosu PDF gerektirmediği ve proje ölçeklenmeyeceği için C'nin getirdiği ek SDK, ek güvenlik katmanı ve duraklatma riski, ders projesine karşılığı olmayan bir hata yüzeyi ekliyor. B, raporun güvenlik gereksinimini en az parçayla karşılıyor.

## Sonuçlar

- **Kolaylaşan:** Tek backend, tek güvenlik kuralı dosyası, emülatörde uçtan uca test.
- **Zorlaşan:** Belge yalnızca fotoğraf olabilir. Sahip, PDF raporun ekran görüntüsünü veya fotoğrafını yüklemeli.
- **İleride tekrar bakılacak:** Proje ders sonrasında devam ederse belgeler Firebase Storage'a (Blaze) veya başka bir dosya servisine taşınacak. `healthDocuments` ayrı koleksiyon olduğu için taşıma `healthRecords` yapısını bozmaz.

## Uygulama notları

- Görsel `image_picker` ile alınırken `maxWidth: 1280` ve `imageQuality: 70` verilir. Kodlanmış base64 metninin 900 KB'ı geçmesi durumunda yükleme reddedilir ve kullanıcıdan daha net/kırpılmış bir fotoğraf istenir (base64, ham boyutu yaklaşık %33 büyütür).
- `healthDocuments/{recordId}` belgesi yalnızca görsel verisini ve `ownerId` ile `vetId` alanlarını taşır; liste ekranları bu koleksiyonu okumaz, görsel sadece detay ekranında yüklenir.
- Güvenlik kuralı: okuma ve yazma, `request.auth.uid` değeri `ownerId` veya `vetId` ile eşleşiyorsa serbest. Belge oluşturulduktan sonra veri alanı değiştirilemez; yeni yükleme yeni bir sağlık kaydı demektir.

## Yapılacaklar

1. [ ] Rapordaki Teknolojiler tablosundan Firebase Storage satırını çıkar, kararı tek cümleyle açıkla.
2. [ ] `healthDocuments` koleksiyonunu veri modeline ekle.
3. [ ] Sıkıştırma ve boyut kontrolünü yükleme ekranına ekle.
4. [ ] Güvenlik kuralı testini emülatörde yaz: üçüncü bir kullanıcı belgeyi okuyamamalı.
