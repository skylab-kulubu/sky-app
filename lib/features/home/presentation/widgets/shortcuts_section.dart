import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/icon_box.dart';

class ShortcutsSection extends StatelessWidget {
  final List<LinkItem> shortcuts;
  final VoidCallback onEditTap;

  const ShortcutsSection({
    super.key,
    required this.shortcuts,
    required this.onEditTap,
  });

  static const _wrapItemSize = 70.0;
  static const _runSpacing = 16.0;
  static const _spacing = 16.0;
  static const _iconSize = 52.0;
  static const _iconPadding = 14.0;
  static const _iconLabelGap = 6.0;
  static const _containerBorderRadius = 12.0;
  static const _buttonBorderRadius = 8.0;
  static const _buttonTopGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.mainPaddingAll,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(_containerBorderRadius),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: _spacing,
            runSpacing: _runSpacing,
            alignment: WrapAlignment.start,
            children: shortcuts.map((item) {
              return SizedBox(
                width: _wrapItemSize,
                child: GestureDetector(
                  onTap: () {
                    WebviewService.openLink(context, item);
                  },
                  child: Column(
                    children: [
                      IconBox(
                        size: _iconSize,
                        padding: _iconPadding,
                        icon: item.iconPath,
                        color: item.color,
                      ),

                      const SizedBox(height: _iconLabelGap),
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: _buttonTopGap),
          ElevatedButton(
            onPressed: onEditTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scaffoldBackgroundColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_buttonBorderRadius),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 12.0),
                Text('Kısayolları Düzenle'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
