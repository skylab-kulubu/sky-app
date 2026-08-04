import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Navbar öğesi.
///
/// Seçiliyken ikonun yanında label'ı da gösteren bir hap'a dönüşür; seçili
/// değilken yalnızca ikon kalır. Geçiş, label'ın yatayda açılıp kapanmasıyla
/// olur — genişlik elle hesaplanmadığı için metin uzunluğundan bağımsızdır.
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.icon,
  });

  /// [AppIcons] içindeki ikon adı. Seçiliyken Filled, değilken Outline çizilir.
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  static const Duration _duration = Duration(milliseconds: 350);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
      duration: _duration,
      curve: _curve,
      builder: (context, t, _) => _pill(context, t),
    );
  }

  Widget _pill(BuildContext context, double t) {
    return Material(
      color: Color.lerp(Colors.transparent, AppColors.navIndicator, t),
      borderRadius: AppRadiuses.stadiumBorderRadius,
      child: InkWell(
        borderRadius: AppRadiuses.stadiumBorderRadius,
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.lerp(
            AppPaddings.navItem,
            AppPaddings.navItemSelected,
            t,
          )!,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                icon,
                filled: isSelected,
                size: AppSizes.icon,
                color: Color.lerp(
                  AppColors.navTextTertiary,
                  AppColors.primaryColor,
                  t,
                ),
              ),
              _label(context, t),
            ],
          ),
        ),
      ),
    );
  }

  /// [Align.widthFactor] 0'dan 1'e giderken label yatayda açılır. Boyut her
  /// karede değiştiği için geçiş, tek karelik sıçrama yerine akıcı olur.
  Widget _label(BuildContext context, double t) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: t,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSizes.midSpace),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
