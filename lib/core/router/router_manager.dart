import 'package:go_router/go_router.dart';
import 'package:sky_app/core/shell_page.dart';
import 'package:sky_app/features/auth/presentation/pages/auth_page.dart';
import 'package:sky_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';
import 'package:sky_app/features/profile/presentation/pages/profile_page.dart';
import 'package:sky_app/features/profile/presentation/pages/webview_page.dart';
import 'package:sky_app/features/qr/presentation/pages/qr_page.dart';
import 'package:sky_app/features/team/presentation/pages/team_page.dart';

class RouterManager {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => AuthPage()),

      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return WebviewPage(url: extra['url']!, title: extra['title']!);
        },
      ),

      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CalendarPage()),
          ),
          GoRoute(
            path: '/qr',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QrPage()),
          ),
          GoRoute(
            path: '/team',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TeamPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
    ],
  );
}
