import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  ApiException? _error;

  List<EventModel> get events => _events;

  /// Son yüklemenin hatası; başarılıysa null.
  ///
  /// Boş liste artık tek başına bir şey söylemiyor: "etkinlik yok" ile
  /// "yüklenemedi" ayrımını bu alan taşıyor.
  ///
  /// Yükleme sürerken önceki değerinde kalıyor: istek başında sıfırlansaydı
  /// yenileme boyunca hata ekranı bir anlığına boş duruma dönüşürdü.
  ApiException? get error => _error;
  bool get hasError => _error != null;

  /// Bitişi geçmemiş etkinlikler, en yakın tarihli önce.
  ///
  /// Filtre `active` bayrağına değil tarihe bakıyor; bayrağın anlamı
  /// (başvuruya açık mı, devam ediyor mu) net olmadığı için tarih daha
  /// öngörülebilir bir ölçüt.
  List<EventModel> get upcomingEvents {
    final upcoming = _events.where((event) => event.isUpcoming).toList();
    upcoming.sort((a, b) {
      final aStart = a.startDateTime;
      final bStart = b.startDateTime;
      if (aStart == null || bStart == null) return 0;
      return aStart.compareTo(bStart);
    });
    return upcoming;
  }

  String _searchQuery = '';

  /// Etkinlikler sekmesindeki arama kutusunun metni; boşsa arama yok.
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed == _searchQuery) return;
    _searchQuery = trimmed;
    notifyListeners();
  }

  /// Aramaya uyan etkinlikler; arama yoksa listenin tamamı.
  ///
  /// Ad, konum ve tür satırında aranıyor. Açıklama dışarıda: uzun metinde
  /// geçen tek bir kelime alakasız etkinlikleri de sonuca katıyordu.
  List<EventModel> get searchedEvents {
    if (_searchQuery.isEmpty) return _events;

    final needle = _normalize(_searchQuery);
    return _events
        .where(
          (event) => [
            event.name,
            event.location,
            event.ownerTeam,
          ].any((field) => _normalize(field).contains(needle)),
        )
        .toList();
  }

  /// Büyük/küçük harf ve i/ı farkını yok sayar.
  ///
  /// Dart'ın `toLowerCase`'i Türkçeyi bilmiyor: "İ" noktalı bir "i̇"ye, "I"
  /// ise "i"ye dönüşüyor. Klavyeden hangisinin yazılacağı da belli
  /// olmadığından hepsi tek harfe indiriliyor.
  static String _normalize(String value) => value
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .toLowerCase()
      .replaceAll('ı', 'i');

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Süren yükleme; aynı anda gelen çağrılar bunu paylaşır.
  Future<void>? _inFlight;

  /// Etkinlikler elde yoksa bir kez yükler, varsa hiçbir şey yapmaz.
  ///
  /// Sayfalar açılışta koşulsuz çağırabilsin diye idempotent: arka arkaya
  /// gelen çağrılar tek bir yüklemeye karşılık gelir. Veriyi hangi sayfanın
  /// tetiklediği önemsiz; ilk gelen yükler, sonrakiler hazır bulur.
  Future<void> ensureLoaded() async {
    if (_isInitialized) return;
    await _load();
  }

  /// Elde ne olursa olsun yeniden yükler; aşağı çekerek yenileme ve hata
  /// ekranındaki "tekrar dene".
  Future<void> refresh() => _load();

  /// Süren bir yükleme varsa yenisini başlatmaz, onunkini döndürür.
  ///
  /// Erken `return` yerine future paylaşılıyor: aşağı çekerek yenilemede
  /// çağıran isteğin bitmesini bekliyor, hemen tamamlanan boş bir future
  /// göstergeyi veri gelmeden kapatıyordu.
  Future<void> _load() => _inFlight ??= _run();

  Future<void> _run() async {
    _isLoading = true;
    notifyListeners();

    ApiException? error;

    try {
      _events = await _eventService.fetchEvents();
    } on ApiException catch (e) {
      log('Etkinlikler yüklenemedi: $e');
      // Eldeki liste korunuyor: aşağı çekerek yenilemede ağ koptu diye
      // ekrandaki etkinlikler kaybolmamalı. İlk yüklemede zaten boş.
      error = e;
    } catch (e) {
      // Beklenmeyen hata (ör. yanıt modele uymadı) de sayfayı yükleniyor
      // durumunda bırakmamalı; kullanıcı "Tekrar Dene" görebilsin.
      log('Etkinlikler işlenemedi: $e');
      error = const ApiException(
        ApiErrorType.server,
        message: 'Etkinlikler işlenemedi',
      );
    } finally {
      _error = error;
      _isLoading = false;
      _isInitialized = true;
      _inFlight = null;
      notifyListeners();
    }
  }

  Future<bool> joinEvent(String eventId) async {
    return await _eventService.joinEvent(eventId);
  }
}
