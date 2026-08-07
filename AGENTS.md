# AGENTS.md

Bu dosya, projede çalışacak yapay zekâ ajanları içindir. Kod yazmadan önce baştan sona oku.

**`CONTRIBUTING.md` bu dosyanın tamamlayıcısıdır ve kod yazım kurallarında bağlayıcıdır.** Burada projenin ne olduğu, nasıl kurulduğu ve hangi tuzakların bulunduğu anlatılır; oradaki klasör yapısı, Page/PageModel ayrımı, widget extraction ve sabit kullanımı kuralları aynen geçerlidir.

---

## Proje

**sky-app** — Yıldız Teknik Üniversitesi **SKY LAB** öğrenci kulübünün mobil uygulaması. Flutter ile yazılmış; iOS, Android ve web hedefleniyor.

Kullanıcılar kulüp üyesi öğrenciler. Uygulama üyelik kartı (SkyPass), etkinlik takibi, kulüp haberleri ve kulübün alt servislerine erişim sağlıyor.

Flutter 3.44.5 (stable), Material 3. Yazı tipi `theme.dart`'ta `fontFamily: 'Poppins'` ile bir kez veriliyor ve bütün kademelere uygulanıyor; `textTheme` yalnızca yazı tipi dışında bir şey söyleyecekse (gövde metninin rengi gibi) girdi içeriyor.

---

## İletişim ve çalışma biçimi

**Türkçe yaz.** Kullanıcı Türkçe yazıyor ve Türkçe yanıt bekliyor. Kod içi yorumlar, `///` doküman yorumları ve kullanıcıya görünen tüm metinler Türkçe. Değişken ve sınıf adları İngilizce kalır — mevcut kod tabanının deseni bu.

**Asla commit atma.** `git commit` ya da `git push` çalıştırma. Bir iş bitince değişen dosyaları özetle ve dur; commit'i kullanıcı kendisi atar. Bu kesin bir kural.

**Görsel doğrulamayı kullanıcı yapıyor.** Uygulamayı çalıştırıp ekran görüntüsü gönderen ve düzeltmeleri isteyen o. `flutter analyze`'ın temiz olması "derleniyor" demektir, "doğru görünüyor" demek değildir — ikisini karıştırma. Görsel bir değişiklik yaptıysan ekranda doğrulamadığını açıkça söyle ve neye bakması gerektiğini belirt.

> iOS simülatörü bu makinede kullanılamıyor: `xcode-select` Xcode'a ayarlı değil ve düzeltme sudo istediği için ajan çalıştıramaz. Denemeye değer, ama çalışmazsa kullanıcıya söyleyip devam et.

**Tasarım referansı: Luma (lu.ma).** Kullanıcı arayüz işlerinde sürekli Luma'nın ekran görüntülerini paylaşıyor ve ölçüt olarak kullanıyor. Luma'dan **desen** alınır, renk alınmaz — uygulamanın kendi teması korunur. Özellikle **tutarlılık** önemseniyor: liste öğeleri eşit yükseklikte olmalı, tipografi kademeleri ölçülü olmalı.

---

## Komutlar

```bash
flutter analyze --no-pub     # her değişiklikten sonra; temiz kalmalı
dart format lib/             # commit öncesi
flutter pub get
```

Projede **test yok** (`test/` klasörü bulunmuyor). Kullanıcı daha önce test istemediğini belirtti; istenmedikçe test yazma.

---

## Mimari

### Klasör düzeni

```
lib/
├── main.dart                 # provider kayıtları + uygulama girişi
├── core/                     # birden fazla feature'ın paylaştığı her şey
│   ├── constants/            # AppColors, AppPaddings, AppRadiuses, AppSizes, AppAssets, AppIcons
│   ├── extensions/           # context_extensions.dart — tema renkleri buradan okunur
│   ├── models/               # link_item.dart
│   ├── router/               # router_manager.dart (GoRouter)
│   ├── services/             # links_service.dart, webview_service.dart
│   ├── theme/                # theme.dart (light/dark), theme_provider.dart
│   ├── widgets/              # AppIcon, AppBarActions, NavItem, UserAvatar, CoverImage, BottomScrim, ColorGlow, SkyButton ...
│   └── shell_page.dart       # appbar + navbar kabuğu
└── features/<ad>/
    ├── data/{models,services}
    └── presentation/{pages,widgets,providers}
```

