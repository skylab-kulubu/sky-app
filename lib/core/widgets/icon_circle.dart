import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Liste satırlarının solundaki dolu renkli ikon dairesi.
///
/// Ayarlar, sertifika ve aktivite satırlarında kullanılır; hepsi aynı dilde
/// okunsun diye tek yerde.
class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppSizes.settingsIconCircle,
  });

  /// [AppIcons] içindeki ikon adı.
  final String icon;

  final Color color;

  /// Dairenin çapı. Kart içindeki ayar satırlarında varsayılan; kartsız
  /// liste satırlarında (aktivite) daha büyük.
  final double size;

  /// Paletteki renkler koyu tema üzerinde fazla parlak kalıyor; dairenin
  /// zeminini bir tık koyultuyoruz. Doygunluğu korumak için siyaha karıştırmak
  /// yerine HSL parlaklığı düşürülüyor.
  static const double _darken = 0.8;

  /// İkon dairenin yarısı kadar. Ayarlar (18/36) ve bildirim (22/44)
  /// satırlarında oran zaten böyleydi; büyüyen daire ikonu da büyütüyor.
  static const double _iconRatio = 2;

  Color get _background {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * _darken).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _background, shape: BoxShape.circle),
      child: Center(
        child: AppIcon(
          icon,
          filled: true,
          size: size / _iconRatio,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}
