import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/router/router_manager.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';

class FakeUserProvider extends UserProvider {
  AuthStatus _fakeStatus = AuthStatus.loading;

  @override
  AuthStatus get status => _fakeStatus;

  void setStatus(AuthStatus value) {
    _fakeStatus = value;
    notifyListeners();
  }
}

class MockGoRouterState implements GoRouterState {
  @override
  final String matchedLocation;

  MockGoRouterState(this.matchedLocation);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RouterManager Redirect Logic', () {
    late FakeUserProvider provider;

    setUp(() {
      provider = FakeUserProvider();
    });

    test(
      'oturum kontrolü sürerken splash dışındaki her yol splash e döner',
      () {
        provider.setStatus(AuthStatus.loading);

        expect(
          RouterManager.redirectLogic(provider, MockGoRouterState('/home')),
          '/',
        );
        expect(
          RouterManager.redirectLogic(provider, MockGoRouterState('/')),
          isNull,
        );
      },
    );

    test('oturum yokken /auth a yönlendirir', () {
      provider.setStatus(AuthStatus.unauthenticated);

      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/home')),
        '/auth',
      );
      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/')),
        '/auth',
      );
      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/auth')),
        isNull,
      );
    });

    test('oturum varken / ve /auth adresleri /home a düşer', () {
      provider.setStatus(AuthStatus.authenticated);

      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/')),
        '/home',
      );
      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/auth')),
        '/home',
      );
      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/profile')),
        isNull,
      );
    });

    // İşin can alıcı noktası: çevrimdışıyken kullanıcı giriş ekranına
    // atılmamalı, kayıtlı oturumu duruyor.
    test('çevrimdışıyken /auth a atmaz, splash te tutar', () {
      provider.setStatus(AuthStatus.offline);

      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/')),
        isNull,
      );
      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/home')),
        '/',
      );
      expect(
        RouterManager.redirectLogic(provider, MockGoRouterState('/auth')),
        '/',
      );
    });
  });
}
