import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';
import 'package:sky_app/features/home/data/services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _service = NewsService();

  List<NewsItem> _news = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  ApiException? _error;
  Future<void>? _inFlight;

  List<NewsItem> get news => _news;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  NewsItem? itemBySlug(String slug) {
    for (final item in _news) {
      if (item.slug == slug) return item;
    }
    return null;
  }

  Future<void> ensureLoaded() async {
    if (_isInitialized) return;
    await _load();
  }

  Future<void> refresh() => _load();

  /// Oluşturulan ya da güncellenen haberi listeye yansıtır. Yeni haber başa
  /// ekleniyor: CMS oluşturma tarihi döndürmediği için sıralama yok, en son
  /// eklenenin en üstte görünmesi beklenen davranış.
  void upsert(NewsItem item) {
    final exists = _news.any((n) => n.slug == item.slug);
    _news = exists
        ? [for (final n in _news) n.slug == item.slug ? item : n]
        : [item, ..._news];
    notifyListeners();
  }

  Future<void> _load() => _inFlight ??= _run();

  Future<void> _run() async {
    _isLoading = true;
    notifyListeners();

    ApiException? error;
    try {
      _news = await _service.fetchNews();
    } on ApiException catch (e) {
      log('Haberler yüklenemedi: $e');
      error = e;
    } finally {
      _error = error;
      _isLoading = false;
      _isInitialized = true;
      _inFlight = null;
      notifyListeners();
    }
  }
}