Feature'lar: `auth`, `calendar`, `home`, `notification`, `profile`, `qr`, `settings`, `team`.

### Durum yönetimi

`provider` kullanılıyor. `main.dart`'ta kayıtlı üç global provider var:

| Provider | Sorumluluk |
|---|---|
| `ThemeProvider` | `ThemeMode` (sistem/açık/koyu), `SharedPreferences`'ta saklanır |
| `UserProvider` | Oturum ve `User`; `AuthService` üzerinden |
| `EventProvider` | Etkinlik listeleri; splash'te doldurulur |

### Yönlendirme

`go_router`. `router_manager.dart` içinde tek bir `GoRouter`. Yapı:

- **Üst seviye** (tam ekran, kök navigator): `/`, `/auth`, `/notification`, `/webview`, `/settings` (alt rota: `/settings/contact`)
- **`ShellRoute`** (appbar + navbar kabuğu içinde): `/home`, `/calendar`, `/team`, `/profile` (alt rota: `/profile/certificates`)

`redirect` oturum durumuna göre `/`, `/auth` ve `/home` arasında yönlendiriyor.

> ⚠️ **Kabuğun içindeyken tam ekran bir şey açacaksan** rotayı üst seviyeye koy ya da `parentNavigatorKey: _rootNavigatorKey` ver. Aksi hâlde sayfa navbar'ın altında kalır. Aynı tuzak `OpenContainer` için de geçerli: `useRootNavigator: true` vermezsen detay sayfası kabuğun içinde açılır.

### Backend

