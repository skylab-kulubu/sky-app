import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/main_app.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';

void main() {
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
