import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_app/core/widgets/cover_image.dart';
import 'package:sky_app/features/calendar/data/services/cover_color_extractor.dart';

/// Etkinlik kapaklarından çıkarılan zemin renklerini hesaplar ve saklar.
///
/// **Anahtar kapak adresi, etkinlik değil.** Kapak değiştiğinde yeni medya
/// yeni bir CDN adresi alıyor; böylece eski görselin renkleri kendiliğinden
/// geçersiz kalıyor, ayrıca silme gerekmiyor.
///
/// Renk seçimi [CoverColorExtractor]'da (benzer tonları kümeleyip renkli
/// bölgeleri öne çıkarıyor); görsel [_sampleWidth] piksel genişliğe
/// küçültülerek çözülüyor. Hesap ana
/// iş parçacığında, ama aynı anda tek iş ve her biri bir kare bitişinden
/// sonra ([_queue]); liste açılırken kareler düşmüyor. Sonuçlar bellekte ve
/// diskte ([SharedPreferences]) tutuluyor: bir kapağın renkleri cihazda bir
/// kez hesaplanıyor, uygulama yeniden açıldığında tekrar çıkarılmıyor.
class EventPaletteService {
  EventPaletteService._();

  static final Map<String, List<Color>> _cache = {};

  /// Süren hesaplamalar; aynı kapak için gelen ikinci istek bunu bekliyor.
  static final Map<String, Future<List<Color>>> _pending = {};

  /// Görselin çözüleceği genişlik. Verilmezse afiş tam çözünürlükte
  /// (çoğu zaman 2000 piksel) çözülüyor; çok küçüğünde renkler soluyor.
  static const int _sampleWidth = 120;

  /// Zemin için seçilecek en fazla renk.
  static const int _maxColors = 5;

  /// Sıradaki hesapları birbirine bağlayan zincir; aynı anda tek iş.
  static Future<void> _queue = Future<void>.value();

  /// Görsel bu süre içinde çözülemezse vazgeçiliyor; yoksa [_pending]
  /// kaydı sonsuza dek asılı kalırdı.
  static const Duration _decodeTimeout = Duration(seconds: 15);

  static const String _prefsKey = 'event_palette_cache_v4';

  /// Diskte tutulacak en fazla kapak; eskiler (ilk eklenenler) atılıyor.
  static const int _diskLimit = 150;

  static Future<void>? _diskLoad;

  /// Hesaplanmışsa renkleri döndürür, yoksa boş liste. Beklemek istemeyen
  /// çağıranlar için (sayfa ilk karede doğru renkle açılsın diye).
  ///
  /// [known] sunucunun gönderdiği renkler (`EventModel.coverColors`); varsa
  /// hesap yapılmadan onlar kullanılıyor.
  static List<Color> cached(String imageUrl, {List<Color> known = const []}) =>
      known.isNotEmpty ? known : _cache[imageUrl] ?? const [];

  /// Renkleri döndürür; bellekte ya da diskte yoksa hesaplar.
  ///
  /// Görsel indirilemez ya da çözülemezse boş liste döner — çağıran taraf
  /// düz zemine düşer.
  static Future<List<Color>> resolve(
    String imageUrl, {
    List<Color> known = const [],
  }) {
    if (known.isNotEmpty) return Future.value(known);
    if (imageUrl.trim().isEmpty) return Future.value(const []);

    final cached = _cache[imageUrl];
    if (cached != null) return Future.value(cached);

    return _pending[imageUrl] ??= _resolve(imageUrl);
  }

  static Future<List<Color>> _resolve(String imageUrl) async {
    try {
      await (_diskLoad ??= _loadDisk());
      final fromDisk = _cache[imageUrl];
      if (fromDisk != null) return fromDisk;

      final colors = await _enqueue(() => _extract(imageUrl));
      _cache[imageUrl] = colors;
      // Boş sonuç (indirilemedi) diske yazılmıyor; sonraki açılışta tekrar
      // denensin.
      if (colors.isNotEmpty) unawaited(_saveDisk());
      return colors;
    } catch (e) {
      log('Kapak renkleri çıkarılamadı: $e');
      return const [];
    } finally {
      unawaited(_pending.remove(imageUrl));
    }
  }

  /// İşi kuyruğun sonuna ekler ve bir kare bitişini bekletir; hesaplar
  /// kaydırma ve açılış animasyonlarının arasına dağılıyor.
  static Future<T> _enqueue<T>(Future<T> Function() task) {
    final result = _queue.then((_) async {
      await SchedulerBinding.instance.endOfFrame;
      return task();
    });
    // Zincir hata yüzünden kopmasın: sıradaki iş yine de çalışmalı.
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  static Future<List<Color>> _extract(String imageUrl) async {
    final provider = CoverImage.providerFor(imageUrl);
    if (provider == null) return const [];

    final image = await _decodeImage(
      ResizeImage(provider, width: _sampleWidth, allowUpscaling: false),
    );
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bytes == null) return const [];
      return CoverColorExtractor.extract(bytes, maxColors: _maxColors);
    } finally {
      image.dispose();
    }
  }

  /// Bir [ImageProvider]'ı çözüp [ui.Image]'e ulaşır.
  static Future<ui.Image> _decodeImage(ImageProvider provider) {
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    late ImageStreamListener listener;
    late Timer timer;

    void finish() {
      timer.cancel();
      stream.removeListener(listener);
    }

    listener = ImageStreamListener(
      (info, _) {
        finish();
        if (completer.isCompleted) return;
        // Önbellekteki görsel paylaşılıyor; kendi kopyamızı alıp sonra
        // bırakıyoruz.
        completer.complete(info.image.clone());
        info.dispose();
      },
      onError: (error, stackTrace) {
        finish();
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    );

    timer = Timer(_decodeTimeout, () {
      stream.removeListener(listener);
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('Kapak çözülemedi', _decodeTimeout),
        );
      }
    });

    stream.addListener(listener);
    return completer.future;
  }

  /// Diskteki renkleri belleğe alır. Okunamazsa (test ortamı, bozuk kayıt)
  /// sessizce boş başlıyor; renkler yeniden hesaplanır.
  static Future<void> _loadDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      decoded.forEach((url, value) {
        if (value is! List) return;
        _cache.putIfAbsent(
          url,
          () => [for (final argb in value.whereType<int>()) Color(argb)],
        );
      });
    } catch (e) {
      log('Kapak renk önbelleği okunamadı: $e');
    }
  }

  static Future<void> _saveDisk() async {
    try {
      final entries = _cache.entries.where((e) => e.value.isNotEmpty).toList();
      final kept = entries.length > _diskLimit
          ? entries.sublist(entries.length - _diskLimit)
          : entries;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          for (final e in kept) e.key: [for (final c in e.value) c.toARGB32()],
        }),
      );
    } catch (e) {
      log('Kapak renk önbelleği yazılamadı: $e');
    }
  }
}
