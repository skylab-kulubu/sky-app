import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/services/links_service.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_header.dart';

part 'profile_pagemodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ProfilePageModel {
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
        _sectionHeader('KULÜP'),
        _clubSection(),
        _sectionHeader('BAĞLANTILAR'),
        _linksSection(),
        const SizedBox(height: 20),
        _contactSection(),
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

  Padding _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrayDark,
          letterSpacing: 1.2,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _clubSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tileBackgroundColor,
          borderRadius: BorderRadius.circular(AppRadiuses.tile),
        ),
        child: Column(
          children: [
            ProfileTile(
              icon: AppAssets.people,
              iconColor: AppColors.primaryColor,
              title: 'Ekipler',
              subtitle: 'Kulüp ekiplerini keşfet',
              trailingIcon: Icons.chevron_right_rounded,
              onTap: () {
                context.push('/profile/teams');
              },
            ),

            // _divider(),
            // ProfileTile(
            //   icon: AppAssets.certificate,
            //   iconColor: AppColors.primaryColor,
            //   title: 'Sertifikalar',
            //   subtitle: 'Bootcamp ve eğitim sertifikaları',
            //   trailingIcon: Icons.chevron_right_rounded,
            //   onTap: () {
            //     context.go('/profile/certificates');
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _linksSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tileBackgroundColor,
          borderRadius: BorderRadius.circular(AppRadiuses.tile),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: LinksService.list.length,
          separatorBuilder: (context, index) => _divider(),
          itemBuilder: (context, index) {
            final link = LinksService.list[index];
            return ProfileTile(
              icon: link.iconPath,
              iconColor: link.color,
              title: link.name,
              subtitle: link.description,
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () {
                WebviewService.openLink(context, link);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _contactSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tileBackgroundColor,
          borderRadius: BorderRadius.circular(AppRadiuses.tile),
        ),
        child: ProfileTile(
          icon: AppAssets.email,
          iconColor: AppColors.primaryColor,
          title: 'İletişim',
          trailingIcon: Icons.chevron_right_rounded,
          onTap: () {},
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    color: AppColors.dividerColor,
    indent: 72,
    endIndent: 16,
  );
}
