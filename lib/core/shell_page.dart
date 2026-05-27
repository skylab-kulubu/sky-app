import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/widgets/nav_item.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, required this.child});

  final Widget child;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      appBar: appBar(context),
      body: Stack(
        children: [
          widget.child,
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
          Positioned(
            top: -10,
            left: 40,
            child: CustomConfetti(confettiController: _confettiController),
          ),
        ],
      ),
      bottomNavigationBar: navBar(currentLocation, context),
    );
  }

  Padding navBar(String currentLocation, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 10),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.midSpace),
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
                  label: 'Etkinlikler',
                  isSelected: currentLocation == '/calendar',
                  onTap: () => context.go('/calendar'),
                  unSelectedIcon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                ),
              ),
              Expanded(
                child: NavItem(
                  label: 'Biletler',
                  isSelected: currentLocation == '/tickets',
                  onTap: () => context.go('/tickets'),
                  unSelectedIcon: Icons.local_activity_outlined,
                  selectedIcon: Icons.local_activity,
                ),
              ),
              // Expanded(
              //   child: NavItem(
              //     label: 'Ekip',
              //     isSelected: currentLocation == '/team',
              //     onTap: () => context.go('/team'),
              //     unSelectedIcon: Icons.people_outline,
              //     selectedIcon: Icons.people,
              //   ),
              // ),
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
        width: AppSizes.shellTitleLogo,
        height: AppSizes.shellTitleLogo,
        fit: BoxFit.contain,
      ),
      leadingWidth: 60,
      leading: MobilabIconButton(confettiController: _confettiController),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 5),
      //     child: SizedBox(
      //       width: 44,
      //       height: 44,
      //       child: IconButton(
      //         onPressed: () => context.push('/notification'),
      //         padding: EdgeInsets.zero,
      //         constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      //         iconSize: 26,
      //         icon: Icon(
      //           Icons.notifications_outlined,
      //           size: AppSizes.icon,
      //           color: context.colorScheme.onSurface,
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}

class MobilabIconButton extends StatelessWidget {
  const MobilabIconButton({super.key, required this._confettiController});

  final ConfettiController _confettiController;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _confettiController.stop();
        _confettiController.play();
      },
      padding: EdgeInsets.zero,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      icon: SvgPicture.asset(
        AppAssets.mobilab,
        width: AppSizes.shellLeadingLogo,
        height: AppSizes.shellLeadingLogo,
        fit: BoxFit.contain,
      ),
    );
  }
}

class CustomConfetti extends StatelessWidget {
  const CustomConfetti({super.key, required this._confettiController});

  final ConfettiController _confettiController;

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.directional,
      blastDirection: 0.5, // ~30 degrees, toward bottom-right
      shouldLoop: false,
      numberOfParticles: 50,
      maxBlastForce: 30,
      minBlastForce: 15,
      gravity: 0.25,
      emissionFrequency: 0.05,
      particleDrag: 0.05,
      colors: AppColors.confetti,
    );
  }
}
