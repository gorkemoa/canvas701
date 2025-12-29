Canvas701 & Creators – Mobil Uygulama
1. Projenin Amacı

Bu proje, tek bir mobil uygulama içinde iki ayrı ürünün birlikte yaşadığı bir yapıdır:

Canvas701
→ Uygulama sahibinin tek satıcı olduğu, kürasyonlu tablo satış platformu

Creators
→ Kullanıcıların kendi görsellerini yükleyip satış yaptığı, komisyon bazlı pazar yeri

Uygulama ilk etapta sadece Canvas701 aktif olacak şekilde tasarlanır.
Creators alanı mimaride hazırdır, ancak özellik olarak kapalı başlar.

2. Temel Ürün Stratejisi
Canvas701 (Başlangıç / MVP)

Tek satıcı: uygulama sahibi

Premium, sade, galeri hissi

Amaç:

Satış yapmak

Marka algısı oluşturmak

Kullanıcı sadece alıcıdır

Creators (İleri Faz)

Çoklu satıcı (kullanıcılar)

Platform komisyon alır

Ölçeklenebilir yapı

İlk etapta kapalı

İki ürün iki ayrı uygulama değildir.
Tek uygulama – iki modül mantığı vardır.

3. MVP Kapsamı (Canvas701)
MVP’de OLAN

Ürün listeleme

Koleksiyon / kategori yapısı

Ürün detay sayfası

Sepet

Satın alma akışı (UI seviyesinde)

Sipariş sonucu ekranı

Favori ekleme (opsiyonel)

MVP’de OLMAYAN (bilinçli)

Kullanıcı ürün yükleme

Creator onboarding

Komisyon hesaplama

Yorum / puanlama

Sosyal özellikler

MVP’nin hedefi:
“Canvas701 satılabilir bir ürün mü?” sorusuna cevap vermek.

4. Tasarım Yaklaşımı
Mock YOK

Telefon mockup’ları

Sahte verilerle dolu vitrinler

Dribbble/Behance gösterişi

❌ Yapılmayacak.

Tasarımda hedef

Gerçek uygulama ekranı gibi düşünmek

Büyük görseller

Net tipografi

Boşluk odaklı, sade UI

E-ticaret + galeri dengesi

Creators tasarımı

İlk etapta:

iskelet

placeholder

kapalı alan hissi

Canvas701’i gölgelememeli

5. Mimari Yapı (Frontend – Flutter)
lib/
 ├─ canvas701/
 │   ├─ api/        → sadece Canvas701 backend
 │   ├─ theme/      → Canvas701’e özel UI
 │   ├─ view/
 │   ├─ viewmodel/
 │   └─ model/
 │
 ├─ creators/
 │   ├─ api/        → sadece Creators backend
 │   ├─ theme/      → Creators’a özel UI
 │   ├─ view/
 │   ├─ viewmodel/
 │   └─ model/
 │
 ├─ core/
 │   ├─ app_mode.dart
 │   ├─ feature_flags.dart
 │   └─ app_router.dart
 │
 └─ main.dart

Mimari prensipler

MVVM

Canvas701 ve Creators birbirini bilmez

API’ler ayrı

Theme’ler ayrı

core sadece uygulama seviyesi kararlar içerir

6. Core Katmanı (Minimal)

core iş mantığı içermez, tasarım içermez, API içermez.

app_mode

Uygulamanın hangi evrende çalıştığını belirler:

canvas

creators

hybrid (ileride)

feature_flags

Creators açık mı?

bazı alanlar gizli mi?

MVP’de:

statik değerler yeterlidir.

app_router

Uygulama nereden başlar?

Canvas701 mi açılır?

Creators kapalı mı?

Routing kararı modülün değil, uygulamanındır.

7. Backend (Şimdilik Yok, Ama Hazır)
Plan

PHP ile REST API

Canvas701 ve Creators ayrı API’ler

İleride bağlanacak

Şu an

UI tasarım

dummy / static data

gerçek API düşünülerek modelleme

Kavramsal modeller

Product

Collection

Order

Creator

Commission

8. Canvas701 & Creators Ayrımı (Mantık)

Her ürün için:

sahibi kim?

Canvas701

Creator

Bu ayrım:

UI’da

fiyatlandırmada

ileride backend’de
aynı şekilde çalışır.