import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';
import 'package:sky_app/features/home/presentation/widgets/upcoming_event_tile.dart';

import '../../../../helpers/fake_event_provider.dart';

const ApiException _networkError = ApiException(ApiErrorType.network);

/// Ana sayfa oturum açmış kullanıcı istiyor; gerisi testlerin konusu değil.
class _FakeUserProvider extends UserProvider {
  @override
  User get user => User.fromJwt(const {});
}

Future<void> _pumpPage(WidgetTester tester, FakeEventProvider fake) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EventProvider>.value(value: fake),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => _FakeUserProvider(),
        ),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );
  await tester.pump();
}

Future<void> _pull(WidgetTester tester) async {
  await tester.fling(
    find.byType(SingleChildScrollView),
    const Offset(0, 300),
    1000,
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('aşağı çekmek yenilemeyi tetikler', (tester) async {
    final fake = FakeEventProvider(events: [fakeEvent()]);
    await _pumpPage(tester, fake);

    await _pull(tester);

    expect(fake.refreshCount, 1);
  });

  testWidgets('hiç etkinlik yokken hata satırı görünür', (tester) async {
    final fake = FakeEventProvider(error: _networkError);
    await _pumpPage(tester, fake);

    expect(find.text('Etkinlikler Yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);
  });

  testWidgets('elde etkinlik varken yenileme hatası bölümü karartmaz', (
    tester,
  ) async {
    final fake = FakeEventProvider(events: [fakeEvent()], error: _networkError);
    await _pumpPage(tester, fake);

    expect(find.text('Etkinlikler Yüklenemedi'), findsNothing);
    expect(find.byType(UpcomingEventTile), findsOneWidget);
  });

  testWidgets('istek sürerken Tekrar Dene yerini göstergeye bırakır', (
    tester,
  ) async {
    final fake = FakeEventProvider(error: _networkError, loading: true);
    await _pumpPage(tester, fake);

    expect(find.text('Tekrar Dene'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Hata satırı yerinde: yükleme boyunca ekran boş duruma dönüşmüyor.
    expect(find.text('Etkinlikler Yüklenemedi'), findsOneWidget);
  });
}
