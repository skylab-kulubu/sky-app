import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/router/router_manager.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/auth/data/models/user.dart';

class FakeUserProvider extends UserProvider {
  bool _fakeIsInitialized = false;
  User? _fakeUser;

  @override
  bool get isInitialized => _fakeIsInitialized;

  @override
  User? get user => _fakeUser;

  void setInitialized(bool value) {
    _fakeIsInitialized = value;
    notifyListeners();
  }

  void setUser(User? value) {
    _fakeUser = value;
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

    test('redirects to / when not initialized (except when already on /)', () {
      provider.setInitialized(false);
      
      // Not on splash -> redirects to splash
      var state = MockGoRouterState('/home');
      expect(RouterManager.redirectLogic(provider, state), '/');

      // Already on splash -> no redirect
      state = MockGoRouterState('/');
      expect(RouterManager.redirectLogic(provider, state), isNull);
    });

    test('redirects to /auth when initialized but not logged in', () {
      provider.setInitialized(true);
      provider.setUser(null);
      
      // Accessing a protected route
      var state = MockGoRouterState('/home');
      expect(RouterManager.redirectLogic(provider, state), '/auth');

      // Accessing splash route
      state = MockGoRouterState('/');
      expect(RouterManager.redirectLogic(provider, state), '/auth');

      // Accessing auth route -> no redirect
      state = MockGoRouterState('/auth');
      expect(RouterManager.redirectLogic(provider, state), isNull);
    });

    test('redirects to /home when logged in and trying to access / or /auth', () {
      provider.setInitialized(true);
      provider.setUser(const User(
        id: '1',
        name: 'User',
        givenName: '',
        familyName: '',
        email: '',
        preferredUsername: '',
        university: '',
        department: '',
        skyNumber: '',
        emailVerified: true,
        realmRoles: [],
      ));
      
      // Accessing splash route
      var state = MockGoRouterState('/');
      expect(RouterManager.redirectLogic(provider, state), '/home');

      // Accessing auth route
      state = MockGoRouterState('/auth');
      expect(RouterManager.redirectLogic(provider, state), '/home');

      // Accessing a protected route -> no redirect
      state = MockGoRouterState('/profile');
      expect(RouterManager.redirectLogic(provider, state), isNull);
    });
  });
}
