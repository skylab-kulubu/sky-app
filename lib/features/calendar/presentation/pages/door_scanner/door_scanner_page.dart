import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/door_service.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_schedule/event_schedule_page.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_option_sheet.dart';
import 'package:sky_app/features/profile/data/models/nfc_card.dart';
import 'package:sky_app/features/profile/data/services/nfc_service.dart';

part 'door_scanner_pagemodel.dart';

/// Kapı okuyucusu: görevli etkinliği ve oturumu seçip katılımcıların
/// SkyPass QR'ını okutuyor, giriş core'a oturum bazında yazılıyor
/// (`POST /v1/sessions/{id}/check-in/skypass`).
///
/// Yalnızca kapı yetkisi olan etkinlikler listeleniyor ([User.canCheckIn]).
/// Okuyucu her okutmadan sonra açık kalıyor; sonuç kısa süre altta görünüp
/// kayboluyor.
class DoorScannerPage extends StatefulWidget {
  const DoorScannerPage({super.key});

  /// Tam ekran açar (navbar'ın altında kalmasın diye kök navigator'da).
  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => const DoorScannerPage()));
  }

  @override
  State<DoorScannerPage> createState() => _DoorScannerPageState();
}

class _DoorScannerPageState extends DoorScannerPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Al'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: isLoadingEvents
          ? const Center(child: CircularProgressIndicator.adaptive())
          : eventsError != null
          ? _message(
              icon: eventsError!.isConnectivityIssue
                  ? AppIcons.wifiOff
                  : AppIcons.warning,
              title: 'Etkinlikler Yüklenemedi',
              message: eventsError!.userMessage,
              actionLabel: 'Tekrar Dene',
              onAction: onRetryEvents,
            )
          : events.isEmpty
          ? _message(
              icon: AppIcons.calendar,
              title: 'Okutulacak Etkinlik Yok',
              message:
                  'Giriş alabileceğin yaklaşan bir etkinlik yok. Etkinliğin '
                  'lideri ya da kapı görevlisi olduğunda burada görünecek.',
            )
          : ListView(
              padding: AppPaddings.mainPaddingAll,
              children: [
                const SectionHeader('Yoklama', isFirst: true),
                _selectors(),
                const SizedBox(height: AppSizes.largeSpace),
                _modeSwitch(),
                const SizedBox(height: AppSizes.bigSpace),
                _scannerArea(),
                const SizedBox(height: AppSizes.bigSpace),
                _resultCard(),
              ],
            ),
    );
  }

  Widget _selectors() {
    return TileGroup(
      children: [
        SettingsTile(
          icon: AppIcons.calendar,
          iconColor: AppColors.blue,
          title: 'Etkinlik',
          value: eventLabel,
          trailingIcon: events.length > 1 ? AppIcons.chevronRight : null,
          onTap: onChooseEvent,
        ),
        SettingsTile(
          icon: AppIcons.clock,
          iconColor: AppColors.purple,
          title: 'Oturum',
          value: sessionLabel,
          subtitle: sessionSubtitle,
          trailingIcon: sessions.length > 1 ? AppIcons.chevronRight : null,
          onTap: onChooseSession,
        ),
      ],
    );
  }

  /// Kamera ancak bir oturum seçiliyken açılıyor; yoklama oturuma yazılıyor.
  Widget _scannerArea() {
    final Widget child;
    if (isLoadingSessions) {
      child = const Center(child: CircularProgressIndicator.adaptive());
    } else if (sessionsError != null) {
      child = _message(
        icon: sessionsError!.isConnectivityIssue
            ? AppIcons.wifiOff
            : AppIcons.warning,
        title: 'Oturumlar Yüklenemedi',
        message: sessionsError!.userMessage,
        actionLabel: 'Tekrar Dene',
        onAction: onRetrySessions,
      );
    } else if (selected == null) {
      child = _message(
        icon: AppIcons.clock,
        title: 'Oturum Yok',
        message: canEditSchedule
            ? 'Yoklama oturum bazında alınıyor. Önce etkinliğin programına '
                  'gün ve oturum ekle.'
            : 'Yoklama oturum bazında alınıyor. Etkinliği düzenleyenlerin '
                  'programa oturum eklemesi gerekiyor.',
        actionLabel: canEditSchedule ? 'Programı Düzenle' : null,
        onAction: canEditSchedule ? onEditSchedule : null,
      );
    } else if (mode == DoorMode.card) {
      child = _cardReader();
    } else {
      child = MobileScanner(
        controller: scanner,
        onDetect: onDetect,
        errorBuilder: (context, error) => _message(
          icon: AppIcons.camera,
          title: 'Kamera Açılamadı',
          message: error.errorCode == MobileScannerErrorCode.permissionDenied
              ? 'Kodları okutmak için ayarlardan kameraya izin ver.'
              : 'Kamera başlatılamadı. Sayfayı kapatıp yeniden aç.',
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: AppRadiuses.cardBorderRadius,
        child: ColoredBox(color: context.tileColor, child: child),
      ),
    );
  }

  /// QR ile öğrenci kartı arasında seçim; iki eşit hap.
  Widget _modeSwitch() {
    Widget option(DoorMode value, String icon, String label) {
      final selected = mode == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onModeChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppPaddings.buttonInternalPadding,
            decoration: BoxDecoration(
              color: selected ? context.accentColor : context.tileColor,
              borderRadius: AppRadiuses.stadiumBorderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  icon,
                  size: AppSizes.iconSmall,
                  color: selected
                      ? context.onAccentColor
                      : context.textSecondary,
                ),
                const SizedBox(width: AppSizes.midSpace),
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? context.onAccentColor
                        : context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(DoorMode.qr, AppIcons.scan, 'QR Okut'),
        const SizedBox(width: AppSizes.midSpace),
        option(DoorMode.card, AppIcons.studentCard, 'Öğrenci Kartı'),
      ],
    );
  }

  /// Kart modu: NFC okumayı butonla başlatıyor (iOS her seferinde sistem
  /// penceresini açıyor).
  Widget _cardReader() {
    return _message(
      icon: AppIcons.nfc,
      title: 'Öğrenci Kartını Okut',
      message:
          'Kişinin öğrenci kartını telefonun arkasına yaklaştır. Kartın '
          'önceden SkyPass\'e eşlenmiş olması gerekiyor.',
      actionLabel: isReadingCard ? null : 'Kartı Okut',
      onAction: isReadingCard ? null : onReadCard,
      loading: isReadingCard,
    );
  }

  /// Son okutmanın sonucu; yoksa ne yapılacağını söyleyen ipucu.
  Widget _resultCard() {
    final value = result;
    final (icon, color) = switch (value?.kind) {
      DoorResultKind.success => (AppIcons.checkCircle, AppColors.green),
      DoorResultKind.already => (AppIcons.clock, AppColors.orange),
      DoorResultKind.error => (AppIcons.warning, AppColors.red),
      null => (
        mode == DoorMode.card ? AppIcons.studentCard : AppIcons.qr,
        context.textTertiary,
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(value),
        padding: AppPaddings.settingsTile,
        decoration: BoxDecoration(
          color: context.tileColor,
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        child: Row(
          children: [
            AppIcon(icon, size: AppSizes.iconMedium, color: color),
            const SizedBox(width: AppSizes.bigSpace),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value?.title ??
                        (mode == DoorMode.card
                            ? 'Kartı okut, giriş otomatik alınır'
                            : 'Kişinin SkyPass QR\'ını kameraya tut'),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: value == null ? context.textSecondary : color,
                    ),
                  ),
                  if (value != null && value.detail.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.smallSpace),
                    Text(
                      value.detail,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message({
    required String icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool loading = false,
  }) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            if (loading) ...[
              const SizedBox(height: AppSizes.largeSpace),
              const CircularProgressIndicator.adaptive(),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.largeSpace),
              SkyButton(text: actionLabel, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
