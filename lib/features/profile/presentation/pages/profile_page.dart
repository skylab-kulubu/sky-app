import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/profile/presentation/widgets/external_link_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/logout_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/navigation_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:sky_app/features/profile/presentation/widgets/section_header.dart';

part 'profile_pagemodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ProfilePageModel {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.mainHorizontalPadding.copyWith(top: 8, bottom: 40),
      children: [
        _appBranding(),
        const SizedBox(height: 24),
        const ProfileHeader(
          initials: 'SK',
          name: 'SKY LAB Üyesi',
          email: 'skylab@std.yildiz.edu.tr',
          teamName: 'mobilab ekibi',
        ),
        const SectionHeader(title: 'KULÜP'),
        _clubSection(),
        const SectionHeader(title: 'BAĞLANTILAR'),
        _linksSection(),
        const SizedBox(height: 20),
        _contactSection(),
        const SizedBox(height: 12),
        LogoutTile(onTap: onLogoutTap),
      ],
    );
  }

  Widget _appBranding() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          AppAssets.mobilab,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        SvgPicture.asset(
          AppAssets.skylab,
          width: 44,
          height: 44,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        const Icon(
          Icons.notifications_none_rounded,
          color: Colors.white,
          size: AppSizes.icon,
        ),
      ],
    );
  }

  Widget _clubSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tileBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadiuses.tile),
      ),
      child: Column(
        children: [
          NavigationTile(
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.primaryColor,
            title: 'Ekipler',
            subtitle: 'Kulüp ekiplerini keşfet',
            onTap: () {},
          ),
          _divider(),
          NavigationTile(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.primaryColor,
            title: 'Sertifikalar',
            subtitle: 'Bootcamp ve eğitim sertifikaları',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _linksSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tileBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadiuses.tile),
      ),
      child: Column(
        children: [
          ExternalLinkTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.primaryColor,
            title: 'YıldızSkylab',
            subtitle: 'SKY LAB resmi web sitesi',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.red,
            title: 'YıldızPlace',
            subtitle: 'YTÜ kampüs haritası ve mekan rehberi',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.videogame_asset_rounded,
            iconColor: AppColors.green,
            title: 'YTUGuessr',
            subtitle: 'YTÜ kampüsünü keşfet, konumu tahmin et',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.cloud_rounded,
            iconColor: AppColors.teal,
            title: 'SKYCLOUD',
            subtitle: 'Kulüp dosya paylaşım ve depolama sistemi',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.description_rounded,
            iconColor: AppColors.purple,
            title: 'SKYFORMS',
            subtitle: 'Kulüp anket ve form platformu',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.shield_rounded,
            iconColor: AppColors.orange,
            title: 'SKYSEC Articles',
            subtitle: 'Siber güvenlik makaleleri ve yazıları',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.meeting_room_rounded,
            iconColor: AppColors.teal,
            title: 'Sky Lab Oda Durumu',
            subtitle: 'Kulüp odasının anlık açık/kapalı durumu',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.storage_rounded,
            iconColor: AppColors.orange,
            title: 'Sky Lab Sunucu Durumu',
            subtitle: 'Sunucu ve servis erişilebilirlik durumu',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.picture_as_pdf_rounded,
            iconColor: AppColors.pink,
            title: 'SKYPDF',
            subtitle: 'PDF dönüştürme ve düzenleme aracı',
            onTap: () {},
          ),
          _divider(),
          ExternalLinkTile(
            icon: Icons.storefront_rounded,
            iconColor: AppColors.darkPurple,
            title: 'Stant',
            subtitle: 'Kulüp stant ve tanıtım etkinlikleri',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _contactSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tileBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadiuses.tile),
      ),
      child: NavigationTile(
        icon: Icons.email_rounded,
        iconColor: AppColors.primaryColor,
        title: 'İletişim',
        subtitle: '',
        onTap: () {},
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
