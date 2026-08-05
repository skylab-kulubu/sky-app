import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/auth/presentation/widgets/skylab_animation_logo.dart';

part 'auth_pagemodel.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends AuthPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          clipBehavior: .hardEdge,
          children: [
            Positioned(
              right: -300,
              top: 0,
              bottom: 0,
              width: 800,
              child: SkylabAnimationLogo(),
            ),
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [_header(context), _loginButton()],
                    ),
                  ),
                ),
                _footer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 150),
        Text(
          'SKY LAB',
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Bilgisayar Bilimleri Kulübü',
          style: TextStyle(fontSize: 12, color: context.textSecondary),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _loginButton() {
    const buttonHeight = 68.0;
    final borderRadius = BorderRadius.circular(buttonHeight / 2);

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: AnimatedBuilder(
        animation: pressController,
        builder: (context, child) {
          final scale = 1 - (pressController.value * 0.05);

          return Transform.scale(scale: scale, child: child);
        },
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: context.elevatedColor.withValues(alpha: 0.45),
              child: InkWell(
                onTapDown: isLoading ? null : (_) => animatePress(true),
                onTapCancel: isLoading ? null : () => animatePress(false),
                onTapUp: isLoading ? null : (_) => animatePress(false),
                onTap: isLoading ? null : handleAuth,
                splashColor: context.textPrimary.withValues(alpha: 0.08),
                highlightColor: context.textPrimary.withValues(alpha: 0.04),
                child: SizedBox(
                  height: buttonHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.textPrimary,
                          ),
                        )
                      else
                        SvgPicture.asset(
                          AppAssets.skylab,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            context.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        'e-skylab ile Giriş Yap',
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.only(top: 36.0, bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Developed by ',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          SvgPicture.asset(
            AppAssets.mobilab,
            height: 22,
            colorFilter: ColorFilter.mode(
              context.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
