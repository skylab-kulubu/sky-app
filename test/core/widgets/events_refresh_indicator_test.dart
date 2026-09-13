import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/events_refresh_indicator.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

import '../../helpers/fake_event_provider.dart';

const ApiException _networkError = ApiException(ApiErrorType.network);

/// Göstergenin altına konan en sade kaydırılabilir içerik.
///
/// `AlwaysScrollableScrollPhysics` bilerek burada: içerik ekranı
/// doldurmadığı hâlde jestin başlaması bu physics'e bağlı.
Widget _scrollableChild({int itemCount = 1}) {
  return ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: itemCount,
    itemBuilder: (context, index) =>
        SizedBox(height: 80, child: Text('satır $index')),
  );
}

Future<void> _pumpIndicator(WidgetTester tester, FakeEventProvider fake) {
  return tester.pumpWidget(
    ChangeNotifierProvider<EventProvider>.value(
      value: fake,
      child: MaterialApp(
        home: Scaffold(body: EventsRefreshIndicator(child: _scrollableChild())),
      ),
    ),
  );
}

/// Aşağı çekme jesti: fırlat, göstergeyi aç, işi bitene kadar bekle.
Future<void> _pull(WidgetTester tester) async {
  await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// SnackBar'ın kendi zamanlayıcısını boşaltır; bekleyen zamanlayıcı testi
/// düşürüyor.
Future<void> _drainSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('aşağı çekmek yenilemeyi tetikler', (tester) async {
    final fake = FakeEventProvider(events: [fakeEvent()]);
    await _pumpIndicator(tester, fake);

    expect(fake.refreshCount, 0);
    await _pull(tester);

    expect(fake.refreshCount, 1);
  });

  testWidgets('içerik ekranı doldurmasa da jest çalışır', (tester) async {
    final fake = FakeEventProvider(events: [fakeEvent()]);
    await tester.pumpWidget(
      ChangeNotifierProvider<EventProvider>.value(
        value: fake,
        child: MaterialApp(
          home: Scaffold(
            // Tek satır: liste ekranın çok altında kalıyor.
            body: EventsRefreshIndicator(child: _scrollableChild()),
          ),
        ),
      ),
    );

    await _pull(tester);

    expect(fake.refreshCount, 1);
  });

  testWidgets('liste doluyken yenileme hatası SnackBar ile bildirilir', (
    tester,
  ) async {
    final fake = FakeEventProvider(events: [fakeEvent()])
      ..nextError = _networkError;
    await _pumpIndicator(tester, fake);

    await _pull(tester);

    // Liste ekranda kaldı; hatanın tek görünür yeri SnackBar.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(_networkError.userMessage), findsOneWidget);

    await _drainSnackBar(tester);
  });

  testWidgets('liste boşken SnackBar çıkmaz', (tester) async {
    // Elde gösterilecek bir şey yokken sayfanın kendi hata ekranı
    // görünüyor; üstüne bir de bildirim çıkmamalı.
    final fake = FakeEventProvider()..nextError = _networkError;
    await _pumpIndicator(tester, fake);

    await _pull(tester);

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('başarılı yenilemede SnackBar çıkmaz', (tester) async {
    final fake = FakeEventProvider(events: [fakeEvent()])
      ..nextEvents = [fakeEvent(id: 'e1'), fakeEvent(id: 'e2')];
    await _pumpIndicator(tester, fake);

    await _pull(tester);

    expect(find.byType(SnackBar), findsNothing);
    expect(fake.events.length, 2);
  });

  testWidgets('önceki hata başarılı yenilemede bildirilmez', (tester) async {
    // Hata ekranından çekiliyor ve istek bu kez başarılı: eski hatanın
    // SnackBar olarak geri gelmemesi gerekiyor.
    final fake = FakeEventProvider(error: _networkError)
      ..nextEvents = [fakeEvent()];
    await _pumpIndicator(tester, fake);

    await _pull(tester);

    expect(find.byType(SnackBar), findsNothing);
    expect(fake.error, isNull);
  });
}
