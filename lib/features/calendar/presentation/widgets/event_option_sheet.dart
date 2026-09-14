import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/tile_group.dart';

/// Seçeneklerden birini seçtiren sheet (sahip ekip, sezon). Görünüm
/// sheet'iyle aynı düzen: başlık ve satırlar, seçilide tik. Seçilen sırayı
/// döner; vazgeçilirse `null`.
class EventOptionSheet extends StatelessWidget {
  const EventOptionSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final List<String> options;
  final int? selectedIndex;
  final String icon;
  final Color iconColor;

  static Future<int?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required int? selectedIndex,
    required String icon,
    required Color iconColor,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => EventOptionSheet(
        title: title,
        options: options,
        selectedIndex: selectedIndex,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  /// Seçenek çoksa (YK'nın ekip listesi) sheet ekranı taşmasın, içeride kaysın.
  static const double _maxHeightFactor = 0.7;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.bigSpace),
              Flexible(
                child: SingleChildScrollView(
                  child: TileGroup(
                    children: [
                      for (var i = 0; i < options.length; i++)
                        SettingsTile(
                          icon: icon,
                          iconColor: iconColor,
                          title: options[i],
                          trailingIcon: i == selectedIndex
                              ? AppIcons.check
                              : null,
                          trailingIconColor: context.accentColor,
                          onTap: () => Navigator.pop(context, i),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
