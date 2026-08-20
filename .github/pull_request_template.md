## Ne yapıldı?

<!-- Değişikliği bir iki cümleyle özetle. İlgili issue varsa: Closes #123 -->

## Nasıl test edildi?

<!-- Hangi cihaz/platformda, hangi ekranlarda denendi? -->

## Ekran görüntüsü / video

<!-- UI değişikliği varsa açık ve koyu tema için ayrı ayrı ekle. Yoksa bu bölümü sil. -->

## Kontrol listesi

CONTRIBUTING.md'deki kurallara göre:

- [ ] Klasör yapısı kurala uygun (`features/özellik_adı/data` ve `presentation`)
- [ ] Sayfa kalabalıklaştıysa Page ve PageModel `part`/`part of` ile ayrılmış
- [ ] Tekrar eden widget'lar `widgets/` klasörüne extract edilmiş
- [ ] Uzun UI blokları extract method olarak ayrılmış
- [ ] Zemin/metin/ayraç renkleri `context` erişimcilerinden alınmış; `AppColors` yalnızca marka renkleri için kullanılmış
- [ ] Hard-coded padding, radius, boyut ve asset yolu yok; `core/constants` kullanılıyor
- [ ] İkonlar `AppIcon` + `AppIcons` üzerinden; Material ikon kullanılmamış
- [ ] Değişiklik hem açık hem koyu temada kontrol edilmiş
- [ ] CI yeşil (format + analiz)
