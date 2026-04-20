import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.teamName,
    this.avatarUrl,
  });

  final String? avatarUrl;
  final String name;
  final String email;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tileBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [_avatar(), const SizedBox(width: 16), _userInfo()]),
    );
  }

  Widget _avatar() {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: hasAvatar
            ? AppColors.tileBackgroundColor
            : Colors.purple.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.person, color: Colors.purple, size: 28),
              ),
            )
          : Center(child: Icon(Icons.person, color: Colors.purple, size: 28)),
    );
  }

  Widget _userInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            email,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            teamName,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