- REST: `https://api.yildizskylab.com` — yanıtlar `{success, message, data, ...}` zarfıyla geliyor, `data` açılarak kullanılıyor (`EventService`'e bak).
- Kimlik doğrulama: Keycloak, `https://e.yildizskylab.com/realms/e-skylab`, `flutter_appauth` ile OAuth/PKCE. Token'lar `flutter_secure_storage`'da.

> Çıkışta `UserProvider.user` null'a düşüyor ve sayfalar aynı karede yeniden çiziliyor; `/auth`'a yönlendirme ancak bir sonraki karede oluyor. Kullanıcıyı okuyan sayfalar bu tek kareyi karşılamak zorunda — `user!` yazmak orada patlar (bkz. `profile_page.dart`).

### Dikkat çeken paketler

| Paket | Nerede |
|---|---|
| `reicon_flutter` | Bütün ikonlar (`AppIcon` üzerinden) |
| `animations` | Yalnızca haber tile'ının `OpenContainer` geçişi |
| `palette_generator` | Etkinlik kapağından zemin rengi (`EventPaletteService`) |
| `share_plus` | Etkinlik detayındaki paylaş butonu — **native bağımlılık**, eklendiğinde hot reload yetmez |
| `timeago` | Bildirim listesindeki göreli zaman (`tr` ve `tr_short` locale'leri `main.dart`'ta kayıtlı) |

---

## Tema ve renk — en kritik kural

Uygulama açık ve koyu temayı birlikte destekliyor. Renkler **iki kaynağa** ayrılmıştır ve karıştırılması açık temayı sessizce bozar.

**Temaya göre değişenler `context`'ten okunur** (`core/extensions/context_extensions.dart`):

`backgroundColor` · `tileColor` · `elevatedColor` · `textPrimary` · `textSecondary` · `textTertiary` · `dividerColor` · `accentColor` · `onAccentColor`

> `onAccentColor`, `accentColor` zemini üzerindeki içerik içindir. Vurgu rengi koyu temada açık lila, açık temada koyu mor olduğu için üstündeki metin de yön değiştirir; her iki temada beyaz kalan `AppColors.onAccent` onun yerine kullanılamaz.

**Temadan bağımsız olanlar `AppColors`'ta kalır:** marka renkleri (`primaryColor`, `primaryStrong`, `blue`, `red`, `green` ...), doygun zemin üstündeki içerik (`onAccent`), SkyPass kartı renkleri, navbar gölgeleri.

```dart
// ❌ açık temada kırılır
color: Colors.white
color: AppColors.darkTextPrimary

// ✅
color: context.textPrimary
color: AppColors.red   // marka rengi
```

`AppColors` içindeki `dark*` / `light*` sabitleri **yalnızca** `theme.dart`'taki `ColorScheme`'leri besler; widget'larda doğrudan kullanılmaz.

> **İstisna — etkinlik detay sayfası.** `event_detail_page.dart` her iki temada da koyu: zemini kapak görselinin baskın renginden (`palette_generator`) türetiliyor ve o renk açık bir zemine karıştırıldığında soluyor. Bu sayfadaki renkler `context` erişimcilerinden değil `AppColors.coverBackdropBase` ve `onCover*` sabitlerinden okunur. Aynı nedenle `SkyButton` ve `AppBarActions` kendilerine açıkça renk verildiğinde tema varsayılanlarını kullanmaz.

`context`'ten gelen renk derleme zamanı sabiti olmadığı için o widget `const` olamaz — `const`'u kaldır. Refactor sırasında en sık karşılaşılan derleme hatası budur.

Ortak AppBar özellikleri (`backgroundColor`, `elevation`, `centerTitle`, `actionsPadding`, `iconTheme`, `titleTextStyle`, `systemOverlayStyle`) `appBarTheme`'de merkezîdir; sayfalarda tekrar edilmez.

---

## İkonlar

Material ikonları **kullanılmıyor**. İkonlar `reicon_flutter` paketinden geliyor.

**Kritik fark:** Reicon `IconData` döndürmez, ham SVG path string'i verir. Bu yüzden `Icon(Icons.x)` → `Icon(Reicon...)` şeklinde bir bul-değiştir mümkün değildir; çizim `SvgPicture.string` ile yapılır ve bu iş `AppIcon` widget'ında toplanmıştır.

```dart
AppIcon(AppIcons.home)
AppIcon(AppIcons.home, filled: true, size: AppSizes.icon, color: context.accentColor)
```

İkon adları `core/constants/app_icons.dart` içinde. Widget imzalarında ikon alanları `IconData` değil **`String`** tipindedir.

Yeni ikon eklerken adın **hem Outline hem Filled** ağırlığında bulunduğunu doğrula; bulunmayan ad sessizce boş kutu çizer:

```bash
grep -o "^  '[a-zA-Z0-9]*':" ~/.pub-cache/hosted/pub.dev/reicon_flutter-*/lib/src/icons.dart \
  | sed "s/^  '//;s/'://" | sort -u
```

Adlar camelCase: `info-square` → `infoSquare`.

---

## Kabuk: AppBar ve Navbar

`core/shell_page.dart` shell rotalarının ortak kabuğunu çizer.

**AppBar sekmeye göre değişir.** `_AppBarConfig` her sekme için başlık, action ikonları ve logo/avatar gösterimini tutar. Action'lar `AppBarActions` hap'ında toplanır ve sekme değişince ikon sayısına göre genişleyip daralır.

Şu an bağlı olan action'lar: **menü** (`AppIcons.widget` → `ClubMenuSheet`), **bildirim** (`AppIcons.bell` → `/notification`) ve **ayarlar** (`/settings`). Diğerleri — arama, QR, düzenle, shuffle, info — dokunulabilir ama **hiçbir şey yapmıyor**; sayfaları henüz yok. Bağlamak için `shell_page.dart`'taki `_onActionTap`'e ekle.

**Navbar** yüzen bir hap; seçili sekme ikonun yanında etiketini açar. Genişleme `Align.widthFactor` animasyonuyla yapılır — etiket genişliği metne bağlı olduğu için elle genişlik hesabı yapılmaz.

> `AppBarActions`'ı `leading` slotunda kullanacaksan `Center` ile sarmala ve `leadingWidth`'i `AppBarActions.widthFor(n)` ile hesapla. Slot sıkı yükseklik kısıtı verdiği için sarmalanmazsa hap dikeyde uzar; `leadingWidth` verilmezse kırpılır.

---

## Bilinmesi gereken durum

**Bağlanmayı bekleyenler:**

- `User.fromJson` ve `mergeWith` yazıldı ama **hiç çağrılmıyor**. Profil API'si (`profilePictureUrl`, `faculty`, `linkedin` ...) bağlandığında kullanılacak. Endpoint yolu henüz bilinmiyor. **Önemli:** API yanıtında rol bilgisi yok; `teams`/`teamsDisplay`/`isOrganizerFor` yalnızca JWT'deki `realmRoles`'a bağlı. Bu yüzden API nesnesi JWT'nin yerine geçemez, `mergeWith` ile üzerine uygulanır.
- Ana sayfadaki haberler (`NewsService`) ve bildirimler mock veridir.
- Profildeki hızlı eylemler (QR'ı Göster, Öğrenci Kartını Eşle, NFC'yi Aç) ve ayarlardaki Bildirimler / İzinler satırları no-op.
- `lib/features/qr/presentation/pages/qr_page.dart` **tamamen yorum içinde** ve hiçbir yerden import edilmiyor.

**Yakın geçmişte kaldırılanlar** — geri getirmeden önce sor: biletler (tickets) özelliği, duyuru carousel'i, ana sayfadaki kısayollar, Ekipler sayfası, ana sayfadaki karşılama metni. Hepsi git geçmişinde.

**Etkinlik filtresi:** `EventModel.active` bayrağının anlamı bilinmiyor; "yaklaşan etkinlik" filtresi bilinçli olarak **tarihe** göre kuruldu (`EventProvider.upcomingEvents`, bitiş tarihi baz alınır ki çok günlü etkinlikler devam ederken düşmesin). Arayüzde `active`, "başvuru açık mı" olarak yorumlanıyor: kartta "Yakında" rozeti, detayda durum satırı ve pasif Katıl butonu buna bağlı.

---

## Etkinlik detayı — bilmen gerekenler

Bu sayfa uygulamanın en çok parçası olan ekranı; dokunmadan önce oku.

**Açılış tek yerden yapılır:** `EventDetailPage.open(context, event)`. Hem Etkinlikler sekmesindeki `EventCard` hem ana sayfadaki `UpcomingEventTile` bunu çağırıyor. Route kök navigator'a push ediliyor (yoksa navbar'ın altında kalır) ve sayfa `FadeTransition` ile biniyor.

