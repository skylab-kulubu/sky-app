import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:sky_app/features/profile/presentation/widgets/quick_action_button.dart';
import 'package:sky_app/features/profile/presentation/widgets/skypass_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Navbar'ın kartların üstüne binmemesi için liste sonuna bırakılan boşluk.
  static const double _bottomInset = 120;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user!;

    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        SkyPassCard(
          name: user.name,
          skyNumber: user.skyNumber,
          subtitle: user.teamsDisplay.isNotEmpty
              ? user.teamsDisplay
              : user.department,
        ),
        const SizedBox(height: 24),
        _quickActions(),
        const SizedBox(height: 12),
        _sectionHeader(context, 'Hesap Bilgileri'),
        ProfileInfoCard(
          rows: [
            ProfileInfoRow(label: 'E-posta', value: user.email),
            ProfileInfoRow(label: 'Üniversite', value: user.university),
            ProfileInfoRow(label: 'Bölüm', value: user.department),
          ],
        ),
        const SizedBox(height: 24),
        _certificatesTile(context),
        const SizedBox(height: _bottomInset),
      ],
    );
  }

  Widget _quickActions() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: QuickActionButton(icon: AppIcons.qr, label: "QR'ı Göster"),
        ),
        Expanded(
          child: QuickActionButton(
            icon: AppIcons.studentCard,
            label: 'Öğrenci Kartını Eşle',
          ),
        ),
        Expanded(
          child: QuickActionButton(icon: AppIcons.nfc, label: "NFC'yi Aç"),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: AppPaddings.sectionHeader,
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textGray,
        ),
      ),
    );
  }

  Widget _certificatesTile(BuildContext context) {
    return Material(
      color: AppColors.tileBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/profile/certificates'),
        child: Padding(
          padding: AppPaddings.settingsTile,
          child: Row(
            children: [
              const AppIcon(
                AppIcons.certificate,
                size: AppSizes.icon,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(
                child: Text(
                  'Sertifikalarım',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const AppIcon(
                AppIcons.chevronRight,
                size: AppSizes.iconSmall,
                color: AppColors.textGrayDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
