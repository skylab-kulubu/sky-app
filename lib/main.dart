import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/main_app.dart';
import 'package:sky_app/core/theme/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MainApp(),
    ),
  );
}
