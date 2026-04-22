import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadiuses.navitem),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadiuses.navitem),
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : unSelectedIcon,
                size: 26,
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: isSmall ? 9 : 11,
                  height: 1.2,
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
