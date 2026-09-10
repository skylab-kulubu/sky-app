import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
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

  Future<void> _retry() async {
    final userProvider = context.read<UserProvider>();
    final eventProvider = context.read<EventProvider>();

    await userProvider.tryAutoLogin();

    if (userProvider.user != null) {
      unawaited(eventProvider.ensureLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline =
        context.watch<UserProvider>().status == AuthStatus.offline;

    return Scaffold(
      body: Center(
        child: isOffline ? _offline(context) : const SkylabLoader(size: 120),
      ),
    );
  }

  /// Sunucuya ulaşılamadığında gösterilir.
  ///
  /// Oturum silinmediği için tekrar denemek yeterli; kullanıcı yeniden giriş
  /// yapmak zorunda değil. Yine de kalıcı bir arızada ekranda kilitlenmesin
  /// diye giriş ekranına dönüş yolu bırakıldı.
  Widget _offline(BuildContext context) {
    return Padding(
      padding: AppPaddings.authContent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            AppIcons.wifiOff,
            size: AppSizes.iconLarge,
            color: context.textTertiary,
          ),
          const SizedBox(height: AppSizes.bigSpace),
          Text(
            'Bağlantı Kurulamadı',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.smallSpace),
          Text(
            'Sunucuya ulaşılamıyor. İnternet bağlantını kontrol edip tekrar dene.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textTertiary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSizes.largeSpace),
          SkyButton(text: 'Tekrar Dene', onPressed: _retry),
          TextButton(
            onPressed: () => context.read<UserProvider>().discardSession(),
            child: Text(
              'Giriş ekranına dön',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
