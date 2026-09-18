import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

const String _eventsPath = '/v1/events';

/// Dio'nun ağ katmanının yerine geçen taşıyıcı.
///
/// Provider, servis ve zarf ayrıştırması gerçek koduyla çalışsın diye
/// sahtelik en alt katmana konuyor; yalnızca istek ve yanıt kurgulanıyor.
class _FakeAdapter implements HttpClientAdapter {
  /// Yol başına verilecek yanıt. Üretici `throw` ederse istek hata alır.
  final Map<String, Future<ResponseBody> Function()> handlers = {};

  /// İstenen yollar, sırasıyla. Kaç istek atıldığını doğrulamak için.
  final List<String> requested = [];

  int countOf(String path) => requested.where((p) => p == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requested.add(options.path);
    final handler = handlers[options.path];
    if (handler == null) throw _networkError(options.path);
    return handler();
  }

  @override
  void close({bool force = false}) {}
}

DioException _networkError(String path) => DioException(
  requestOptions: RequestOptions(path: path),
  type: DioExceptionType.connectionError,
  error: 'ağ yok',
);

Map<String, dynamic> _eventJson(String id) => {
  'id': id,
  'name': 'Etkinlik $id',
  'coverImageUrl': '',
  'description': 'Açıklama',
  'location': 'D-B12',
  'startDate': '2030-01-01T10:00:00Z',
  'endDate': '2030-01-01T12:00:00Z',
  'formUrl': '',
  'active': true,
  'ownerTeam': 'MOBILAB',
};

ResponseBody _okBody(List<Map<String, dynamic>> events) =>
    ResponseBody.fromString(
      jsonEncode(events),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  late _FakeAdapter adapter;
  late EventProvider provider;

  setUp(() {
    adapter = _FakeAdapter();
    ApiClient.instance.dio.httpClientAdapter = adapter;
    adapter.handlers[_eventsPath] = () async =>
        _okBody([_eventJson('e1'), _eventJson('e2')]);
    provider = EventProvider();
  });

  group('ensureLoaded', () {
    test('bir kez yükler, ikinci çağrı istek atmaz', () async {
      await provider.ensureLoaded();

      expect(provider.events.length, 2);
      expect(provider.isInitialized, isTrue);
      expect(provider.error, isNull);
      expect(adapter.countOf(_eventsPath), 1);

      await provider.ensureLoaded();

      expect(adapter.countOf(_eventsPath), 1);
    });

    test('hata alsa da tamamlanmış sayılır ve hatayı taşır', () async {
      adapter.handlers[_eventsPath] = () async =>
          throw _networkError(_eventsPath);

      await provider.ensureLoaded();

      expect(provider.events, isEmpty);
      expect(provider.isInitialized, isTrue);
      expect(provider.error?.type, ApiErrorType.network);
      expect(provider.hasError, isTrue);

      // Tekrar denemenin yolu ensureLoaded değil: ekrandaki "Tekrar Dene"
      // ve aşağı çekme refresh() çağırıyor.
      await provider.ensureLoaded();
      expect(adapter.countOf(_eventsPath), 1);
    });
  });

  group('refresh', () {
    test('elde veri varken bile yeniden yükler', () async {
      await provider.ensureLoaded();
      adapter.handlers[_eventsPath] = () async =>
          _okBody([_eventJson('e1'), _eventJson('e2'), _eventJson('e3')]);

      await provider.refresh();

      expect(adapter.countOf(_eventsPath), 2);
      expect(provider.events.length, 3);
    });

    test('hata verirse eldeki liste korunur', () async {
      await provider.ensureLoaded();
      expect(provider.events.length, 2);

      adapter.handlers[_eventsPath] = () async =>
          throw _networkError(_eventsPath);

      await provider.refresh();

      // Asıl kural: ağ koptu diye ekrandaki etkinlikler kaybolmuyor.
      expect(provider.events.length, 2);
      expect(provider.error?.type, ApiErrorType.network);
    });

    test('başarılı yenileme önceki hatayı temizler', () async {
      adapter.handlers[_eventsPath] = () async =>
          throw _networkError(_eventsPath);
      await provider.ensureLoaded();
      expect(provider.hasError, isTrue);

      adapter.handlers[_eventsPath] = () async => _okBody([_eventJson('e1')]);
      await provider.refresh();

      expect(provider.hasError, isFalse);
      expect(provider.events.length, 1);
    });

    test('yükleme sürerken önceki hata yerinde kalır', () async {
      adapter.handlers[_eventsPath] = () async =>
          throw _networkError(_eventsPath);
      await provider.ensureLoaded();
      expect(provider.hasError, isTrue);

      final gate = Completer<void>();
      adapter.handlers[_eventsPath] = () async {
        await gate.future;
        return _okBody([_eventJson('e1')]);
      };

      final refreshing = provider.refresh();
      await Future<void>.delayed(Duration.zero);

      // İstek başında sıfırlansaydı hata ekranı bir anlığına boş duruma
      // dönüşürdü; kullanıcı yenileme boyunca aynı ekranı görmeli.
      expect(provider.isLoading, isTrue);
      expect(provider.hasError, isTrue);

      gate.complete();
      await refreshing;

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
    });
  });

  group('eşzamanlılık', () {
    test('aynı anda gelen çağrılar tek istek atar', () async {
      final gate = Completer<void>();
      adapter.handlers[_eventsPath] = () async {
        await gate.future;
        return _okBody([_eventJson('e1')]);
      };

      final first = provider.refresh();
      final second = provider.refresh();
      final third = provider.ensureLoaded();

      gate.complete();
      await Future.wait([first, second, third]);

      expect(adapter.countOf(_eventsPath), 1);
    });

    test('süren yükleme bitmeden future tamamlanmaz', () async {
      final gate = Completer<void>();
      adapter.handlers[_eventsPath] = () async {
        await gate.future;
        return _okBody([_eventJson('e1')]);
      };

      var firstDone = false;
      var secondDone = false;
      final first = provider.ensureLoaded().then((_) => firstDone = true);
      final second = provider.refresh().then((_) => secondDone = true);

      await Future<void>.delayed(Duration.zero);

      // Erken tamamlanan bir future, yenileme göstergesini veri gelmeden
      // kapatıyordu.
      expect(firstDone, isFalse);
      expect(secondDone, isFalse);

      gate.complete();
      await Future.wait([first, second]);

      expect(firstDone, isTrue);
      expect(secondDone, isTrue);
    });

    test('yükleme boyunca isLoading true kalır', () async {
      final gate = Completer<void>();
      adapter.handlers[_eventsPath] = () async {
        await gate.future;
        return _okBody([_eventJson('e1')]);
      };

      expect(provider.isLoading, isFalse);
      final loading = provider.ensureLoaded();
      await Future<void>.delayed(Duration.zero);
      expect(provider.isLoading, isTrue);

      gate.complete();
      await loading;
      expect(provider.isLoading, isFalse);
    });
  });

  group('örnek veri', () {
    test('boş yanıt debug derlemesinde örnek etkinliklere düşer', () async {
      // `flutter test` debug modda koşuyor; release'de bu liste boş kalır.
      adapter.handlers[_eventsPath] = () async => _okBody([]);

      await provider.ensureLoaded();

      expect(provider.error, isNull);
      expect(provider.events.length, EventService.mockEvents.length);
    });
  });
}
