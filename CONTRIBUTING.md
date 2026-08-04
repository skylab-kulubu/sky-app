# Contributing Guide

Bu projeye katkıda bulunmadan önce lütfen aşağıdaki kuralları dikkatlice oku.

---

##  Klasör Yapısı

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   ├── app_paddings.dart
│   │   ├── app_radiuses.dart
│   │   └── app_sizes.dart
│   ├── extensions/
│   ├── models/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── widgets/
└── features/
    └── home/
        ├── data/
        │   ├── models/
        │   └── services/
        └── presentation/
            ├── pages/
            │   ├── home_page.dart
            │   └── home_pagemodel.dart
            ├── widgets/
            │   └── latest_news_section.dart
            └── providers/
```

Her yeni özellik `features/` altına kendi adıyla klasör açılarak eklenir. Klasör yapısı yukarıdaki şemaya uygun olmalıdır.

Birden fazla feature'ın ortak kullandığı widget, servis, model ve sabitler `core/` altında yaşar; yalnızca tek bir feature'ı ilgilendirenler o feature'ın kendi klasöründe kalır.

---

##  Page & PageModel Ayrımı (`part` / `part of`)

**Bu ayrım her sayfa için zorunlu değildir.** Sayfa büyüdükçe — özellikle `StatefulWidget` sayfalarda fonksiyon sayısı arttıkça — UI tarafı kalabalıklaşır ve okunması zorlaşır. Böyle durumlarda sayfa ikiye bölünür:

- `home_page.dart` → Sadece `build` ve UI extract method'ları.
- `home_pagemodel.dart` → `initState`, `dispose`, state alanları ve iş mantığı.

Sayfa küçükse ve neredeyse hiç mantık içermiyorsa (basit bir `StatelessWidget`, tek `build`'lik bir sayfa) tek dosyada bırakılır. Kural okunabilirlik içindir; dosya sayısını artırmak için değil.

**Ne zaman ayır:**

- Sayfada birden fazla event handler / iş mantığı fonksiyonu birikmişse
- `initState` / `dispose` ve controller yönetimi varsa
- `build` dışındaki mantık, UI kodunu okumayı zorlaştırıyorsa

**`home_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/home/presentation/widgets/latest_news_section.dart';

part 'home_pagemodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends HomePagemodel {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        _sectionHeader('Son Haberler'),
        const LatestNewsSection(),
      ],
    );
  }

  Widget _sectionHeader(String title) => Text(title);
}
```

**`home_pagemodel.dart`**
```dart
part of 'home_page.dart';

abstract class HomePagemodel extends State<HomePage> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
```

> ⚠️ PageModel sınıfı mutlaka `abstract` olmalıdır.

**İsimlendirme:** Dosya `<sayfa_adı>_pagemodel.dart`, sınıf `<SayfaAdı>Pagemodel` şeklinde yazılır.

---

##  Widget Extraction

Birden fazla yerde kullanılan ya da karmaşık hale gelen widget'lar `widgets/` klasörüne ayrı bir dosya olarak çıkarılır.

```dart
// features/home/presentation/widgets/news_thumbnail.dart

import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';

class NewsThumbnail extends StatelessWidget {
  const NewsThumbnail({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground, // core/constants kullanılmalı
        borderRadius: AppRadiuses.cardBorderRadius,
      ),
      child: Text(title),
    );
  }
}
```

Yalnızca tek bir feature'da kullanılan widget o feature'ın `presentation/widgets/` klasörüne; birden fazla feature'da kullanılanlar `core/widgets/` altına konur.

---

##  Extract Method Kullanımı

Aynı sayfa içinde tekrar eden ya da uzun UI blokları `build` metodundan ayrılarak private method olarak tanımlanır.

```dart
// ✅ Doğru
Widget _sectionHeader(String title) => Text(title);
PreferredSizeWidget _appBar() => AppBar(title: const Text('Profil'));

// ❌ Yanlış — her şeyi build içine yazmak
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Profil')),
    body: Column(
      children: [
        // onlarca satır iç içe widget
      ],
    ),
  );
}
```

---

##  Core Constants Kullanımı

Renk, padding, radius ve boyut değerleri **kesinlikle** hard-code yazılmaz. `core/constants/` altındaki ilgili sabit dosyası kullanılır.

```dart
// ❌ Yanlış
color: Colors.black
padding: EdgeInsets.all(16)
borderRadius: BorderRadius.circular(16)
size: 26
'assets/icons/email.svg'

// ✅ Doğru
color: AppColors.scaffoldBackgroundColor
padding: AppPaddings.mainPaddingAll
borderRadius: AppRadiuses.cardBorderRadius
size: AppSizes.icon
AppAssets.email
```

| Dosya | Sınıf | İçerik |
|---|---|---|
| `app_colors.dart` | `AppColors` | Renk sabitleri |
| `app_paddings.dart` | `AppPaddings` | `EdgeInsets` padding değerleri |
| `app_radiuses.dart` | `AppRadiuses` | Border radius değerleri (`double` ve `BorderRadius`) |
| `app_sizes.dart` | `AppSizes` | İkon boyutları ve boşluk (space) değerleri |
| `app_assets.dart` | `AppAssets` | Asset dosya yolları (svg, png) |

İhtiyaç duyduğun değer sabit dosyasında yoksa, hard-code yazmak yerine ilgili dosyaya anlamlı bir isimle yeni sabit ekle.

---

##  Özet Kontrol Listesi

PR açmadan önce aşağıdaki maddeleri kontrol et:

- [ ] Klasör yapısı kurala uygun (`features/özellik_adı/data` ve `presentation`)
- [ ] Sayfa kalabalıklaştıysa Page ve PageModel `part`/`part of` ile ayrılmış
- [ ] Tekrar eden widget'lar `widgets/` klasörüne extract edilmiş
- [ ] Uzun UI blokları extract method olarak ayrılmış
- [ ] Hard-coded renk, padding, radius, boyut ve asset yolu yok; `core/constants` kullanılıyor
