import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/data/services/activity_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/activity_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/quick_action_button.dart';
import 'package:sky_app/features/profile/presentation/widgets/skypass_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Navbar'ın kartların üstüne binmemesi için liste sonuna bırakılan boşluk.
  static const double _bottomInset = 120;

  static const double _sectionSpacing = 32;
  static const double _titleSpacing = 12;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    // Çıkışta kullanıcı temizleniyor ve sayfa hemen yeniden çiziliyor, ama
    // `/auth`'a yönlendirme bir sonraki karede gerçekleşiyor. O kare boyunca
    // çizilecek veri yok; `user!` burada patlıyordu.
    if (user == null) return const SizedBox.shrink();

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
        _quickActions(context),
        const SizedBox(height: _sectionSpacing),
        _sectionTitle(context, 'Aktivitelerim'),
        const SizedBox(height: _titleSpacing),
        _activities(),
        const SizedBox(height: _bottomInset),
      ],
    );
  }

  /// QR artık kartın arka yüzünde olduğu için "QR'ı Göster"in yeri
  /// sertifikalara devredildi.
  Widget _quickActions(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: QuickActionButton(
            icon: AppIcons.certificate,
            label: 'Sertifikalarım',
            onTap: () => context.push('/profile/certificates'),
          ),
        ),
        const Expanded(
          child: QuickActionButton(
            icon: AppIcons.studentCard,
            label: 'Öğrenci Kartını Eşle',
          ),
        ),
        const Expanded(
          child: QuickActionButton(icon: AppIcons.nfc, label: "NFC'yi Aç"),
        ),
      ],
    );
  }

  Widget _activities() {
    final activities = ActivityService.list;

    return Column(
      children: [
        for (final activity in activities) ActivityTile(item: activity),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
