import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/theme/theme.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/data/services/attendance_service.dart';
import 'package:sky_app/features/calendar/presentation/widgets/scan_message.dart';
import 'package:sky_app/features/calendar/presentation/widgets/scan_result_card.dart';
import 'package:sky_app/features/profile/presentation/providers/activity_provider.dart';

part 'session_check_in_pagemodel.dart';

/// Katılımcının oturum QR'ını (perdede gösterilen) okutup kendi yoklamasını
/// vermesi: `POST /v1/sessions/{id}/check-in/me`. Sertifika bu girişlere
/// göre hesaplanıyor.
class SessionCheckInPage extends StatefulWidget {
  const SessionCheckInPage({super.key});

  /// Tam ekran açar (navbar'ın altında kalmasın diye kök navigator'da).
  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => const SessionCheckInPage()));
  }

  @override
  State<SessionCheckInPage> createState() => _SessionCheckInPageState();
}

class _SessionCheckInPageState extends SessionCheckInPagemodel {
  /// Okutma çerçevesinin ekran genişliğine oranı.
  static const double _frameWidthFactor = 0.7;
  static const double _frameStroke = 3;

  /// Başlığın kamera görüntüsünün üstünde okunması için üstteki karartma.
  static const double _topScrimHeight = 160;

  @override
  Widget build(BuildContext context) {
    // Kamera ekranı iki temada da koyu; açık temada koyu başlık görüntünün
    // üstünde okunmuyordu.
    return Theme(
      data: darkTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('QR Okut'),
          leading: IconButton(
            icon: const AppIcon(AppIcons.arrowBack),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: scanner,
              onDetect: onDetect,
              errorBuilder: (context, error) => ColoredBox(
                color: context.backgroundColor,
                child: ScanMessage(
                  icon: AppIcons.camera,
                  title: 'Kamera Açılamadı',
                  message:
                      error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'QR okutmak için ayarlardan kameraya izin ver.'
                      : 'Kamera başlatılamadı. Sayfayı kapatıp yeniden aç.',
                ),
              ),
            ),
            _topScrim(),
            IgnorePointer(child: Center(child: _frame())),
            if (isBusy)
              const ColoredBox(
                color: Colors.black38,
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: AppPaddings.mainPaddingAll,
                  child: ScanResultCard(
                    result: result,
                    hintIcon: AppIcons.qr,
                    hint: 'Oturum QR\'ını çerçeveye tut',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topScrim() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: IgnorePointer(
        child: Container(
          height: _topScrimHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  /// QR'ın nereye tutulacağını gösteren çerçeve; okuma yine tüm görüntüde.
  Widget _frame() {
    return FractionallySizedBox(
      widthFactor: _frameWidthFactor,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadiuses.cardBorderRadius,
            border: Border.all(color: AppColors.onScrim, width: _frameStroke),
          ),
        ),
      ),
    );
  }
}
