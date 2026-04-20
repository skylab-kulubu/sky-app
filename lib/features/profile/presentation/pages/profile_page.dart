import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:sky_app/features/profile/presentation/widgets/section_header.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

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
      padding: AppPaddings.mainPaddingAll,
      children: [
        const ProfileHeader(
          name: 'Yakup Emin',
          email: 'skylab@std.yildiz.edu.tr',
          teamName: 'MOBILAB',
        ),
        const SectionHeader(title: 'KULÜP'),
        _clubSection(),
        const SectionHeader(title: 'BAĞLANTILAR'),
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
              icon: Icons.logout_rounded,
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
              icon: Icons.people_alt_rounded,
              iconColor: AppColors.primaryColor,
              title: 'Ekipler',
              subtitle: 'Kulüp ekiplerini keşfet',
              trailingIcon: Icons.chevron_right_rounded,
              onTap: () {},
            ),
            _divider(),
            ProfileTile(
              icon: Icons.workspace_premium_rounded,
              iconColor: AppColors.primaryColor,
              title: 'Sertifikalar',
              subtitle: 'Bootcamp ve eğitim sertifikaları',
              trailingIcon: Icons.chevron_right_rounded,
              onTap: () {},
            ),
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
        child: Column(
          children: [
            ProfileTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.primaryColor,
              title: 'YıldızSkylab',
              subtitle: 'SKY LAB resmi web sitesi',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://yildizskylab.com', 'YıldızSkylab'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.red,
              title: 'YıldızPlace',
              subtitle: 'YTÜ kampüs haritası ve mekan rehberi',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://yildizplace.com', 'YıldızPlace'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.videogame_asset_rounded,
              iconColor: AppColors.green,
              title: 'YTUGuessr',
              subtitle: 'YTÜ kampüsünü keşfet, konumu tahmin et',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () => _openWebView('https://ytuguessr.com', 'YTUGuessr'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.cloud_rounded,
              iconColor: AppColors.teal,
              title: 'SKYCLOUD',
              subtitle: 'Kulüp dosya paylaşım ve depolama sistemi',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://cloud.yildizskylab.com', 'SKYCLOUD'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.description_rounded,
              iconColor: AppColors.purple,
              title: 'SKYFORMS',
              subtitle: 'Kulüp anket ve form platformu',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://forms.yildizskylab.com', 'SKYFORMS'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.shield_rounded,
              iconColor: AppColors.orange,
              title: 'SKYSEC Articles',
              subtitle: 'Siber güvenlik makaleleri ve yazıları',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () => _openWebView(
                'https://articles.sky-sec.org',
                'SKYSEC Articles',
              ),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.meeting_room_rounded,
              iconColor: AppColors.teal,
              title: 'Sky Lab Oda Durumu',
              subtitle: 'Kulüp odasının anlık açık/kapalı durumu',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://room.yildizskylab.com', 'Oda Durumu'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.storage_rounded,
              iconColor: AppColors.orange,
              title: 'Sky Lab Sunucu Durumu',
              subtitle: 'Sunucu ve servis erişilebilirlik durumu',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () => _openWebView(
                'https://status.yildizskylab.com',
                'Sunucu Durumu',
              ),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: AppColors.pink,
              title: 'SKYPDF',
              subtitle: 'PDF dönüştürme ve düzenleme aracı',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://pdf.yildizskylab.com', 'SKYPDF'),
            ),
            _divider(),
            ProfileTile(
              icon: Icons.storefront_rounded,
              iconColor: AppColors.darkPurple,
              title: 'Stant',
              subtitle: 'Kulüp stant ve tanıtım etkinlikleri',
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () =>
                  _openWebView('https://stant.yildizskylab.com', 'Stant'),
            ),
          ],
        ),
      ),
    );
  }

  void _openWebView(String url, String title) {
    if (kIsWeb) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      context.push('/webview', extra: {'url': url, 'title': title});
    }
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
          icon: Icons.email_rounded,
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
