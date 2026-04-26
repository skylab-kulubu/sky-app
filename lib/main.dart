import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/main_app.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

void main() {
  EventService.prefetch();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MainApp(),
    ),
  );
}
