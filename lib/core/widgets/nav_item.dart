import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Navbar öğesi: seçiliyken ikonun yanında label'lı bir hap, değilken yalnız
/// ikon. Label `Align.widthFactor` ile açıldığı için genişlik metinden
/// bağımsız, elle hesaplanmıyor.
///
/// [showLabel] kapalıyken seçili öğe de yalnız ikon (yanında menü butonu varken).
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.icon,
    this.showLabel = true,
  });

  /// [AppIcons] içindeki ikon adı. Seçiliyken Filled, değilken Outline çizilir.
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final bool showLabel;

  static const Duration _duration = Duration(milliseconds: 350);
  static const Curve _curve = Curves.easeOutCubic;

  /// Seçili hap'ın zemini: vurgu renginin çok soluk hâli.
  static const double _pillTint = 0.14;

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
      color: Color.lerp(
        Colors.transparent,
        context.accentColor.withValues(alpha: _pillTint),
        t,
      ),
      borderRadius: AppRadiuses.stadiumBorderRadius,
      child: InkWell(
        borderRadius: AppRadiuses.stadiumBorderRadius,
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Padding(
          padding: showLabel
              ? EdgeInsets.lerp(
                  AppPaddings.navItem,
                  AppPaddings.navItemSelected,
                  t,
                )!
              : AppPaddings.navItem,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                icon,
                filled: isSelected,
                size: AppSizes.icon,
                color: Color.lerp(
                  context.textSecondary,
                  context.accentColor,
                  t,
                ),
              ),
              if (showLabel) _label(context, t),
            ],
          ),
        ),
      ),
    );
  }

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
              color: context.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
