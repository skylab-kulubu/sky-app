import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/router/router_manager.dart';
import 'package:sky_app/core/theme/theme_provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SkyApp',
      theme: Provider.of<ThemeProvider>(context).themeData,
      routerConfig: RouterManager.router,
    );
  }
}
