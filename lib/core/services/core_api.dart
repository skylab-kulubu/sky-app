import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';

/// Kulübün ana API'si (core-backend) için ortak istek katmanı.
///
/// Core `/v1` altında ve yanıtları sarmalamıyor: gövde doğrudan kaynağın
/// kendisi (nesne ya da dizi). Oluşturma 201, silme 204 (gövdesiz) dönüyor;
/// hatalar `application/problem+json` ve [ApiException]'a çevriliyor.
///
/// CMS (`/api/cms/...`) buradan geçmiyor; o ayrı bir servis ve yolu
/// değişmedi. Token ve 401 yenilemesi [ApiClient]'ta.
class CoreApi {
  CoreApi._();

  static const String prefix = '/v1';

  static Dio get _dio => ApiClient.instance.dio;

  static Future<Object?> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>('$prefix$path', queryParameters: query));

  static Future<Object?> post(String path, {Object? body}) =>
      _send(() => _dio.post<dynamic>('$prefix$path', data: body));

  static Future<Object?> put(String path, {Object? body}) =>
      _send(() => _dio.put<dynamic>('$prefix$path', data: body));

  static Future<Object?> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>('$prefix$path', data: body));

  static Future<void> delete(String path) =>
      _send(() => _dio.delete<dynamic>('$prefix$path'));

  /// Gövdenin nesne olmasını bekler; değilse sunucu hatası sayılır.
  static Map<String, dynamic> object(Object? body, {required String what}) {
    if (body is Map<String, dynamic>) return body;
    throw ApiException(ApiErrorType.server, message: 'Yanıtta $what yok');
  }

  /// Gövdenin dizi olmasını bekler ve nesne elemanlarını döner.
  static List<Map<String, dynamic>> list(Object? body, {required String what}) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    throw ApiException(ApiErrorType.server, message: 'Yanıtta $what yok');
  }

  /// İsteği atar, hatayı [ApiException]'a çevirir ve gövdeyi çözer.
  /// Gövdesiz yanıtta (204) `null` döner.
  static Future<Object?> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    final Response<dynamic> response;
    try {
      response = await request();
    } catch (e) {
      throw ApiException.from(e);
    }

    final body = response.data;
    if (body is! String) return body;
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (_) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Yanıt çözümlenemedi',
      );
    }
  }
}
