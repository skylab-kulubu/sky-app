import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Uygulamanın birincil butonu.
///
/// Navbar ve appbar hap'larıyla aynı tam yuvarlak köşeye sahip. Basılınca
/// yay (spring) hissiyle küçülür ve bırakılınca yerine oturur; bu yüzden
/// [ElevatedButton] değil, [InkWell] üzerine kurulu (dokunmanın başlangıç ve
/// bitişi gerekiyor).
class SkyButton extends StatefulWidget {
  final String text;
  final Widget? icon;

  /// `null` ise buton pasif: soluk zeminde durur, dokunmaya yanıt vermez.
  final VoidCallback? onPressed;

  /// İstek sürerken metin yerine ilerleme göstergesi çizilir ve dokunma
  /// yok sayılır; aynı isteğin iki kez gönderilmesini engeller.
  final bool isLoading;

  final Color? backgroundColor;
  final Color? textColor;

  const SkyButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
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

  /// Basılıyken küçülme oranı.
  static const double _pressScale = 0.05;

  static const double _spinnerSize = 20;
  static const double _spinnerStroke = 2;

  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 520,
    damping: 32,
  );

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this);
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

  /// Dokunma işleniyor mu; pasif ve yükleniyor durumlarında hem basma
  /// animasyonu hem de geri çağrı devre dışı.
  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  /// Zemin üzerindeki metin ve ripple rengi. Vurgu zemini temaya göre açık
  /// lila ile koyu mor arasında yer değiştirdiği için kontrast rengi de
  /// temadan okunur.
  ///
  /// Açıkça verilen renk pasif durumda da geçerli: butonu temadan bağımsız
  /// bir zeminin üstüne koyan sayfalar (etkinlik detayı) iki durumu da
  /// kendisi belirliyor.
  Color _foreground(BuildContext context) {
    if (widget.textColor != null) return widget.textColor!;
    if (widget.onPressed == null) return context.textTertiary;
    return context.onAccentColor;
  }

  /// Pasif buton vurgu renginde durursa hâlâ basılabilir görünüyor; nötr
  /// yükseltilmiş yüzeye düşüyor.
  Color _background(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.onPressed == null) return context.elevatedColor;
    return context.accentColor;
  }

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
          color: _background(context),
          borderRadius: AppRadiuses.stadiumBorderRadius,
          // Ripple'ın köşelerden taşmaması için.
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTapDown: _isEnabled ? (_) => _animatePress(true) : null,
            onTapCancel: _isEnabled ? () => _animatePress(false) : null,
            onTapUp: _isEnabled ? (_) => _animatePress(false) : null,
            onTap: _isEnabled ? widget.onPressed : null,
            // Varsayılan ripple metin renginden türüyor; renkli zeminde
            // doğru tarafta kalması için açıkça veriliyor.
            splashColor: _foreground(context).withValues(alpha: 0.10),
            highlightColor: _foreground(context).withValues(alpha: 0.05),
            child: _content(context),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          height: _spinnerSize,
          width: _spinnerSize,
          // `.adaptive` değil: iOS'ta Cupertino göstergesine düşüyor ve
          // rengi buradan almıyor, butonun üstünde platformun varsayılan
          // grisi/siyahı kalıyordu. Material göstergesi metinle aynı rengi
          // alıyor.
          child: CircularProgressIndicator(
            strokeWidth: _spinnerStroke,
            color: _foreground(context),
          ),
        ),
      );
    }

    return Row(
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
    );
  }
}
