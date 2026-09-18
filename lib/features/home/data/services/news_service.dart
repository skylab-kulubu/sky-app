import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';

/// SkyCMS `News` koleksiyonu.
///
/// Okuma girişsiz. Yazma için token'ın `skyapp` client'ında `cms:access`
/// rolü ve YK/DK/ADMIN grubu gerekiyor (`User.canManageNews`); bu
/// kullanıcılar bütün haberleri oluşturup düzenleyebiliyor. Silme
/// endpoint'i yok.
///
/// Koleksiyon adı büyük harfle (`News`); yanıtlar `{data: ...}` zarfında
/// değil.
class NewsService {
  final Dio _dio = ApiClient.instance.dio;

  static const String _path = '/api/cms/collections/News';
  static const int _pageLimit = 100;

  Future<List<NewsItem>> fetchNews() async {
    final body = await _request(
      () => _dio.get<dynamic>(_path, queryParameters: {'limit': _pageLimit}),
    );
    final items = body['items'];
    if (items is! List) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Yanıtta haber listesi yok',
      );
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(NewsItem.fromJson)
        .where((item) => item.slug.isNotEmpty && item.title.isNotEmpty)
        .toList(growable: false);
  }

  /// Tek haber, düzenleme için taze (sürüm numarası); token'lı istek CMS'te
  /// önbelleğe alınmıyor.
  Future<NewsItem> fetchNewsItem(String slug) async {
    return NewsItem.fromJson(
      await _request(() => _dio.get<dynamic>('$_path/$slug')),
    );
  }

  /// Yeni haber; slug'ı CMS başlıktan üretiyor.
  Future<NewsItem> createNews(NewsItem draft) async {
    return NewsItem.fromJson(
      await _request(
        () => _dio.post<dynamic>(_path, data: {'data': draft.toCmsData()}),
      ),
    );
  }

  Future<NewsItem> updateNews(NewsItem item) async {
    return NewsItem.fromJson(
      await _request(
        () => _dio.put<dynamic>(
          '$_path/${item.slug}',
          data: {'data': item.toCmsData(), 'version': item.version},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    final Response<dynamic> response;
    try {
      response = await send();
    } catch (e) {
      throw ApiException.from(e);
    }

    dynamic body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        throw const ApiException(
          ApiErrorType.server,
          message: 'Yanıt çözümlenemedi',
        );
      }
    }
    if (body is! Map<String, dynamic>) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Beklenmeyen yanıt gövdesi',
      );
    }
    return body;
  }
}
