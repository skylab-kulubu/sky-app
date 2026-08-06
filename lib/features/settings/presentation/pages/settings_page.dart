import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/links_service.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/core/theme/theme_provider.dart';
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
          _sectionHeader('Tercihler'),
          _group([
            SettingsTile(
              icon: AppIcons.appearance,
              iconColor: AppColors.purple,
              title: 'Görünüm',
              value: ThemeModeSheet.labelOf(
                context.watch<ThemeProvider>().themeMode,
              ),
              onTap: onAppearanceTap,
            ),
            _divider(),
            SettingsTile(
              icon: AppIcons.bell,
              iconColor: AppColors.red,
              title: 'Bildirimler',
              onTap: onNotificationsTap,
            ),
            _divider(),
            SettingsTile(
              icon: AppIcons.permissions,
              iconColor: AppColors.green,
              title: 'İzinler',
              onTap: onPermissionsTap,
            ),
          ]),
          _sectionHeader('Kaynaklar'),
          _group([
            SettingsTile(
              icon: AppIcons.support,
              iconColor: AppColors.secondaryBlue,
              title: 'Destek ile İletişime Geç',
              onTap: onSupportTap,
            ),
            _divider(),
            SettingsTile(
              icon: AppIcons.browser,
              iconColor: context.accentColor,
              title: 'SKY LAB Web Sitesi',
              trailingIcon: AppIcons.externalLink,
              onTap: onWebsiteTap,
            ),
          ]),
          const SizedBox(height: 24),
          _group([
            SettingsTile(
              icon: AppIcons.logout,
              iconColor: AppColors.red,
              title: 'Çıkış Yap',
              onTap: onLogoutTap,
            ),
          ]),
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: AppPaddings.sectionHeader,
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textSecondary,
        ),
      ),
    );
  }

  /// Satırları tek bir kart içinde toplar.
  Widget _group(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      child: Container(
        color: context.tileColor,
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    color: context.dividerColor,
    indent: 64,
    endIndent: 16,
  );
}
