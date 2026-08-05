import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

class EditShortcutsSheet extends StatefulWidget {
  final List<LinkItem> allShortcuts;
  final Set<int> visibleIndices;
  final ValueChanged<Set<int>> onChanged;

  const EditShortcutsSheet({
    super.key,
    required this.allShortcuts,
    required this.visibleIndices,
    required this.onChanged,
  });

  @override
  State<EditShortcutsSheet> createState() => _EditShortcutsSheetState();
}

class _EditShortcutsSheetState extends State<EditShortcutsSheet> {
  late Set<int> _selected;

  static const _iconSize = 44.0;
  static const _iconPadding = 8.0;
  static const _iconBorderRadius = 8.0;
  static const _checkSize = 28.0;
  static const _cardBorderRadius = 12.0;
  static const _sheetBorderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.visibleIndices);
  }

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
    widget.onChanged(Set.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_sheetBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: context.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Kısayolları Düzenle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: AppIcon(AppIcons.close, color: context.textPrimary),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: widget.allShortcuts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.allShortcuts[index];
                final isSelected = _selected.contains(index);
                return GestureDetector(
                  onTap: () => _toggle(index),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.tileColor,
                      borderRadius: BorderRadius.circular(_cardBorderRadius),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: _iconSize,
                          height: _iconSize,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              _iconBorderRadius,
                            ),
                          ),
                          padding: const EdgeInsets.all(_iconPadding),
                          child: SvgPicture.asset(
                            item.iconPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: context.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: _checkSize,
                          height: _checkSize,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.blue
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: context.dividerColor,
                                    width: 1.5,
                                  ),
                          ),
                          child: isSelected
                              ? AppIcon(
                                  AppIcons.check,
                                  color: context.textPrimary,
                                  size: 18,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
