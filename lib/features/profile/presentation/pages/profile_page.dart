import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_header.dart';

part 'profile_pagemodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ProfilePagemodel {
  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;

    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        ProfileHeader(
          name: user!.name,
          email: user.email,
          teamName: user.teamsDisplay,
        ),
        const SizedBox(height: 20),
        // _contactSection(),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadiuses.tile),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.tileBackgroundColor,
              borderRadius: BorderRadius.circular(AppRadiuses.tile),
            ),
            child: ProfileTile(
              icon: 'assets/icons/logout.svg',
              iconColor: AppColors.red,
              title: 'Çıkış Yap',
              onTap: onLogoutTap,
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  // Widget _contactSection() {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(AppRadiuses.tile),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: AppColors.tileBackgroundColor,
  //         borderRadius: BorderRadius.circular(AppRadiuses.tile),
  //       ),
  //       child: ProfileTile(
  //         icon: AppAssets.email,
  //         iconColor: AppColors.primaryColor,
  //         title: 'İletişim',
  //         trailingIcon: AppIcons.chevronRight,
  //         onTap: () {},
  //       ),
  //     ),
  //   );
  // }
}
