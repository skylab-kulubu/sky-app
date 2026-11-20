import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_features.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/presentation/pages/session_check_in/session_check_in_page.dart';
import 'package:sky_app/features/profile/data/services/nfc_service.dart';
import 'package:sky_app/features/profile/presentation/providers/activity_provider.dart';
import 'package:sky_app/features/profile/presentation/widgets/activity_list.dart';
import 'package:sky_app/features/profile/presentation/widgets/nfc_scan_overlay.dart';
import 'package:sky_app/features/profile/presentation/widgets/quick_action_button.dart';
import 'package:sky_app/features/profile/presentation/widgets/skypass_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Navbar kartların üstüne binmesin diye liste sonundaki boşluk.
  static const double _bottomInset = 120;

  static const double _sectionSpacing = 32;
  static const double _titleSpacing = 12;

  final SkyPassCardController _cardController = SkyPassCardController();

  /// Eşleme sürerken ve kart yerine dönerken buton yerinde kalıyor.
  bool _isLinkRevealPending = false;

  /// Overlay kapanırken kartın yerine uçma süresi.
  static const Duration _cardReturnDuration = Duration(milliseconds: 500);

  static const Duration _buttonFadeDuration = Duration(milliseconds: 450);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    // Çıkışta kullanıcı temizleniyor ama `/auth`'a yönlendirme bir sonraki
    // karede; o kare boyunca çizilecek veri yok (`user!` patlıyordu).
    if (user == null) return const SizedBox.shrink();

    final subtitle = user.teamsDisplay.isNotEmpty
        ? user.teamsDisplay
        : user.department;

    return RefreshIndicator.adaptive(
      onRefresh: () => _onRefresh(user.id),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                controller: _cardController,
                showStudentCardMark: user.studentCardLinked,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.largeSpace),
          _quickActions(context, user, subtitle),
          const SizedBox(height: _sectionSpacing),
          _sectionTitle(context, 'Aktivitelerim'),
          const SizedBox(height: _titleSpacing),
          ActivityList(userId: user.id),
          const SizedBox(height: _bottomInset),
        ],
      ),
    );
  }

  /// Profil (kart eşlemesi, ekipler) ve aktiviteler birlikte yenileniyor.
  Future<void> _onRefresh(String userId) => Future.wait([
    context.read<UserProvider>().reloadProfile(),
    context.read<ActivityProvider>().refresh(userId),
  ]);

  /// "QR'ı Göster" kartı çeviriyor (karta dokunmakla aynı iş, keşfedilsin
  /// diye). Kapıda giriş alma yönetim menüsünde.
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
        // Eşlenmiş kartta buton yerine "QR Okut"; öğrenci kartı kapalıyken
        // ([AppFeatures.studentCard]) hep "QR Okut".
        Expanded(
          child: AnimatedSwitcher(
            duration: _buttonFadeDuration,
            child:
                AppFeatures.studentCard &&
                    (!user.studentCardLinked || _isLinkRevealPending)
                ? QuickActionButton(
                    key: const ValueKey('link-card'),
                    icon: AppIcons.studentCard,
                    label: 'Öğrenci Kartını Eşle',
                    onTap: () => _onStudentCardTap(
                      context,
                      userName: user.name,
                      skyNumber: user.skyNumber,
                      subtitle: subtitle,
                    ),
                  )
                : QuickActionButton(
                    key: const ValueKey('scan-qr'),
                    icon: AppIcons.scan,
                    label: 'QR Okut',
                    onTap: () => SessionCheckInPage.open(context),
                  ),
          ),
        ),
        Expanded(
          child: QuickActionButton(
            icon: AppIcons.qr,
            label: "QR'ı Göster",
            onTap: _cardController.flip,
          ),
        ),
      ],
    );
  }

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

      // Buton kart yerine dönene kadar kalıyor, sonra "QR Okut"a dönüşüyor.
      setState(() => _isLinkRevealPending = true);
      final userProvider = context.read<UserProvider>();

      final linked = await NfcScanOverlay.show(
        context,
        userName: userName,
        skyNumber: skyNumber,
        subtitle: subtitle,
        onLinked: userProvider.reloadProfile,
      );

      if (linked) await Future<void>.delayed(_cardReturnDuration);
      if (!mounted) return;
      setState(() => _isLinkRevealPending = false);
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.tileColor,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        title: Text(
          title,
          style: dialogContext.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: dialogContext.textTheme.bodyMedium?.copyWith(
            color: dialogContext.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Tamam',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: dialogContext.accentColor,
              ),
            ),
          ),
        ],
      ),
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
