import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/main_app.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/profile/presentation/providers/activity_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // ApiClient `core` altında ve oturumu bilmiyor; token kaynağı burada,
  // tek bağlama noktasında veriliyor.
  ApiClient.instance.attachTokenProvider(AuthService());

  timeago.setLocaleMessages('tr', timeago.TrMessages());
  // Bildirim satırlarındaki kısa zaman etiketi ("5dk", "2g").
  timeago.setLocaleMessages('tr_short', timeago.TrShortMessages());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MainApp(),
    ),
  );
}
