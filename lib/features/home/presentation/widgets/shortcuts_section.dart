import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/home/presentation/pages/home_page_model.dart';

class ShortcutsSection extends StatelessWidget {
  final List<ShortcutItem> shortcuts;
  final VoidCallback onEditTap;

  const ShortcutsSection({super.key, required this.shortcuts, required this.onEditTap});

  static const _gridItemExtent = 92.0;
  static const _gridColumnCount = 4;
  static const _gridMainSpacing = 16.0;
  static const _gridCrossSpacing = 16.0;
  static const _iconSize = 48.0;
  static const _iconPadding = 10.0;
  static const _iconBorderRadius = 8.0;
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisExtent: _gridItemExtent,
              crossAxisCount: _gridColumnCount,
              mainAxisSpacing: _gridMainSpacing,
              crossAxisSpacing: _gridCrossSpacing,
            ),
            itemCount: shortcuts.length,
            itemBuilder: (context, index) {
              final item = shortcuts[index];
              return GestureDetector(
                onTap: () {
                  // TODO navigate to page
                },
                child: Column(
                  children: [
                    Container(
                      width: _iconSize,
                      height: _iconSize,
                      decoration: BoxDecoration(
                        color: item.backgroundColor,
                        borderRadius: BorderRadius.circular(_iconBorderRadius),
                      ),
                      padding: const EdgeInsets.all(_iconPadding),
                      child: SvgPicture.asset(
                        item.iconPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: _iconLabelGap),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
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
