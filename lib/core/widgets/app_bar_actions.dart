import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// AppBar'ın actions bölümünde duran sarmalayıcı.
///
/// Sayfa değiştiğinde [icons] listesinin uzunluğuna göre genişleyip daralır.
///
/// ```dart
/// AppBarActions(icons: [AppIcons.menu, AppIcons.notification])
/// ```
class AppBarActions extends StatelessWidget {
  const AppBarActions({
    super.key,
    required this.icons,
    this.onIconTap,
    this.backgroundColor,
    this.iconColor,
  });

  /// Soldan sağa çizilecek [AppIcons] adları.
  final List<String> icons;

  /// Hap'ın zemini ve ikon rengi. Temadan bağımsız bir zeminin üstünde
  /// duran sayfalar (etkinlik detayı) kendi renklerini veriyor; verilmezse
  /// tema renkleri kullanılıyor.
  final Color? backgroundColor;
  final Color? iconColor;

  /// Şimdilik sayfalar hazır olmadığı için verilmiyor; verilmezse dokunma
  /// görsel olarak çalışır ama bir şey yapmaz.
  final void Function(String icon)? onIconTap;

  static const Duration _duration = Duration(milliseconds: 350);
  static const Curve _curve = Curves.easeOutCubic;
  static const double _buttonSize = 38;
  static const double _gap = AppSizes.smallSpace;
  static const double _inset = AppSizes.smallSpace;
  static const double _borderWidth = 1;

  /// Verilen ikon sayısı için kapsayıcının dış genişliği.
  ///
  /// `leading` slotunda kullanılırken [AppBar.leadingWidth] bu değerden
  /// türetilmeli; slot varsayılan genişliğinde kalırsa hap kırpılır.
  static double widthFor(int iconCount) {
    if (iconCount == 0) return 0;
    return iconCount * _buttonSize +
        (iconCount - 1) * _gap +
        (_inset + _borderWidth) * 2;
  }

  /// Kapsayıcının dış ölçüsü: içerik + iç boşluk + kenarlık.
  /// [_row] ile birebir aynı sabitlerden türediği için kayma olamaz.
  /// İkon yokken 0 — aksi halde boş bir hap görünürdü.
  double get _width => widthFor(icons.length);

  double get _height => _buttonSize + (_inset + _borderWidth) * 2;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      curve: _curve,
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.tileColor,
        borderRadius: AppRadiuses.stadiumBorderRadius,
        border: Border.all(
          color: backgroundColor != null
              ? Colors.transparent
              : context.dividerColor,
          width: _borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadiuses.stadiumBorderRadius,
        // Genişleme sırasında yeni ikon, kapsayıcı henüz dar iken eklenir.
        // OverflowBox taşma hatasını engelliyor; sağa hizalı olduğu için
        // sağdaki ikon yerinde kalıp yenisi soldan açılıyor.
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(_inset),
            child: _row(context),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < icons.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          _button(context, icons[i]),
        ],
      ],
    );
  }

  Widget _button(BuildContext context, String icon) {
    return SizedBox(
      width: _buttonSize,
      height: _buttonSize,
      child: IconButton(
        onPressed: () => onIconTap?.call(icon),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: _buttonSize,
          height: _buttonSize,
        ),
        // Tema varsayılanı `padded`; butonu 48x48 yerleştirip her iki yanına
        // görünmez dolgu ekliyor.
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: AppIcon(
          icon,
          size: AppSizes.iconMedium,
          color: iconColor ?? context.textPrimary,
        ),
      ),
    );
  }
}
