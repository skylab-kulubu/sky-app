import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/shell_page.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';
import 'package:sky_app/features/auth/presentation/pages/auth_page.dart';
import 'package:sky_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';
import 'package:sky_app/features/profile/presentation/pages/certificates/cert_page.dart';
import 'package:sky_app/features/profile/presentation/pages/contact/contact_page.dart';
import 'package:sky_app/features/profile/presentation/pages/profile_page.dart';
import 'package:sky_app/features/profile/presentation/pages/teams/teams_page.dart';
import 'package:sky_app/features/profile/presentation/pages/webview_page.dart';
import 'package:sky_app/features/team/presentation/pages/comming_soon_page.dart';
import 'package:sky_app/features/tickets/presentation/pages/tickets_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterManager {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) async {
      final AuthService authService = AuthService();
      final bool isLoggedIn = await authService.isLoggedIn();
      final bool isAuthRoute = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isAuthRoute) {
        return '/auth';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      return null;
    },
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
            path: '/tickets',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TicketsPage()),
          ),
          GoRoute(
            path: '/team',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CommingSoonPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
            routes: [
              GoRoute(
                path: 'teams',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TeamsPage(),
              ),
              GoRoute(
                path: 'certificates',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CertPage(),
              ),
              GoRoute(
                path: 'contact',
                builder: (context, state) => const ContactPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
