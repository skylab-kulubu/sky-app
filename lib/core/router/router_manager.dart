import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/pages/shell_page.dart';
import 'package:sky_app/features/auth/presentation/pages/auth_page.dart';
import 'package:sky_app/features/auth/presentation/pages/splash_page.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';
import 'package:sky_app/features/notification/presentation/pages/notification_page.dart';
import 'package:sky_app/features/profile/presentation/pages/certificates/certificates_page.dart';
import 'package:sky_app/features/profile/presentation/pages/profile_page.dart';
import 'package:sky_app/core/pages/webview_page.dart';
import 'package:sky_app/features/settings/presentation/pages/account/account_page.dart';
import 'package:sky_app/features/settings/presentation/pages/contact/contact_page.dart';
import 'package:sky_app/features/settings/presentation/pages/settings_page.dart';
import 'package:sky_app/features/team/presentation/pages/coming_soon_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterManager {
  final UserProvider userProvider;

  RouterManager(this.userProvider);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: userProvider,
    redirect: (context, state) => redirectLogic(userProvider, state),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),

      GoRoute(path: '/auth', builder: (context, state) => AuthPage()),
      GoRoute(
        path: '/notification',
        builder: (context, state) => NotificationPage(),
      ),

      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return WebviewPage(url: extra['url']!, title: extra['title']!);
        },
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'account',
            builder: (context, state) => const AccountPage(),
          ),
          GoRoute(
            path: 'contact',
            builder: (context, state) => const ContactPage(),
          ),
        ],
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
            path: '/team',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ComingSoonPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
            routes: [
              GoRoute(
                path: 'certificates',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CertificatesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static String? redirectLogic(UserProvider userProvider, GoRouterState state) {
    final bool isInitialized = userProvider.isInitialized;
    final bool isLoggedIn = userProvider.user != null;
    final bool isAuthRoute = state.matchedLocation == '/auth';
    final bool isSplashRoute = state.matchedLocation == '/';

    if (!isInitialized) return isSplashRoute ? null : '/';
    if (!isLoggedIn && !isAuthRoute) return '/auth';
    if (isLoggedIn && (isAuthRoute || isSplashRoute)) return '/home';

    return null;
  }
}
