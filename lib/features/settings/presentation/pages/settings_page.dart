import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/links_service.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
import 'package:sky_app/features/settings/presentation/widgets/account_tile.dart';
import 'package:sky_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:sky_app/features/settings/presentation/widgets/theme_mode_sheet.dart';

part 'settings_pagemodel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends SettingsPagemodel {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(AppIcons.arrowBack),
        ),
      ),
      body: ListView(
        padding: AppPaddings.mainPaddingAll,
        children: [
          // Çıkışta kullanıcı bir kare boyunca null kalıyor; satır o karede
          // çizilmiyor (bkz. profile_page.dart).
          if (user != null)
            AccountTile(
              name: user.name,
              username: user.usernameDisplay,
              imageUrl: user.profilePictureUrl,
              onTap: onAccountTap,
            ),
          const SectionHeader('Tercihler'),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.appearance,
                iconColor: AppColors.purple,
                title: 'Görünüm',
                value: ThemeModeSheet.labelOf(
                  context.watch<ThemeProvider>().themeMode,
                ),
                onTap: onAppearanceTap,
              ),
              SettingsTile(
                icon: AppIcons.bell,
                iconColor: AppColors.red,
                title: 'Bildirimler',
                onTap: onNotificationsTap,
              ),
              SettingsTile(
                icon: AppIcons.permissions,
                iconColor: AppColors.green,
                title: 'İzinler',
                onTap: onPermissionsTap,
              ),
            ],
          ),
          const SectionHeader('Kaynaklar'),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.support,
                iconColor: AppColors.secondaryBlue,
                title: 'Destek ile İletişime Geç',
                onTap: onSupportTap,
              ),
              SettingsTile(
                icon: AppIcons.browser,
                iconColor: context.accentColor,
                title: 'SKY LAB Web Sitesi',
                trailingIcon: AppIcons.externalLink,
                onTap: onWebsiteTap,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.logout,
                iconColor: AppColors.red,
                title: 'Çıkış Yap',
                onTap: onLogoutTap,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sectionSpace),
          _credit(),
        ],
      ),
    );
  }

  /// Geliştirici künyesi. Giriş sayfasındaydı; oraya her açılışta bakılıyor
  /// ama bilgi aranarak bulunacak türden, o yüzden ayarların sonunda.
  Widget _credit() {
    return Padding(
      padding: AppPaddings.credit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Developed by ',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textTertiary,
            ),
          ),
          SvgPicture.asset(
            AppAssets.mobilab,
            height: AppSizes.iconMedium,
            colorFilter: ColorFilter.mode(
              context.textTertiary,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
