import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reicon_flutter/reicon_flutter.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_sizes.dart';

/// Reicon ikonlarını Material'ın [Icon] widget'ı gibi kullanmayı sağlar.
///
/// Reicon ikonları `IconData` değil ham SVG path verisi olarak gelir; bu widget
/// çözme ve renklendirme işini tek yerde toplar.
///
/// ```dart
/// AppIcon(AppIcons.home)
/// AppIcon(AppIcons.home, filled: true, color: AppColors.primaryColor)
/// ```
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = AppSizes.icon,
    this.color,
    this.filled = false,
  });

  /// [AppIcons] içindeki ikon adı.
  final String name;

  final double size;

  /// Verilmezse önce [IconTheme], o da yoksa [AppColors.textWhite] kullanılır.
  final Color? color;

  /// `true` ise Filled, değilse Outline ağırlığı kullanılır.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final pathData = (filled ? Reicon.filled : Reicon.outline)[name];

    // Ad pakette yoksa layout'u bozmamak için ikon boyutunda boşluk bırakılır.
    if (pathData == null) {
      return SizedBox(width: size, height: size);
    }

    final resolvedColor =
        color ?? IconTheme.of(context).color ?? AppColors.textWhite;

    return SvgPicture.string(
      reiconSvg(pathData, size: size.round()),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}
