import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:url_launcher/url_launcher.dart';

part 'contact_pagemodel.dart';

/// Destek ve kulübün sosyal medya hesapları.
///
/// Satırların hepsi uygulamanın dışına çıkıyor (mail uygulaması, tarayıcı,
/// Instagram/LinkedIn uygulaması); bu yüzden sağlarında ok değil
/// [AppIcons.externalLink] var.
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ContactPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İletişim'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: AppPaddings.mainPaddingAll,
        children: [
          const SectionHeader('Destek', isFirst: true),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.email,
                iconColor: AppColors.secondaryBlue,
                title: 'E-posta Gönder',
                trailingIcon: AppIcons.externalLink,
                onTap: onEmailTap,
              ),
              SettingsTile(
                icon: AppIcons.bug,
                iconColor: AppColors.orange,
                title: 'Hata Bildir',
                trailingIcon: AppIcons.externalLink,
                onTap: onBugReportTap,
              ),
            ],
          ),
          const SectionHeader('Sosyal Medya'),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.instagram,
                iconColor: AppColors.pink,
                title: 'Instagram',
                trailingIcon: AppIcons.externalLink,
                onTap: onInstagramTap,
              ),
              SettingsTile(
                icon: AppIcons.linkedin,
                iconColor: AppColors.blue,
                title: 'LinkedIn',
                trailingIcon: AppIcons.externalLink,
                onTap: onLinkedInTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
