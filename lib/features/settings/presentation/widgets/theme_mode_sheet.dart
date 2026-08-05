import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

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

  static String? _descriptionOf(ThemeMode mode) =>
      mode == ThemeMode.system ? 'Cihaz ayarını izler' : null;

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
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadiuses.tile),
              child: Container(
                color: context.tileColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final mode in ThemeMode.values) ...[
                      if (mode != ThemeMode.values.first) _divider(context),
                      _option(context, mode, mode == selected),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, ThemeMode mode, bool isSelected) {
    final description = _descriptionOf(mode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<ThemeProvider>().setThemeMode(mode);
          Navigator.pop(context);
        },
        child: Padding(
          padding: AppPaddings.settingsTile,
          child: Row(
            children: [
              AppIcon(
                _iconOf(mode),
                filled: isSelected,
                size: AppSizes.iconMedium,
                color: isSelected ? context.accentColor : context.textSecondary,
              ),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelOf(mode),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                AppIcon(
                  AppIcons.check,
                  size: AppSizes.iconMedium,
                  color: context.accentColor,
                ),
            ],
          ),
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

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    color: context.dividerColor,
    indent: 16,
    endIndent: 16,
  );
}
