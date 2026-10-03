import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';

/// Core'a yüklenmiş bir görsel: medya id'si ve CDN adresi.
class UploadedImage {
  const UploadedImage({required this.id, required this.url});

  final String id;
  final String url;
}

/// Görsel seçme ve core'a yükleme (`POST /v1/media`). Oturum açmış herkes
/// yükleyebiliyor; core görseli temizleyip CDN'e koyuyor (en fazla 10 MB).
/// Etkinlik kapağı medya id'siyle, haber görseli (CMS alanı URL) adresle
/// kullanılıyor.
class MediaService {
  /// Görsel kalitesi: afişler çoğu zaman çok büyük geliyor; bu sınırlarla
  /// yükleme hızlı, görünüm etkilenmiyor.
  static const double _maxSide = 2000;
  static const int _quality = 85;

  static const String _cdnBase = 'https://cdn.yildizskylab.com/';

  /// Galeriden görsel seçtirir; vazgeçilirse `null`. Galeri izni
  /// reddedildiğinde `PlatformException` fırlatıyor.
  static Future<XFile?> pickImage() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
  }

  /// Görseli yükler. Alan adı `file`.
  ///
  /// [purpose] core'un medya amacı (`config/media-purposes.json`): verilirse
  /// core görseli yeniden kodluyor, boyutlarını üretiyor ve kuralları o
  /// amaca göre uyguluyor. Amaçsız yüklenen görseller `legacy` sayılıyor.
  ///
  /// Sunucu hatalarında (5xx) en çok [_maxAttempts] kez, artan aralıklarla
  /// yeniden deneniyor; `media_busy`'de `Retry-After` kadar bekleniyor. 4xx
  /// yeniden denenmiyor: aynı istek aynı yanıtı alır.
  Future<UploadedImage> uploadImage(XFile image, {String? purpose}) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await _upload(image, purpose);
      } on ApiException catch (error) {
        final retryable = (error.statusCode ?? 0) >= 500;
        if (!retryable || attempt >= _maxAttempts) throw _describe(error);
        await Future<void>.delayed(_backoff(error, attempt));
      }
    }
  }

  static const int _maxAttempts = 3;

  /// `Retry-After` varsa o (çok uzunsa kırpılarak), yoksa 1 s, 2 s …
  static Duration _backoff(ApiException error, int attempt) {
    final wait = error.retryAfter ?? Duration(seconds: attempt);
    return wait > _maxBackoff ? _maxBackoff : wait;
  }

  static const Duration _maxBackoff = Duration(seconds: 10);

  Future<UploadedImage> _upload(XFile image, String? purpose) async {
    // Gövde her denemede yeniden kuruluyor: MultipartFile bir kez okunabiliyor.
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
      'purpose': ?purpose,
    });

    final body = CoreApi.object(
      await CoreApi.post('/media', body: form),
      what: 'yüklenen görsel',
    );
    final id = body['id'];
    final url = body['url'];
    if (id is! String || id.isEmpty || url is! String || url.isEmpty) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Yüklenen görselin kimliği dönmedi',
      );
    }
    return UploadedImage(id: id, url: _absolute(url));
  }

  /// Core'un medya hata kodlarını (`application/problem+json` `code`)
  /// Türkçeleştirir. Önce koda, kod yoksa durum koduna bakılıyor; sunucunun
  /// `detail`'i kullanıcıya gösterilmiyor. Uygulama hatası sayılan kodlar
  /// (`purpose_unknown`, `media_name_invalid` …) loglanıp genel mesajla
  /// geçiyor.
  static ApiException _describe(ApiException error) {
    final text = switch (error.code) {
      'media_type_not_allowed' =>
        'Bu dosya türü yüklenemiyor. JPEG, PNG, WebP ya da GIF seç.',
      'media_too_large' => _tooLarge(error.details['maxBytes']),
      'media_image_too_large' =>
        'Görselin çözünürlüğü çok yüksek. Daha küçük bir görsel seç.',
      'purpose_forbidden' => 'Bu görseli yükleme yetkin yok.',
      'media_rate_limited' => _rateLimited(error),
      'media_busy' => 'Sunucu şu an yoğun. Birazdan tekrar dene.',
      _ => switch (error.statusCode) {
        413 => 'Görsel çok büyük. Daha küçük bir görsel seç.',
        415 => 'Bu dosya türü yüklenemiyor. JPEG, PNG, WebP ya da GIF seç.',
        429 => 'Çok fazla yükleme yaptın. Biraz bekleyip tekrar dene.',
        503 => 'Sunucu şu an yoğun. Birazdan tekrar dene.',
        _ => null,
      },
    };
    if (error.code != null && text == null) {
      log('Medya yükleme hatası: $error');
    }
    if (text == null) return error;
    return ApiException(
      error.type,
      statusCode: error.statusCode,
      message: error.message,
      serverMessage: error.serverMessage,
      userText: text,
      code: error.code,
      retryAfter: error.retryAfter,
      details: error.details,
    );
  }

  static String _tooLarge(Object? maxBytes) {
    if (maxBytes is! num || maxBytes <= 0) {
      return 'Görsel çok büyük. Daha küçük bir görsel seç.';
    }
    final mb = (maxBytes / (1024 * 1024)).round();
    return 'Görsel çok büyük; en fazla $mb MB olabilir.';
  }

  /// Sınır iki türlü: kısa sürede çok yükleme (`uploads`) ya da günlük
  /// toplam boyut (`volume`). Bekleme süresi biliniyorsa söyleniyor.
  static String _rateLimited(ApiException error) {
    if (error.details['limit'] == 'volume') {
      return 'Günlük yükleme sınırına ulaştın. Yarın tekrar dene.';
    }
    final wait = error.retryAfter;
    if (wait == null || wait.inMinutes < 1) {
      return 'Çok fazla yükleme yaptın. Biraz bekleyip tekrar dene.';
    }
    return 'Çok fazla yükleme yaptın. ${wait.inMinutes} dakika sonra tekrar dene.';
  }

  /// Core mutlak adres dönüyor; göreli (`images/…`) gelirse CDN'e bağlanıyor.
  static String _absolute(String url) {
    if (url.startsWith('http')) return url;
    return '$_cdnBase${url.startsWith('/') ? url.substring(1) : url}';
  }
}
