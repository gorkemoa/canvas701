# Canvas701 & Creators – Mobil Uygulama & Mimari Kuralları

## 1. Projenin Amacı
Bu proje, tek bir mobil uygulama içinde iki ayrı ürünün birlikte yaşadığı bir yapıdır:
- **Canvas701**: Uygulama sahibinin tek satıcı olduğu, kürasyonlu tablo satış platformu.
- **Creators**: Kullanıcıların kendi görsellerini yükleyip satış yaptığı, komisyon bazlı pazar yeri.

Uygulama ilk etapta sadece Canvas701 aktif olacak şekilde tasarlanır. Creators alanı mimaride hazırdır, ancak özellik olarak kapalı başlar.

## 2. Temel Ürün Stratejisi
### Canvas701 (Başlangıç / MVP)
- Tek satıcı: uygulama sahibi
- Premium, sade, galeri hissi
- Amaç: Satış yapmak, marka algısı oluşturmak
- Kullanıcı sadece alıcıdır

### Creators (İleri Faz)
- Çoklu satıcı (kullanıcılar)
- Platform komisyon alır
- Ölçeklenebilir yapı
- İlk etapta kapalı

*İki ürün iki ayrı uygulama değildir. Tek uygulama – iki modül mantığı vardır.*

## 3. MVP Kapsamı (Canvas701)
### MVP’de OLAN
- Ürün listeleme
- Koleksiyon / kategori yapısı
- Ürün detay sayfası
- Sepet
- Satın alma akışı (UI seviyesinde)
- Sipariş sonucu ekranı
- Favori ekleme (opsiyonel)

### MVP’de OLMAYAN (bilinçli)
- Kullanıcı ürün yükleme
- Creator onboarding
- Komisyon hesaplama
- Yorum / puanlama
- Sosyal özellikler

## 4. Tasarım Yaklaşımı
- **Mock YOK**: Telefon mockup’ları veya sahte verilerle dolu vitrinler kullanılmayacak.
- **Hedef**: Gerçek uygulama ekranı gibi düşünmek, büyük görseller, net tipografi, boşluk odaklı sade UI.
- **Creators Tasarımı**: İlk etapta iskelet/placeholder olarak kalacak, Canvas701’i gölgelemeyecek.

## 5. Mimari Yapı (Frontend – Flutter)
\`\`\`
lib/
 ├─ canvas701/
 │   ├─ api/        → sadece Canvas701 backend
 │   ├─ theme/      → Canvas701’e özel UI
 │   ├─ view/
 │   ├─ viewmodel/
 │   └─ model/
 ├─ creators/
 │   ├─ api/        → sadece Creators backend
 │   ├─ theme/      → Creators’a özel UI
 │   ├─ view/
 │   ├─ viewmodel/
 │   └─ model/
 ├─ core/
 │   ├─ app_mode.dart
 │   ├─ feature_flags.dart
 │   └─ app_router.dart
 └─ main.dart
\`\`\`

### Mimari Prensipler
- **MVVM** deseni kullanılır.
- Canvas701 ve Creators birbirini bilmez.
- API’ler ve Theme’ler her modül için ayrıdır.
- \`core\` sadece uygulama seviyesi kararlar içerir.

## 6. Teknik Kurallar & Backend Bağlantısı

### 1. API Endpoints
- **Base URL**: \`https://api.canvas701.com/c701/v1.0.0/\`
- **Tüm endpoint'ler** `lib/canvas701/api/api_constants.dart` içinde tanımlanır.
- Asla view veya service içinde hardcode endpoint yazmayın.

### 2. Models
- Her API isteği için **Request** ve **Response** modeli oluşturun.
- \`toJson()\` ve \`fromJson()\` metodlarını ekleyin.
- Modeller ilgili modülün (canvas701 veya creators) \`model/\` klasörü altında veya genel ise \`lib/models/\` altında kategorize edilir.

### 3. Services
- API çağrıları sadece **Service** sınıflarında yapılır.
- Her domain için ayrı service (AuthService, ProductService, etc.).
- Singleton pattern kullanın.

### 4. ViewModels
- UI mantığı ve state yönetimi **ViewModel**'lerde yapılır.
- View ile Service arasında köprü görevi görür.
- \`ChangeNotifier\` extend eder.

### 5. Error Handling
- **ASLA** statik hata mesajları yazmayın.
- **401 status code** = Basic Auth veya Yetkilendirme hatası.
- **403 status code** = Token geçersiz veya süresi dolmuş. Bu durumda token silinmeli ve kullanıcı login ekranına yönlendirilmelidir.
- **417 status code** = Backend validation hatası.
- Hata geldiğinde API'den gelen \`message\` alanını kullanıcıya gösterin.
- Validator kullanmayın, backend'den gelen mesajları gösterin.

\`\`\`dart
// ✅ DOĞRU
if (response.statusCode == 417) {
  showError(response.data['message']);
}

// ❌ YANLIŞ
if (response.statusCode == 417) {
  showError('Kullanıcı adı veya şifre hatalı'); // Statik mesaj
}
\`\`\`

### 6. Örnek Kullanım (Login)
**Endpoint**: \`POST {{BASE_URL}}service/auth/login\`

**Request Body**:
\`\`\`json
{
	"userEmail" : "ridvan.dasdelen@gmail.com",
	"userPassword" : "ridvan123"
}
\`\`\`

**Response Body (Success)**:
\`\`\`json
{
    "error": false,
    "success": true,
    "data": {
        "status": "success",
        "message": "Giriş Başarılı!",
        "userID": 143,
        "token": "euQp2Us5VwVPUqNE446sKmHOgKAECxFb"
    },
    "200": "OK"
}
\`\`\`

## 7. Core Katmanı
\`core\` iş mantığı, tasarım veya API içermez.
- **app_mode**: Uygulamanın hangi evrende çalıştığını belirler (canvas, creators, hybrid).
- **feature_flags**: Özelliklerin (örn. Creators) açık/kapalı durumunu yönetir.
- **app_router**: Uygulamanın başlangıç noktasını ve routing kararlarını yönetir.

## 8. Sayfa Davranışları (Profil Sayfaları)
- **ProfilePage** & **ProfileInfoPage**: Her açılışta \`getUser\` API çağrısı yapılır.
- Kullanıcı bilgileri güncellenmiş olabilir, her zaman en güncel veriyi göster.
- Loading state ile kullanıcıya yüklenme durumu gösterilir.

\`\`\`dart
// ✅ DOĞRU - Her girişte yenile
@override
void initState() {
  super.initState();
  _refreshUserData(); // Her zaman güncel veri
}
\`\`\`

## 9. 🔑 Hatırlatmalar
1. ✅ Endpoint'ler tek yerde (\`api_constants.dart\`)
2. ✅ Model'ler \`model/\` klasöründe
3. ✅ API çağrıları \`services/\` içinde
4. ✅ State yönetimi \`viewmodels/\` içinde
5. ✅ 417 hatası = Backend mesajını göster
6. ✅ Profil sayfalarına her girişte kullanıcı bilgilerini yenile
7. ❌ Statik hata mesajı yazma
8. ❌ Validator kullanma (backend validation)
