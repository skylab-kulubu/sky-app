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
import 'package:sky_app/core/widgets/app_bar_actions.dart';
import 'package:sky_app/core/widgets/bottom_scrim.dart';
import 'package:sky_app/core/widgets/club_menu_sheet.dart';
import 'package:sky_app/core/widgets/nav_item.dart';
import 'package:sky_app/core/widgets/user_avatar.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      appBar: appBar(context),
      body: Stack(children: [child, const BottomScrim()]),
      bottomNavigationBar: navBar(currentLocation, context),
    );
  }

  Widget navBar(String currentLocation, BuildContext context) {
    return Padding(
      padding: AppPaddings.navBar,
      child: Center(
        // heightFactor olmadan Center tüm yüksekliği doldurur ve
        // bottomNavigationBar içinde hap ekranın ortasına düşer.
        heightFactor: 1,
        // Hap içeriğe oturuyor; dar ekranda taşmak yerine küçülsün diye
        // FittedBox ile sarmalanıyor.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: AppPaddings.navBarContent,
            decoration: BoxDecoration(
              color: context.tileColor.withValues(alpha: 0.95),
              borderRadius: AppRadiuses.stadiumBorderRadius,
              // Açık temada hap ile beyaz zemin arasındaki fark çok az
              // kalıyor; ince kenarlık sınırı belirginleştiriyor.
              border: Border.all(color: context.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.navShadowDark
                      : AppColors.navShadowLight,
                  blurRadius: 36,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavItem(
                  label: 'Ana Sayfa',
                  isSelected: currentLocation == '/home',
                  onTap: () => context.go('/home'),
                  icon: AppIcons.home,
                ),
                NavItem(
                  label: 'Etkinlikler',
                  isSelected: currentLocation == '/calendar',
                  onTap: () => context.go('/calendar'),
                  icon: AppIcons.calendar,
                ),
                NavItem(
                  label: 'Ekip',
                  isSelected: currentLocation == '/team',
                  onTap: () => context.go('/team'),
                  icon: AppIcons.users2,
                ),
                NavItem(
                  label: 'Profil',
                  isSelected: currentLocation == '/profile',
                  onTap: () => context.go('/profile'),
                  icon: AppIcons.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    final config = _AppBarConfig.forLocation(
      GoRouterState.of(context).matchedLocation,
    );

    return AppBar(
      automaticallyImplyLeading: false,
      title: _appBarTitle(context, config),
      actions: [
        AppBarActions(
          icons: config.actions,
          onIconTap: (icon) => _onActionTap(context, icon),
        ),
      ],
    );
  }

  /// Diğer ikonların sayfaları henüz yok; bağlanana kadar sessizce yok sayılır.
  void _onActionTap(BuildContext context, String icon) {
    if (icon == AppIcons.widget) ClubMenuSheet.show(context);
    if (icon == AppIcons.bell) context.push('/notification');
    if (icon == AppIcons.settings) context.push('/settings');
  }

  Widget _appBarTitle(BuildContext context, _AppBarConfig config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.showLogo) ...[
          SvgPicture.asset(
            AppAssets.skylab,
            width: AppSizes.iconLarge,
            height: AppSizes.iconLarge,
            fit: BoxFit.contain,
            // Logo beyaz monokrom; açık temada görünmesi için metin rengine
            // boyanıyor.
            colorFilter: ColorFilter.mode(context.textPrimary, BlendMode.srcIn),
          ),
          const SizedBox(width: AppSizes.midSpace),
        ],
        if (config.showAvatar) ...[
          Builder(
            builder: (context) {
              final user = context.watch<UserProvider>().user;
              return UserAvatar(
                name: user?.name ?? '',
                imageUrl: user?.profilePictureUrl,
              );
            },
          ),
          const SizedBox(width: AppSizes.midSpace),
        ],
        Text(config.title),
      ],
    );
  }
}

/// Shell sekmelerinin her biri için appbar içeriği.
class _AppBarConfig {
  const _AppBarConfig({
    required this.title,
    required this.actions,
    this.showLogo = false,
    this.showAvatar = false,
  });

  final String title;
  final List<String> actions;
  final bool showLogo;

  /// Başlığın soluna kullanıcı avatarı çizilir.
  final bool showAvatar;

  static const _home = _AppBarConfig(
    title: 'Sky Lab',
    showLogo: true,
    actions: [AppIcons.widget, AppIcons.bell],
  );
  static const _calendar = _AppBarConfig(
    title: 'Etkinlikler',
    actions: [AppIcons.search],
  );

  static const _team = _AppBarConfig(
    title: 'Ekip',
    actions: [AppIcons.shuffle, AppIcons.infoSquare],
  );
  static const _profile = _AppBarConfig(
    title: 'Profil',
    showAvatar: true,
    actions: [AppIcons.edit, AppIcons.settings],
  );

  factory _AppBarConfig.forLocation(String location) {
    if (location.startsWith('/calendar')) return _calendar;
    if (location.startsWith('/team')) return _team;
    if (location.startsWith('/profile')) return _profile;
    return _home;
  }
}
