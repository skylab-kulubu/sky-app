import 'dart:convert';

import 'package:dio/dio.dart';

/// Ağ katmanından dönen hataların uygulama içindeki karşılığı.
enum ApiErrorType {
  /// Sunucuya hiç ulaşılamadı: bağlantı yok, DNS çözülmedi, sertifika reddedildi.
  network,

  /// Sunucuya ulaşıldı ama zamanında yanıt gelmedi.
  timeout,

  /// Kimlik doğrulanamadı: token yok, süresi dolmuş ya da yenilenemedi.
  auth,

  /// İstenen kayıt bulunamadı.
  notFound,

  /// Sunucu tarafında hata (5xx).
  server,

  /// İstek iptal edildi.
  cancelled,

  /// Yukarıdakilerin hiçbiri.
  unknown,
}

/// [DioException]'ın sınıflandırılmış hâli.
///
/// Çağrı yerlerinin `DioExceptionType`'ı tek tek elemesi yerine tek bir
/// [type] alanına bakması için var. Asıl ihtiyaç oturum yönetiminde:
/// "yetkilendirme reddedildi" ile "internet yok" ayrımı, oturumun silinip
/// silinmeyeceğine karar veriyor.
class ApiException implements Exception {
  const ApiException(
    this.type, {
    this.statusCode,
    this.message,
    this.serverMessage,
    this.userText,
  });

  factory ApiException.fromDio(DioException error) {
    final int? statusCode = error.response?.statusCode;

    final ApiErrorType type = switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => ApiErrorType.network,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiErrorType.timeout,
      DioExceptionType.cancel => ApiErrorType.cancelled,
      DioExceptionType.badResponse => _fromStatusCode(statusCode),
      DioExceptionType.unknown => ApiErrorType.unknown,
    };

    return ApiException(
      type,
      statusCode: statusCode,
      message: error.message,
      serverMessage: _problemText(error.response?.data),
    );
  }

  /// Herhangi bir hatayı [ApiException]'a indirger.
  ///
  /// `_ErrorInterceptor` sınıflandırmayı `DioException.error` içine koyuyor;
  /// bu kurucu onu çıkarıyor, bulamazsa yeniden sınıflandırıyor.
  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final inner = error.error;
      return inner is ApiException ? inner : ApiException.fromDio(error);
    }
    return ApiException(ApiErrorType.unknown, message: error.toString());
  }

  final ApiErrorType type;
  final int? statusCode;
  final String? message;

  /// Sunucunun kendi açıklaması: core'un `application/problem+json`
  /// gövdesindeki `detail` (yoksa `title`). İngilizce ve teknik; kullanıcıya
  /// değil loglara. Kullanıcı metni [userMessage].
  final String? serverMessage;

  /// Duruma özel Türkçe açıklama; verilirse [userMessage] bunu döner.
  /// Sunucunun bir hata kodunu anlamlandırabildiğimiz yerlerde (medya
  /// yükleme gibi) kullanılıyor.
  final String? userText;

  /// Hata kullanıcının oturumundan değil bağlantıdan kaynaklanıyorsa true.
  /// Oturumun korunup korunmayacağına bu ayrım karar veriyor.
  bool get isConnectivityIssue =>
      type == ApiErrorType.network || type == ApiErrorType.timeout;

  /// Hata ekranlarında gösterilen açıklama.
  String get userMessage =>
      userText ??
      switch (type) {
        ApiErrorType.network => 'İnternet bağlantısı kurulamadı.',
        ApiErrorType.timeout => 'Sunucu zamanında yanıt vermedi.',
        ApiErrorType.auth => 'Oturumun doğrulanamadı.',
        ApiErrorType.notFound => 'Aradığın kayıt bulunamadı.',
        ApiErrorType.server => 'Sunucuda bir sorun oluştu.',
        ApiErrorType.cancelled => 'İstek iptal edildi.',
        ApiErrorType.unknown => 'Beklenmeyen bir hata oluştu.',
      };

  static ApiErrorType _fromStatusCode(int? statusCode) {
    if (statusCode == null) return ApiErrorType.unknown;
    if (statusCode == 401 || statusCode == 403) return ApiErrorType.auth;
    if (statusCode == 404) return ApiErrorType.notFound;
    if (statusCode >= 500) return ApiErrorType.server;
    return ApiErrorType.unknown;
  }

  /// problem+json gövdesinden açıklamayı çıkarır; başka biçimde `null`.
  static String? _problemText(Object? data) {
    Object? body = data;
    if (body is String && body.isNotEmpty) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        return null;
      }
    }
    if (body is! Map) return null;

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    final title = body['title'];
    return title is String && title.isNotEmpty ? title : null;
  }

  @override
  String toString() =>
      'ApiException($type'
      '${statusCode == null ? '' : ', $statusCode'}'
      '${serverMessage == null ? '' : ', $serverMessage'})';
}
