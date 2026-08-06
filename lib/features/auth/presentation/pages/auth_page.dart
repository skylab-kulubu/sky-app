import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/widgets/color_glow.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/auth/presentation/widgets/skylab_animation_logo.dart';

part 'auth_pagemodel.dart';

/// Giriş sayfası: ortada kendini çizen logo, altında kulübün adı, en altta
/// tek bir giriş butonu.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends AuthPagemodel {
  /// Zemindeki renk parıltılarının yerleşimi.
  ///
  /// Hepsi üst yarıda toplanıyor: parıltı logonun çevresinde yoğunlaşıp
  /// aşağı doğru sönüyor. Alt yarıya yayıldığında metin ve buton renkli bir
  /// bulutun üstünde kalıyor, sayfa dengesini kaybediyordu.
  static const List<GlowSpot> _glowSpots = [
    (center: Alignment(-0.95, -0.85), radius: 0.85, opacity: 0.30),
    (center: Alignment(0.9, -0.6), radius: 0.8, opacity: 0.26),
    (center: Alignment(0.0, -0.25), radius: 0.95, opacity: 0.22),
    (center: Alignment(0.85, 0.1), radius: 0.7, opacity: 0.16),
  ];

  /// Koyu temada parıltının kısıldığı oran.
  ///
  /// Aynı opaklık siyah zeminde renkleri hızla doyuruyor ve sayfa kirli bir
  /// renk bulutuna dönüyor; beyaz zeminde ise pastel bir yıkama olarak
  /// kalıyor.
  static const double _darkGlowScale = 0.35;

  double _glowIntensity(BuildContext context) =>
      context.theme.brightness == Brightness.dark ? _darkGlowScale : 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Parıltı içeriğin altında ve güvenli alanın dışında: ekranın
          // kenarlarına kadar uzanması gerekiyor.
          Positioned.fill(
            child: RepaintBoundary(
              child: ColorGlow(
                colors: AppColors.brandGradient,
                spots: _glowSpots,
                intensity: _glowIntensity(context),
              ),
            ),
          ),
          _glowFade(context),
          SafeArea(
            child: Padding(
              padding: AppPaddings.authContent,
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  _logo(context),
                  // Esnek boşluk logo ile metnin arasında: başlık bloğu
                  // butonun hemen üstünde duruyor, ikisi bir grup gibi
                  // okunuyor.
                  const Spacer(flex: 2),
                  _heading(context),
                  const SizedBox(height: AppSizes.sectionSpace),
                  _loginButton(context),
                  const SizedBox(height: AppSizes.sectionSpace),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parıltının alt yarıda tamamen sönmesini sağlayan örtü.
  ///
  /// Lekeler üst yarıda toplanmış olsa da kenarları aşağı sızıyor; bu örtü
  /// sayfanın alt bölgesini düz zemin rengine indiriyor, böylece başlık ve
  /// buton sakin bir zeminde duruyor.
  Widget _glowFade(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                context.backgroundColor.withValues(alpha: 0),
                context.backgroundColor,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kendini çizen logo. Zeminde dev bir doku olarak durmak yerine sayfanın
  /// odağı: ortada, sınırlı boyutta ve marka renginde.
  Widget _logo(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.authLogo,
      child: SkylabAnimationLogo(color: context.accentColor),
    );
  }

  /// İki satırlık başlık: üstte kulübün adı, altında ne olduğu. İkinci satır
  /// birincinin soluk bir alt yazısı değil, onunla aynı ağırlıkta ve marka
  /// renginde — cümleyi ikisi birlikte tamamlıyor.
  Widget _heading(BuildContext context) {
    return Column(
      children: [
        Text(
          'Sky Lab',
          textAlign: TextAlign.center,
          // Kulübün adı değil, altındaki renkli satır sayfanın vurgusu;
          // bu satır onun üstünde sakin bir künye gibi duruyor.
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.smallSpace),
        _gradientText(
          context,
          'Bilgisayar Bilimleri Kulübü',
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Metni gökkuşağı geçişiyle boyar.
  ///
  /// [ShaderMask] geçişi metnin kendi kutusuna göre kuruyor, yani satır
  /// sayısı değişse de renkler metne oturuyor. Verilen metin rengi shader
  /// tarafından eziliyor ama opak olmalı: maske metnin alfasını kullanıyor.
  Widget _gradientText(
    BuildContext context,
    String text, {
    required TextStyle? style,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: AppColors.brandGradient,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style?.copyWith(color: AppColors.onAccent),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return SkyButton(
      text: 'e-skylab ile Devam Et',
      isLoading: isLoading,
      onPressed: handleAuth,
    );
  }
}
