import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';

class ExternalLinkTile extends StatelessWidget {
  const ExternalLinkTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
              _iconBox(),
              const SizedBox(width: 16),
              _textSection(),
              const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.textGrayDark,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiuses.iconBox),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _textSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontFamily: 'Poppins',
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
        ],
      ),
    );
  }
}
