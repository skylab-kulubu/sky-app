import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/main_app.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
<<<<<<< HEAD
import 'package:sky_app/features/calendar/data/services/event_service.dart';

void main() {
  EventService.prefetch();
=======
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  timeago.setLocaleMessages('tr', timeago.TrMessages());

>>>>>>> upstream/main
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
