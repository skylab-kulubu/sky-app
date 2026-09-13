import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';

/// Görünüm tercihini seçtiren bottom sheet: Sistem / Açık / Koyu.
class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => const ThemeModeSheet(),
    );
  }

  /// Kullanıcıya gösterilecek etiket. Ayarlar satırındaki güncel değer de
  /// buradan okunuyor, böylece iki yer birbirinden ayrışmıyor.
  static String labelOf(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Sistem',
    ThemeMode.light => 'Açık',
    ThemeMode.dark => 'Koyu',
  };

  static String _iconOf(ThemeMode mode) => switch (mode) {
    ThemeMode.system => AppIcons.themeSystem,
    ThemeMode.light => AppIcons.themeLight,
    ThemeMode.dark => AppIcons.themeDark,
  };

  static Color _colorOf(ThemeMode mode) => switch (mode) {
    ThemeMode.system => AppColors.secondaryBlue,
    ThemeMode.light => AppColors.darkOrange,
    ThemeMode.dark => AppColors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ThemeProvider>().themeMode;

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _handle(context),
            Text(
              'Görünüm',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.bigSpace),
            // Ayarlar sayfasındaki satırların aynısı; seçili olanın sağında
            // ok yerine işaret var, diğerlerinde sağ taraf boş.
            TileGroup(
              children: [
                for (final mode in ThemeMode.values)
                  SettingsTile(
                    icon: _iconOf(mode),
                    iconColor: _colorOf(mode),
                    title: labelOf(mode),
                    trailingIcon: mode == selected ? AppIcons.check : null,
                    trailingIconColor: context.accentColor,
                    onTap: () {
                      context.read<ThemeProvider>().setThemeMode(mode);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _handle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSizes.bigSpace),
        decoration: BoxDecoration(
          color: context.dividerColor,
          borderRadius: AppRadiuses.stadiumBorderRadius,
        ),
      ),
    );
  }
}
