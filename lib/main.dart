import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/main_app.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  timeago.setLocaleMessages('tr', timeago.TrMessages());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MainApp(),
    ),
  );
}
