import 'package:flutter/material.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_box.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailingIcon,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              IconBox(icon: icon, color: iconColor),
              const SizedBox(width: 16),
              _textSection(context),
              if (trailingIcon != null)
                AppIcon(trailingIcon!, color: context.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty)
            Text(
              subtitle!,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w300,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
        ],
      ),
    );
  }
}
