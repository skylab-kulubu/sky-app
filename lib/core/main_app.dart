import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/router/router_manager.dart';
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
      theme: Provider.of<ThemeProvider>(context).themeData,
      routerConfig: _routerManager.router,
    );
  }
}
