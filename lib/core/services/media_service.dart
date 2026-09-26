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
  Future<UploadedImage> uploadImage(XFile image, {String? purpose}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
      'purpose': ?purpose,
    });

    final Object? raw;
    try {
      raw = await CoreApi.post('/media', body: form);
    } on ApiException catch (error) {
      throw _describe(error);
    }

    final body = CoreApi.object(raw, what: 'yüklenen görsel');
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
  /// Türkçeleştirir; tanımadığımız kodlarda hata olduğu gibi kalıyor.
  static ApiException _describe(ApiException error) {
    final text = switch (error.statusCode) {
      413 => 'Görsel çok büyük. Daha küçük bir görsel seç.',
      415 => 'Bu dosya türü yüklenemiyor. JPEG, PNG, WebP ya da GIF dene.',
      429 => 'Çok fazla yükleme yaptın. Biraz bekleyip tekrar dene.',
      503 => 'Sunucu şu an yoğun. Birazdan tekrar dene.',
      _ => null,
    };
    if (text == null) return error;
    return ApiException(
      error.type,
      statusCode: error.statusCode,
      message: error.message,
      serverMessage: error.serverMessage,
      userText: text,
    );
  }

  /// Core mutlak adres dönüyor; göreli (`images/…`) gelirse CDN'e bağlanıyor.
  static String _absolute(String url) {
    if (url.startsWith('http')) return url;
    return '$_cdnBase${url.startsWith('/') ? url.substring(1) : url}';
  }
}
