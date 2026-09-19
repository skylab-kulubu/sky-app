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
  Future<UploadedImage> uploadImage(XFile image) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
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

  /// Core mutlak adres dönüyor; göreli (`images/…`) gelirse CDN'e bağlanıyor.
  static String _absolute(String url) {
    if (url.startsWith('http')) return url;
    return '$_cdnBase${url.startsWith('/') ? url.substring(1) : url}';
  }
}
