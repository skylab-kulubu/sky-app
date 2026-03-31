
import 'package:flutter/material.dart';
import 'package:sky_app/core/router/router_manager.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: RouterManager.router,
    );
  }
}