**Kapak görseli `Hero` ile uçuyor.** Etiket ve uçuş yolu `EventCoverHero` widget'ında; kapağı gösteren üç yer de onu kullanıyor, ayar tek yerden değişir. Uçuş yolu bilinçli olarak `RectTween` (düz) — Hero'nun varsayılan `MaterialRectArcTween`'i küçük bir satırdan tam genişlikte kapağa giderken görseli savuruyor.

> `OpenContainer` (container transform) burada **kullanılamaz**: kutuyu büyütür ama iki içeriği cross-fade eder, yani görsel yerinden hareket etmez. Hero ile birlikte de çalışmaz — ikisi de kaynak widget'ı gizleyip kendi katmanında çizer.

**Zemin rengi kapaktan geliyor.** `EventPaletteService` görselin baskın renklerini çıkarıp bellekte tutuyor; sayfa bunları dağınık radial lekeler hâlinde koyu bir tabana bindiriyor. Servisin iki kritik ayrıntısı var:

- Görsel `ResizeImage` ile ~120 pikselde çözülüyor. Verilmezse afiş tam çözünürlükte, üstelik kartın gösterdiği kopyadan **ayrı** olarak çözülür (farklı boyut isteyen her istek kendi önbellek anahtarını alır).
- Hesaplar sıraya dizili ve her biri `endOfFrame` sonrası başlıyor. Hepsi birden çalışınca sekme açılışında kareler düşüyordu.

Hesap, kart/satır göründüğü anda başlatılıyor (`initState`); sayfa açıldığında renk çoğu zaman hazır oluyor, değilse açılış animasyonu bittikten sonra tamamlanıyor.

**Kapak sayfada sabit duruyor:** `_pinnedCover` kaydırma ilerledikçe yüksekliği büzülen bir `Positioned`; üstteki başlık çubuğunda etkinlik adı ancak kapak yukarı kaybolunca beliriyor.

---

## Çalışma alışkanlıkları

- Her değişiklikten sonra `flutter analyze --no-pub` çalıştır ve temiz bırak.
- Sabit dosyalarına değer eklerken anlamlı isim ver; `AppRadiuses.stadium` gibi hazır çözümlere bak (yükseklik değişse de tam yuvarlak kalır).
- Bir şeyi silmeden önce commit'li olduğunu doğrula, silinenleri ve geri alma komutunu raporla.
- Kullanıcı ekran görüntüsü gönderdiğinde sorunu tahmin etme; kaynağını koddan çöz ve nedenini açıkla. Layout sorunlarının çoğu kısıt (constraint) kaynaklıdır — `Center`/`Expanded`/`stretch` eksikliği gibi.
- İş bitince özet ver ve dur. Commit atma.
