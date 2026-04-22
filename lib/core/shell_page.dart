import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/nav_item.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      appBar: appBar(context),
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: navBar(currentLocation, context),
    );
  }

  Padding navBar(String currentLocation, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40, top: 10),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.tileBackgroundColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppRadiuses.navbar),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: NavItem(
                  label: 'Ana Sayfa',
                  isSelected: currentLocation == '/home',
                  onTap: () => context.go('/home'),
                  unSelectedIcon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                ),
              ),
              Expanded(
                child: NavItem(
                  label: 'Takvim',
                  isSelected: currentLocation == '/calendar',
                  onTap: () => context.go('/calendar'),
                  unSelectedIcon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                ),
              ),
              Expanded(
                child: NavItem(
                  label: 'QR',
                  isSelected: currentLocation == '/qr',
                  onTap: () => context.go('/qr'),
                  unSelectedIcon: Icons.qr_code_outlined,
                  selectedIcon: Icons.qr_code,
                ),
              ),
              Expanded(
                child: NavItem(
                  label: 'Ekip',
                  isSelected: currentLocation == '/team',
                  onTap: () => context.go('/team'),
                  unSelectedIcon: Icons.people_outline,
                  selectedIcon: Icons.people,
                ),
              ),
              Expanded(
                child: NavItem(
                  label: 'Profil',
                  isSelected: currentLocation == '/profile',
                  onTap: () => context.go('/profile'),
                  unSelectedIcon: Icons.person_outline,
                  selectedIcon: Icons.person,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: SvgPicture.asset(
        AppAssets.skylab,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          Color.fromRGBO(255, 255, 255, 1),
          BlendMode.srcIn,
        ),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SvgPicture.asset(
            AppAssets.mobilab,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              iconSize: 26,
              icon: Icon(
                Icons.notifications_outlined,
                size: AppSizes.icon,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
