import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

class NavItem extends StatelessWidget {
  final IconData unSelectedIcon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const NavItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.unSelectedIcon,
    required this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadiuses.navitem),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadiuses.navitem),
        onTap: onTap,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? selectedIcon : unSelectedIcon,
                  size: AppSizes.icon,
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
