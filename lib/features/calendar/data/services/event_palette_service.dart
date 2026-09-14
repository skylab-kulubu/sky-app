import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';
import 'package:sky_app/core/widgets/cover_image.dart';

/// Etkinlik kapaklarından çıkarılan zemin renklerini hesaplar ve saklar.
///
/// Görsel çözme ana isolate'te kalır (platform gerektiriyor); pahalı olan
/// kuantizasyon [compute] ile arka plan isolate'ine taşınmıştır. Böylece
/// birçok kart aynı anda hesap istese de ana iş parçacığı bloklanmaz.
/// Sonuç etkinlik başına bir kez hesaplanıp bellekte tutuluyor; listedeki kart
/// göründüğü anda tetiklendiği için detay sayfası açıldığında renk çoğu zaman
/// hazır oluyor.
class EventPaletteService {
  EventPaletteService._();

  static final Map<String, List<Color>> _cache = {};

  /// Süren hesaplamalar. Aynı etkinlik için ikinci bir istek geldiğinde
  /// (kart yeniden göründü, sayfa açıldı) iş tekrarlanmıyor.
  static final Map<String, Future<List<Color>>> _pending = {};

  /// Görselin çözüleceği piksel genişliği.
  ///
  /// Kritik: bu verilmezse afiş tam çözünürlükte (çoğu zaman 2000 piksel)
  /// çözülüyor — üstelik kartın gösterdiği kopyadan ayrı bir çözüm olarak,
  /// çünkü farklı boyut isteyen her istek kendi önbellek anahtarını alıyor.
  /// Kuantizasyon zaten pikselleri örnekleyerek tarıyor, o yüzden bu kadarı yeter.
  static const int _decodeWidth = 120;

  /// Kaç renge indirgeneceği. Az tutuluyor: amaç görselin genel tonunu
  /// yakalamak, ayrıntısını değil.
  static const int _maxColors = 6;

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

    return _pending[eventId] ??= _extract(eventId, imageUrl);
  }

  static Future<List<Color>> _extract(String eventId, String imageUrl) async {
    final provider = CoverImage.providerFor(imageUrl);
    if (provider == null) return _store(eventId, const []);

    try {
      // Ana isolate: görsel çözme (ResizeImage ile küçük boyutta) ve ham
      // pikselleri alma. Bu adım platform (dart:ui) gerektirdiği için
      // arka plana taşınamaz.
      final image = await _decodeImage(
        ResizeImage(provider, width: _decodeWidth, allowUpscaling: false),
      );
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return _store(eventId, const []);

      final params = _QuantizeParams(
        pixels: byteData.buffer.asUint8List(),
        width: image.width,
        height: image.height,
        maxColors: _maxColors,
      );

      // Arka plan isolate: renk kuantizasyonu (saf Dart, ana iş parçacığını
      // bloklamaz).
      final tints = await compute(_quantize, params);
      return _store(eventId, tints);
    } catch (_) {
      return _store(eventId, const []);
    }
  }

  /// Bir [ImageProvider]'ı çözüp [ui.Image]'e ulaşır.
  static Future<ui.Image> _decodeImage(ImageProvider provider) {
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(info.image);
      },
      onError: (error, stackTrace) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    );

    stream.addListener(listener);
    return completer.future;
  }

  static List<Color> _store(String eventId, List<Color> tints) {
    _cache[eventId] = tints;
    _pending.remove(eventId);
    return tints;
  }
}

/// [compute]'a geçen kuantizasyon girdisi. Alanların tümü isolate sınırından
/// geçebilen tiplerdir.
class _QuantizeParams {
  const _QuantizeParams({
    required this.pixels,
    required this.width,
    required this.height,
    required this.maxColors,
  });

  final Uint8List pixels;
  final int width;
  final int height;
  final int maxColors;
}

/// Arka plan isolate'inde çalışan kuantizasyon. Ham RGBA piksellerden paleti
/// çıkarır; [PaletteGeneratorMaster.fromByteData] saf Dart olduğu için burada
/// güvenle koşar.
Future<List<Color>> _quantize(_QuantizeParams params) async {
  final palette = await PaletteGeneratorMaster.fromByteData(
    EncodedImageMaster(
      params.pixels.buffer.asByteData(),
      width: params.width,
      height: params.height,
      format: ui.ImageByteFormat.rawRgba,
    ),
    maximumColorCount: params.maxColors,
  );

  // Sıralama bilinçli: baskın renk görselin genel tonunu verir, canlı
  // ve soluk tonlar onun yanına çeşni katar.
  return <Color?>[
    palette.dominantColor?.color,
    palette.vibrantColor?.color,
    palette.mutedColor?.color,
    palette.darkVibrantColor?.color,
    palette.lightMutedColor?.color,
  ].whereType<Color>().toSet().toList();
}
