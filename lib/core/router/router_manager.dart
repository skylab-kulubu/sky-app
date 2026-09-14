import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/pages/content_link_page.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_detail/event_detail_page.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';
import 'package:sky_app/features/home/data/services/news_service.dart';
import 'package:sky_app/features/home/presentation/pages/news_detail/news_detail_page.dart';
import 'package:sky_app/features/home/presentation/providers/news_provider.dart';
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
import 'package:sky_app/features/team/presentation/pages/team_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterManager {
  final UserProvider userProvider;

  RouterManager(this.userProvider);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: userProvider,
    redirect: (context, state) => _redirect(state),
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
            // Paylaşılan haber bağlantısı (`/news/<slug>` buraya çevriliyor).
            // Ana sayfanın altında: geri dönünce ana sayfa açık kalıyor.
            routes: [
              GoRoute(
                path: 'news/:slug',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  return ContentLinkPage<NewsItem>(
                    notFoundTitle: 'Haber bulunamadı',
                    load: () async =>
                        context.read<NewsProvider>().itemBySlug(slug) ??
                        await NewsService().fetchNewsItem(slug),
                    builder: (item) => NewsDetailPage(item: item),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CalendarPage()),
            // Paylaşılan etkinlik bağlantısı (`/events/<id>` buraya çevriliyor).
            routes: [
              GoRoute(
                path: 'events/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ContentLinkPage<EventModel>(
                    notFoundTitle: 'Etkinlik bulunamadı',
                    load: () => EventService().fetchEvent(id),
                    builder: (event) => EventDetailPage(event: event),
                  );
                },
              ),
            ],
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

  /// Bağlantının hedefi; giriş ya da splash sürerken saklanıyor, oturum
  /// doğrulanınca oraya gidiliyor. Yoksa link soğuk açılışta `/home`'a
  /// düşüp kayboluyordu.
  String? _pendingLocation;

  /// Dışarıya paylaşılan kısa yollar ve uygulama içindeki karşılıkları.
  static final RegExp _newsLink = RegExp(r'^/news/([^/]+)/?$');
  static final RegExp _eventLink = RegExp(r'^/events/([^/]+)/?$');

  /// Hedefi saklanabilecek içerik yolları.
  static bool _isContentPath(String path) =>
      path.startsWith('/home/news/') || path.startsWith('/calendar/events/');

  String? _redirect(GoRouterState state) {
    final path = state.uri.path;

    // 1. Paylaşılan bağlantı → sekmenin altındaki iç içe rota.
    final news = _newsLink.firstMatch(path);
    if (news != null) return '/home/news/${news.group(1)}';
    final event = _eventLink.firstMatch(path);
    if (event != null) return '/calendar/events/${event.group(1)}';

    // 2. Oturum durumuna göre yönlendirme; içerik hedefi araya giriyorsa sakla.
    final target = redirectLogic(userProvider, state);
    if (target != null && _isContentPath(path)) {
      _pendingLocation = state.uri.toString();
    }

    // 3. Oturum doğrulandı: saklanan hedef varsa ana sayfa yerine oraya.
    if (target == '/home' && _pendingLocation != null) {
      final pending = _pendingLocation;
      _pendingLocation = null;
      return pending;
    }
    return target;
  }

  static String? redirectLogic(UserProvider userProvider, GoRouterState state) {
    final bool isAuthRoute = state.matchedLocation == '/auth';
    final bool isSplashRoute = state.matchedLocation == '/';

    switch (userProvider.status) {
      // Oturum kontrolü sürüyor ya da sunucuya ulaşılamıyor; ikisinde de
      // splash'te kalınıyor. Çevrimdışıyken `/auth`'a atmak, aslında geçerli
      // olabilecek oturumu kaybettirmek olurdu — splash tekrar denemeyi
      // sunuyor.
      case AuthStatus.loading:
      case AuthStatus.offline:
        return isSplashRoute ? null : '/';

      case AuthStatus.unauthenticated:
        return isAuthRoute ? null : '/auth';

      case AuthStatus.authenticated:
        return isAuthRoute || isSplashRoute ? '/home' : null;
    }
  }
}
