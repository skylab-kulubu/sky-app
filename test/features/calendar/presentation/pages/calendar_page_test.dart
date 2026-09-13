import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_card.dart';

import '../../../../helpers/fake_event_provider.dart';

const ApiException _networkError = ApiException(ApiErrorType.network);

Future<void> _pumpPage(WidgetTester tester, FakeEventProvider fake) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<EventProvider>.value(
      value: fake,
      child: const MaterialApp(home: CalendarPage()),
    ),
  );
  // initState'teki kare sonu geri çağrısı koşsun.
  await tester.pump();
}

/// Sayfanın hangi kaydırılabiliri çizdiği duruma göre değişiyor; jest her
/// ikisinde de aynı.
Future<void> _pull(WidgetTester tester, Finder scrollable) async {
  await tester.fling(scrollable, const Offset(0, 300), 1000);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ilk yükleme bitmeden ortada gösterge var', (tester) async {
    await _pumpPage(tester, FakeEventProvider(initialized: false));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Etkinlik Yok'), findsNothing);
  });

  testWidgets('liste boşken boş durum görünür ve aşağı çekilebilir', (
    tester,
  ) async {
    final fake = FakeEventProvider();
    await _pumpPage(tester, fake);

    expect(find.text('Etkinlik Yok'), findsOneWidget);

    // Asıl kural: mesaj ekranları da kaydırılabilir; düz bir `Center`
    // altında jest hiç başlamıyordu.
    await _pull(tester, find.byType(CustomScrollView));

    expect(fake.refreshCount, 1);
  });

  testWidgets('hata ekranı aşağı çekilebilir', (tester) async {
    final fake = FakeEventProvider(error: _networkError);
    await _pumpPage(tester, fake);

    expect(find.text('Etkinlikler Yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);

    await _pull(tester, find.byType(CustomScrollView));

    expect(fake.refreshCount, 1);
  });

  testWidgets('aramada sonuç yoksa sonuç yok mesajı görünür', (tester) async {
    final fake = FakeEventProvider(events: [fakeEvent()])..searchResults = [];
    await _pumpPage(tester, fake);

    expect(find.text('Sonuç Yok'), findsOneWidget);
    expect(find.byType(EventCard), findsNothing);
  });

  testWidgets('elde etkinlik varken hata sayfayı kaplamaz', (tester) async {
    // Yenileme ağ yüzünden düştü ama liste elde: kullanıcı listesini
    // kaybetmemeli, hatayı SnackBar görüyor.
    final fake = FakeEventProvider(events: [fakeEvent()], error: _networkError);
    await _pumpPage(tester, fake);

    expect(find.text('Etkinlikler Yüklenemedi'), findsNothing);
    expect(find.byType(EventCard), findsOneWidget);
  });

  testWidgets('liste görünürken aşağı çekmek yenilemeyi tetikler', (
    tester,
  ) async {
    final fake = FakeEventProvider(events: [fakeEvent()]);
    await _pumpPage(tester, fake);

    expect(find.byType(EventCard), findsOneWidget);

    await _pull(tester, find.byType(ListView));

    expect(fake.refreshCount, 1);
  });

  testWidgets('yenileme sonucu listeye yansır', (tester) async {
    // Kartlar uzun; ikisinin aynı anda çizilmesi için ekran daraltılıp
    // yükseltiliyor, yoksa ikinci kart hiç kurulmuyor. Çok yükseltmek de
    // olmuyor: RefreshIndicator'ın eşiği görüntü yüksekliğinin dörtte biri,
    // sabit uzunluktaki çekme jesti eşiğin altında kalıyor.
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fake = FakeEventProvider(events: [fakeEvent(id: 'e1')])
      ..nextEvents = [fakeEvent(id: 'e1'), fakeEvent(id: 'e2')];
    await _pumpPage(tester, fake);

    expect(find.byType(EventCard), findsOneWidget);

    await _pull(tester, find.byType(ListView));

    expect(find.byType(EventCard), findsNWidgets(2));
  });
}
