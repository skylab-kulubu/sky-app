import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/user_avatar.dart';

/// Ayarların en üstündeki hesap satırı: avatar + ad + kullanıcı adı.
///
/// Hesap sayfasına açılır.
class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.name,
    required this.username,
    required this.onTap,
    this.imageUrl,
  });

  final String name;

  /// `@` ile birlikte gelir ([User.usernameDisplay]); boşsa alt satır
  /// hiç çizilmez.
  final String username;

  final VoidCallback onTap;

  /// Boş ya da null ise avatar baş harflere düşer.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tileColor,
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppPaddings.accountTile,
          child: Row(
            children: [
              UserAvatar(
                name: name,
                imageUrl: imageUrl,
                size: AppSizes.accountTileAvatar,
              ),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(child: _texts(context)),
              AppIcon(
                AppIcons.chevronRight,
                size: AppSizes.iconSmall,
                color: context.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        if (username.isNotEmpty) ...[
          const SizedBox(height: AppSizes.smallSpace),
          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
