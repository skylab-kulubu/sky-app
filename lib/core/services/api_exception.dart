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
  const ApiException(this.type, {this.statusCode, this.message});

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

    return ApiException(type, statusCode: statusCode, message: error.message);
  }

  final ApiErrorType type;
  final int? statusCode;
  final String? message;

  /// Hata kullanıcının oturumundan değil bağlantıdan kaynaklanıyorsa true.
  /// Oturumun korunup korunmayacağına bu ayrım karar veriyor.
  bool get isConnectivityIssue =>
      type == ApiErrorType.network || type == ApiErrorType.timeout;

  static ApiErrorType _fromStatusCode(int? statusCode) {
    if (statusCode == null) return ApiErrorType.unknown;
    if (statusCode == 401 || statusCode == 403) return ApiErrorType.auth;
    if (statusCode == 404) return ApiErrorType.notFound;
    if (statusCode >= 500) return ApiErrorType.server;
    return ApiErrorType.unknown;
  }

  @override
  String toString() =>
      'ApiException($type${statusCode == null ? '' : ', $statusCode'})';
}
