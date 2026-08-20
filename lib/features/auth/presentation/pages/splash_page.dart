import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/auth/presentation/widgets/skylab_loader.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  Future<void> _initApp() async {
    final userProvider = context.read<UserProvider>();
    final eventProvider = context.read<EventProvider>();

    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code']!;
        await userProvider.handleWebAuth(code);

        if (userProvider.user != null) {
          unawaited(eventProvider.ensureLoaded());
        }
        return;
      }
    }

    await userProvider.tryAutoLogin();

    if (userProvider.user != null) {
      unawaited(eventProvider.ensureLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SkylabLoader(size: 120)));
  }
}
