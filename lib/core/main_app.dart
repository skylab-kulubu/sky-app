import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/router/router_manager.dart';
import 'package:sky_app/core/theme/theme.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final RouterManager _routerManager;

  @override
  void initState() {
    super.initState();
    _routerManager = RouterManager(context.read<UserProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SkyApp',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: context.watch<ThemeProvider>().themeMode,
      routerConfig: _routerManager.router,
      // AppBar'ı olan sayfalarda durum çubuğu stilini appBarTheme veriyor;
      // splash ve auth gibi AppBar'sız sayfalar için varsayılan buradan.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: _statusBarStyle(Theme.of(context).brightness),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  SystemUiOverlayStyle _statusBarStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
}
