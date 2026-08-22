import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/data/services/activity_service.dart';
import 'package:sky_app/features/profile/data/services/nfc_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/activity_tile.dart';
import 'package:sky_app/features/profile/presentation/widgets/nfc_scan_overlay.dart';
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

    final subtitle = user.teamsDisplay.isNotEmpty
        ? user.teamsDisplay
        : user.department;

    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        Hero(
          tag: 'skypass_card_hero',
          createRectTween: (begin, end) => RectTween(begin: begin, end: end),
          child: Material(
            type: MaterialType.transparency,
            child: SkyPassCard(
              name: user.name,
              skyNumber: user.skyNumber,
              subtitle: subtitle,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _quickActions(context, user, subtitle),
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
  Widget _quickActions(BuildContext context, User user, String subtitle) {
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
        Expanded(
          child: QuickActionButton(
            icon: AppIcons.studentCard,
            label: 'Öğrenci Kartını Eşle',
            onTap: () => _onStudentCardTap(
              context,
              userName: user.name,
              skyNumber: user.skyNumber,
              subtitle: subtitle,
            ),
          ),
        ),
        const Expanded(
          child: QuickActionButton(icon: AppIcons.nfc, label: "NFC'yi Aç"),
        ),
      ],
    );
  }

  /// NFC durumunu kontrol eder ve uygunsa okutma overlay'ini açar.
  Future<void> _onStudentCardTap(
    BuildContext context, {
    required String userName,
    required String skyNumber,
    required String subtitle,
  }) async {
    final nfcService = NfcService();

    try {
      final availability = await nfcService.checkAvailability();

      if (!context.mounted) return;

      if (availability == NFCAvailability.not_supported) {
        _showNfcAlert(
          context,
          title: 'NFC Desteklenmiyor',
          message:
              'Cihazınızda NFC donanım desteği bulunmamaktadır. Öğrenci kartı okutulamaz.',
        );
        return;
      }

      if (availability == NFCAvailability.disabled) {
        _showNfcAlert(
          context,
          title: 'NFC Kapalı',
          message:
              'Öğrenci kartınızı okutabilmek için lütfen telefonunuzun ayarlarından NFC özelliğini açın.',
        );
        return;
      }

      // NFC açık — Hero animasyonlu dikey overlay'i aç
      await NfcScanOverlay.show(
        context,
        userName: userName,
        skyNumber: skyNumber,
        subtitle: subtitle,
      );
    } catch (_) {
      if (!context.mounted) return;
      _showNfcAlert(
        context,
        title: 'NFC Hatası',
        message: 'NFC durumu kontrol edilemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  void _showNfcAlert(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tileColor,
        title: Text(title, style: TextStyle(color: context.textPrimary)),
        content: Text(message, style: TextStyle(color: context.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam', style: TextStyle(color: context.accentColor)),
          ),
        ],
      ),
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
