# Contributing Guide

Bu projeye katkıda bulunmadan önce lütfen aşağıdaki kuralları dikkatlice oku.

---

##  Klasör Yapısı

```
lib/
├── main.dart
├── core/
│   └── constants/
│       ├── app_color.dart
│       ├── app_padding.dart
│       └── app_radius.dart
└── features/
    └── home/
        ├── data/
        │   └── (repository, model, service dosyaları)
        └── presentation/
            ├── pages/
            │   ├── home_page.dart
            │   └── home_pagemodel.dart
            ├── widgets/
            │   └── name_container.dart
            └── providers/
```

Her yeni özellik `features/` altına kendi adıyla klasör açılarak eklenir. Klasör yapısı yukarıdaki şemaya uygun olmalıdır.

---

##  Page & PageModel Ayrımı (`part` / `part of`)

Her sayfa iki ayrı dosyaya bölünür:

- `home_page.dart` → Sadece `build` ve extract method'ları içerir.
- `home_pagemodel.dart` → `initState`, `dispose` ve iş mantığını içerir.

**`home_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:atolye_deneme_skyapp/features/home/presentation/widgets/name_container.dart';

part 'home_pagemodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends HomePagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab(),
      bottomNavigationBar: navbar(),
      body: Column(
        children: [
          NameContainer(name: 'Meryem'),
          NameContainer(name: 'Büşra'),
        ],
      ),
    );
  }

  BottomNavigationBar navbar() => BottomNavigationBar(items: []);
  FloatingActionButton fab() => FloatingActionButton(onPressed: () {});
}
```

**`home_pagemodel.dart`**
```dart
part of 'home_page.dart';

abstract class HomePagemodel extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

> ⚠️ `HomePagemodel` sınıfı mutlaka `abstract` olmalıdır.

---

##  Widget Extraction

Birden fazla yerde kullanılan ya da karmaşık hale gelen widget'lar `widgets/` klasörüne ayrı bir dosya olarak çıkarılır.

```dart
// features/home/presentation/widgets/name_container.dart

import 'package:flutter/material.dart';

class NameContainer extends StatelessWidget {
  const NameContainer({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.primary, // core/constants kullanılmalı
      ),
      child: Text(name),
    );
  }
}
```

---

##  Extract Method Kullanımı

Aynı sayfa içinde tekrar eden ya da uzun UI blokları `build` metodundan ayrılarak private method olarak tanımlanır.

```dart
// ✅ Doğru
FloatingActionButton fab() => FloatingActionButton(onPressed: () {});
BottomNavigationBar navbar() => BottomNavigationBar(items: []);

// ❌ Yanlış — her şeyi build içine yazmak
@override
Widget build(BuildContext context) {
  return Scaffold(
    floatingActionButton: FloatingActionButton(onPressed: () {}),
    bottomNavigationBar: BottomNavigationBar(items: []),
    // ...
  );
}
```

---

##  Core Constants Kullanımı

Renk, padding ve radius değerleri **kesinlikle** hard-code yazılmaz. `core/constants/` altındaki ilgili sabit dosyası kullanılır.

```dart
// ❌ Yanlış
color: Colors.black
padding: EdgeInsets.all(16)
borderRadius: BorderRadius.circular(8)

// ✅ Doğru
color: AppColor.primary
padding: EdgeInsets.all(AppPadding.m)
borderRadius: BorderRadius.circular(AppRadius.m)
```

| Dosya | İçerik |
|---|---|
| `app_color.dart` | Renk sabitleri |
| `app_padding.dart` | Padding değerleri |
| `app_radius.dart` | Border radius değerleri |

---

##  Özet Kontrol Listesi

PR açmadan önce aşağıdaki maddeleri kontrol et:

- [ ] Klasör yapısı kurala uygun (`features/özellik_adı/data` ve `presentation`)
- [ ] Page ve PageModel `part`/`part of` ile ayrılmış
- [ ] Tekrar eden widget'lar `widgets/` klasörüne extract edilmiş
- [ ] Uzun UI blokları extract method olarak ayrılmış
- [ ] Hard-coded renk, padding ve radius değeri yok; `core/constants` kullanılıyor