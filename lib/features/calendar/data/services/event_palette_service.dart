import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sky_app/core/widgets/cover_image.dart';

/// Etkinlik kapaklarından çıkarılan zemin renklerini hesaplar ve saklar.
///
/// Çıkarım görseli çözüp piksel taradığı için ucuz değil ve ana iş
/// parçacığında çalışıyor. Bu yüzden sonuç etkinlik başına bir kez
/// hesaplanıp bellekte tutuluyor; listedeki kart göründüğü anda tetiklendiği
/// için detay sayfası açıldığında renk çoğu zaman hazır oluyor.
class EventPaletteService {
  EventPaletteService._();

  static final Map<String, List<Color>> _cache = {};

  /// Süren hesaplamalar. Aynı etkinlik için ikinci bir istek geldiğinde
  /// (kart yeniden göründü, sayfa açıldı) iş tekrarlanmıyor.
  static final Map<String, Future<List<Color>>> _pending = {};

  /// Palet için görselin küçültüldüğü boyut. Tam çözünürlükte taramak
  /// gereksiz pahalı, sonuç neredeyse aynı.
  static const Size _sampleSize = Size(80, 80);

  /// Görselin çözüleceği piksel genişliği.
  ///
  /// Kritik: bu verilmezse afiş tam çözünürlükte (çoğu zaman 2000 piksel)
  /// çözülüyor — üstelik kartın gösterdiği kopyadan ayrı bir çözüm olarak,
  /// çünkü farklı boyut isteyen her istek kendi önbellek anahtarını alıyor.
  /// Tarama zaten [_sampleSize]'a inecek, o yüzden ondan biraz büyüğü yeter.
  static const int _decodeWidth = 120;

  /// Kaç renge indirgeneceği. Az tutuluyor: amaç görselin genel tonunu
  /// yakalamak, ayrıntısını değil.
  static const int _maxColors = 6;

  /// Sıradaki işleri birbirine bağlayan zincir.
  ///
  /// Etkinlikler sekmesi açıldığında görünen bütün kartlar aynı anda hesap
  /// istiyor; hepsi birden çalışınca ilk kareler düşüyor. İşler sırayla ve
  /// kareler arasında çalıştırılıyor.
  static Future<void> _queue = Future<void>.value();

  /// Hesaplanmışsa renkleri döndürür, yoksa boş liste. Beklemek istemeyen
  /// çağıranlar için.
  static List<Color> cached(String eventId) => _cache[eventId] ?? const [];

  /// Renkleri hesaplar; daha önce hesaplandıysa doğrudan onu döndürür.
  ///
  /// Görsel indirilemez ya da çözülemezse boş liste döner — çağıran taraf
  /// düz zemine düşer.
  static Future<List<Color>> resolve({
    required String eventId,
    required String imageUrl,
  }) {
    final cached = _cache[eventId];
    if (cached != null) return Future.value(cached);

    return _pending[eventId] ??= _enqueue(() => _extract(eventId, imageUrl));
  }

  /// İşi kuyruğun sonuna ekler ve bir kare bitişini bekletir; böylece
  /// hesaplar kaydırma ve açılış animasyonlarının arasına dağılıyor.
  static Future<List<Color>> _enqueue(Future<List<Color>> Function() task) {
    final result = _queue.then((_) async {
      await SchedulerBinding.instance.endOfFrame;
      return task();
    });

    // Zincir hata yüzünden kopmasın: sıradaki iş yine de çalışmalı.
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  static Future<List<Color>> _extract(String eventId, String imageUrl) async {
    final provider = CoverImage.providerFor(imageUrl);
    if (provider == null) return _store(eventId, const []);

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(provider, width: _decodeWidth, allowUpscaling: false),
        size: _sampleSize,
        maximumColorCount: _maxColors,
      );

      // Sıralama bilinçli: baskın renk görselin genel tonunu verir, canlı
      // ve soluk tonlar onun yanına çeşni katar.
      final tints = <Color?>[
        palette.dominantColor?.color,
        palette.vibrantColor?.color,
        palette.mutedColor?.color,
        palette.darkVibrantColor?.color,
        palette.lightMutedColor?.color,
      ].whereType<Color>().toSet().toList();

      return _store(eventId, tints);
    } catch (_) {
      return _store(eventId, const []);
    }
  }

  static List<Color> _store(String eventId, List<Color> tints) {
    _cache[eventId] = tints;
    _pending.remove(eventId);
    return tints;
  }
}
