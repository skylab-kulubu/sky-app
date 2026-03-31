import 'package:go_router/go_router.dart';
import 'package:sky_app/features/auth/presentation/pages/login_page.dart';
import 'package:sky_app/features/auth/presentation/pages/register_page.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';

class RouterManager {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomePage()),
      GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    ],
  );
}