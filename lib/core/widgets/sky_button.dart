import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Uygulamanın birincil butonu.
///
/// Navbar ve appbar hap'larıyla aynı tam yuvarlak köşeye sahip. Basılınca
/// auth sayfasındaki giriş butonuyla aynı yay (spring) hissiyle küçülür ve
/// bırakılınca yerine oturur; bu yüzden [ElevatedButton] değil,
/// [InkWell] üzerine kurulu (dokunmanın başlangıç/bitişi gerekiyor).
class SkyButton extends StatefulWidget {
  final String text;
  final Widget? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SkyButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<SkyButton> createState() => _SkyButtonState();
}

class _SkyButtonState extends State<SkyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  static const double _height = 56;

  /// Basılıyken küçülme oranı; auth butonuyla aynı.
  static const double _pressScale = 0.05;

  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 520,
    damping: 32,
  );

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _animatePress(bool pressed) {
    _pressController.animateWith(
      SpringSimulation(_spring, _pressController.value, pressed ? 1.0 : 0.0, 0),
    );
  }

  /// Zemin üzerindeki metin ve ripple rengi. Vurgu zemini temaya göre açık
  /// lila ile koyu mor arasında yer değiştirdiği için kontrast rengi de
  /// temadan okunur.
  Color _foreground(BuildContext context) =>
      widget.textColor ?? context.onAccentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_pressController.value * _pressScale),
            child: child,
          );
        },
        child: Material(
          color: widget.backgroundColor ?? context.accentColor,
          borderRadius: AppRadiuses.stadiumBorderRadius,
          // Ripple'ın köşelerden taşmaması için.
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTapDown: (_) => _animatePress(true),
            onTapCancel: () => _animatePress(false),
            onTapUp: (_) => _animatePress(false),
            onTap: widget.onPressed,
            // Varsayılan ripple metin renginden türüyor; renkli zeminde
            // doğru tarafta kalması için açıkça veriliyor.
            splashColor: _foreground(context).withValues(alpha: 0.10),
            highlightColor: _foreground(context).withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: AppSizes.bigSpace),
                ],
                Text(
                  widget.text,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: _foreground(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
