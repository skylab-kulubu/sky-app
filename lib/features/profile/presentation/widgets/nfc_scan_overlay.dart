import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/profile/data/models/nfc_card.dart';
import 'package:sky_app/features/profile/data/services/nfc_service.dart';
import 'package:sky_app/features/profile/data/services/skypass_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/skypass_card.dart';

/// Öğrenci kartını SkyPass'e eşleme overlay'i.
///
/// Profil sayfasındaki [SkyPassCard] [Hero] ile ortaya uçup 90 derece
/// dönüyor ve 2 saniyede bir hafifçe titreyerek kartı bekliyor. Kart
/// okununca UID sunucuya gönderiliyor (`POST /v1/skypass/card-bind`); istek
/// sürerken titreme devam ediyor. Başarılıysa kart mıknatıs gibi yukarı
/// çekiliyor, üstünde YTÜ yıldızı yavaşça beliriyor, profil yenileniyor
/// ([onLinked]) ve kart yıldızıyla birlikte yerine uçuyor. Hata olursa mesaj
/// gösterilip kapanıyor. Geri çıkılırsa NFC oturumu ve animasyonlar
/// güvenle iptal ediliyor. Eşlendiyse `true` döner.
class NfcScanOverlay extends StatefulWidget {
  const NfcScanOverlay({
    super.key,
    required this.userName,
    required this.skyNumber,
    required this.subtitle,
    required this.routeAnimation,
    required this.onLinked,
  });

  final String userName;
  final String skyNumber;
  final String subtitle;
  final Animation<double> routeAnimation;

  /// Eşleme başarılı olunca, kart yerine dönmeden önce bekleniyor (profili
  /// yenilemek için); dönen kart ve profil aynı durumu göstersin.
  final Future<void> Function() onLinked;

  /// Overlay'i saydam bir PageRoute olarak kök navigator üzerinde açar.
  /// Kart eşlendiyse `true`.
  static Future<bool> show(
    BuildContext context, {
    required String userName,
    required String skyNumber,
    required String subtitle,
    required Future<void> Function() onLinked,
  }) async {
    final linked = await Navigator.of(context, rootNavigator: true).push<bool>(
      PageRouteBuilder<bool>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, _) => NfcScanOverlay(
          userName: userName,
          skyNumber: skyNumber,
          subtitle: subtitle,
          routeAnimation: animation,
          onLinked: onLinked,
        ),
      ),
    );
    return linked ?? false;
  }

  @override
  State<NfcScanOverlay> createState() => _NfcScanOverlayState();
}

class _NfcScanOverlayState extends State<NfcScanOverlay>
    with TickerProviderStateMixin {
  /// Kart algılandıktan sonra yukarı mıknatısla çekilme süresi.
  static const Duration _pullDuration = Duration(milliseconds: 900);

  /// 2 saniyede bir hafif titreme döngü süresi.
  static const Duration _pulsePeriod = Duration(milliseconds: 2000);

  /// Sonuç gösterildikten sonra otomatik kapanış bekleme süresi.
  static const Duration _resultDelay = Duration(milliseconds: 1100);

  /// Yıldız belirdikten sonra kart yerine dönmeden önce bekleme; yıldızın
  /// belirişi (SkyPassCard'da ~900 ms) bitsin ve bir an görünsün.
  static const Duration _starHold = Duration(milliseconds: 1500);

  /// Kartın yukarı çekilme oranı (ekran yüksekliğine göre).
  static const double _pullRatio = -0.13;

  /// Arka plan kararma opaklığı.
  static const double _maxBarrierOpacity = 0.88;

  late final AnimationController _pullController;
  late final Animation<double> _pullAnim;
  late final AnimationController _pulseController;

  final NfcService _nfcService = NfcService();

  NfcCard? _card;
  String? _errorMessage;
  bool _isFinished = false;

  /// UID sunucuya gönderiliyor; titreme bu sırada da sürüyor.
  bool _isLinking = false;

  /// Eşleme başarılı; kart yukarı çekildi, yıldız görünüyor.
  bool _isLinked = false;

  /// Kart hâlâ bekleme/eşleme hâlinde mi (titreme ve haptic için).
  bool get _isWaiting => !_isFinished && _errorMessage == null && !_isLinked;
  bool _hasVibratedInCurrentCycle = false;

  @override
  void initState() {
    super.initState();

    // Mıknatıs çekme animasyonu (kart algılandığında tetiklenir)
    _pullController = AnimationController(vsync: this, duration: _pullDuration);

    _pullAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pullController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(vsync: this, duration: _pulsePeriod);

    // Her 2 saniyelik titreme döngüsünün başında hafif haptic vibration ver
    _pulseController.addListener(_handlePulseHaptic);

    // Hero geçişi tamamlandıktan sonra merkezde bekleme ve NFC taramayı başlat
    widget.routeAnimation.addStatusListener(_onRouteAnimationStatus);
  }

  void _handlePulseHaptic() {
    if (!_isWaiting) return;

    if (_pulseController.value < 0.10) {
      if (!_hasVibratedInCurrentCycle) {
        _hasVibratedInCurrentCycle = true;
        HapticFeedback.lightImpact();
      }
    } else {
      _hasVibratedInCurrentCycle = false;
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _startIdleAndScan();
    }
  }

  void _startIdleAndScan() {
    if (_isFinished) return;
    // Kart merkezde bekler ve 2 saniyede bir hafifçe titrer + vibration verir
    _pulseController.repeat();
    _startNfcScan();
  }

  Future<void> _startNfcScan() async {
    try {
      final card = await _nfcService.pollCard(
        timeout: const Duration(seconds: 20),
        iosAlertMessage:
            'Lütfen öğrenci kartınızı telefonun arkasına yaklaştırın...',
        iosMultipleTagMessage: 'Birden fazla kart algılandı!',
      );

      if (!mounted || _isFinished) return;

      // Kimliği çözülemeyen kart (id == "unknown") burada eleniyor.
      if (!card.hasReadableUid) {
        HapticFeedback.heavyImpact();
        await _nfcService.finishSession(iosErrorMessage: 'Kart okunamadı.');
        if (!mounted || _isFinished) return;
        _fail('Kart okunamadı');
        return;
      }

      HapticFeedback.mediumImpact();
      await _nfcService.finishSession(iosAlertMessage: 'Kart okundu');
      if (!mounted || _isFinished) return;

      // Sunucuya gönderilirken kart titremeye devam ediyor.
      setState(() {
        _card = card;
        _isLinking = true;
      });

      try {
        await SkyPassService.bindCard(card.normalizedHex);
      } catch (e) {
        final error = ApiException.from(e);
        log('Öğrenci kartı eşlenemedi: $error');
        if (!mounted || _isFinished) return;
        HapticFeedback.heavyImpact();
        _fail(switch (error.statusCode) {
          409 => 'Bu kart başka bir hesaba eşli',
          400 => 'Kart numarası okunamadı',
          _ => error.userMessage,
        });
        return;
      }
      if (!mounted || _isFinished) return;

      // Başarılı: titreme durur, kart yukarı çekilir, yıldız belirir.
      _pulseController.stop();
      HapticFeedback.heavyImpact();
      setState(() {
        _isLinking = false;
        _isLinked = true;
      });
      await _pullController.forward();
      if (!mounted || _isFinished) return;

      // Profil yıldızın belirmesiyle aynı anda yenileniyor; kart döndüğünde
      // profildeki kart da yıldızlı olsun.
      await Future.wait([
        widget.onLinked().catchError(
          (Object e) => log('Profil yenilenemedi: $e'),
        ),
        Future<void>.delayed(_starHold),
      ]);
      if (!mounted || _isFinished) return;
      _isFinished = true;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted || _isFinished) return;
      await _nfcService.finishSession(iosErrorMessage: 'Okuma başarısız.');
      if (!mounted || _isFinished) return;
      _fail('Kart okunamadı');
    }
  }

  /// Hata mesajını gösterip bir süre sonra kapanır (eşlenmedi).
  void _fail(String message) {
    _pulseController.stop();
    setState(() {
      _isLinking = false;
      _errorMessage = message;
    });
    _completeAndExit(false);
  }

  Future<void> _completeAndExit(bool result) async {
    if (_isFinished) return;
    _isFinished = true;

    _pulseController.stop();

    await Future.delayed(_resultDelay);
    if (!mounted) return;

    // Geri dönerken Hero animasyonu kartı 90 dereceden 0'a çevirerek
    // profil sayfasındaki orijinal yerine geri uçurur
    Navigator.of(context).pop(result);
  }

  /// Kullanıcı geriye çıkmak istediğinde işlemi iptal eder ve temizlik yapar.
  void _cancelAndCleanup() {
    _isFinished = true;
    _pulseController.stop();
    if (_pullController.isAnimating) {
      _pullController.stop();
    }
    // Arka planda NFC donanım oturumunu kapat
    _nfcService.finishSession().catchError((_) {});
  }

  @override
  void dispose() {
    _cancelAndCleanup();
    widget.routeAnimation.removeStatusListener(_onRouteAnimationStatus);
    _pulseController.removeListener(_handlePulseHaptic);
    _pullController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// 2 saniyede bir gerçekleşen hafif mikro yatay titreme değeri.
  double get _vibrationOffset {
    if (!_isWaiting) return 0.0;
    final value = _pulseController.value;
    // 2000 ms'nin ilk 400 ms'sinde titrer, kalan 1600 ms durağandır.
    if (value > 0.20) return 0.0;
    final t = value / 0.20; // 0.0 -> 1.0
    final decay = 1.0 - t; // sönümleme
    return sin(t * 6 * pi) * 2.8 * decay;
  }

  /// 2 saniyede bir gerçekleşen hafif mikro açı salınımı (~1 derece).
  double get _vibrationAngle {
    if (!_isWaiting) return 0.0;
    final value = _pulseController.value;
    if (value > 0.20) return 0.0;
    final t = value / 0.20;
    final decay = 1.0 - t;
    return sin(t * 6 * pi) * 0.016 * decay;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenHeight = screenSize.height;
    final pullOffset = screenHeight * _pullRatio;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _cancelAndCleanup();
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.routeAnimation,
            _pullController,
            _pulseController,
          ]),
          builder: (context, _) {
            final barrierOpacity =
                (_maxBarrierOpacity * widget.routeAnimation.value).clamp(
                  0.0,
                  _maxBarrierOpacity,
                );

            return Stack(
              children: [
                // Arka plan kararması (dokunulduğunda da iptal edip çıkış yapar)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (!_isFinished) {
                        _cancelAndCleanup();
                        Navigator.of(context).pop();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: ColoredBox(
                      color: AppColors.scrim.withValues(alpha: barrierOpacity),
                    ),
                  ),
                ),
                // 90 derece dönmüş kart: Merkezde bekler, algılanınca yukarı çekilir
                Center(
                  child: Transform.translate(
                    offset: Offset(
                      _vibrationOffset,
                      (pullOffset * _pullAnim.value),
                    ),
                    child: Padding(
                      padding: AppPaddings.mainPaddingAll,
                      child: _heroRotatedCard(_vibrationAngle),
                    ),
                  ),
                ),
                // Ekranın alt kısmında sabit duran yalın durum metni
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: AppPaddings.nfcStatus,
                      child: Opacity(
                        opacity: widget.routeAnimation.value.clamp(0.0, 1.0),
                        child: _statusIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Profil sayfasındakiyle aynı bounding box boyutuna sahip, 90 derece dönen Hero kartı.
  Widget _heroRotatedCard(double vibrationAngle) {
    return Hero(
      tag: 'skypass_card_hero',
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      flightShuttleBuilder:
          (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                // Push (0.0 -> 1.0): 0'dan 90 dereceye (pi / 2) döner
                // Pop (1.0 -> 0.0): 90 dereceden (pi / 2) 0'a geri döner
                final angle = animation.value * (pi / 2);

                return Material(
                  type: MaterialType.transparency,
                  child: Transform.rotate(
                    angle: angle,
                    child: SkyPassCard(
                      name: widget.userName,
                      skyNumber: widget.skyNumber,
                      subtitle: widget.subtitle,
                      showStudentCardMark: _isLinked,
                    ),
                  ),
                );
              },
            );
          },
      child: Material(
        type: MaterialType.transparency,
        child: Transform.rotate(
          angle: (pi / 2) + vibrationAngle,
          child: SkyPassCard(
            name: widget.userName,
            skyNumber: widget.skyNumber,
            subtitle: widget.subtitle,
            showStudentCardMark: _isLinked,
          ),
        ),
      ),
    );
  }

  /// Yalın durum ve bilgilendirme metni (badge/kutu içermez).
  Widget _statusIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildStatusContent(),
    );
  }

  Widget _buildStatusContent() {
    final baseStyle = context.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        key: ValueKey(_errorMessage),
        textAlign: TextAlign.center,
        style: baseStyle?.copyWith(color: AppColors.red),
      );
    }

    if (_isLinked) {
      return Text(
        'Öğrenci kartın SkyPass\'e eşlendi',
        key: const ValueKey('linked'),
        textAlign: TextAlign.center,
        style: baseStyle?.copyWith(color: AppColors.green),
      );
    }

    if (_isLinking && _card != null) {
      return Text(
        'Kart eşleniyor…',
        key: const ValueKey('linking'),
        textAlign: TextAlign.center,
        style: baseStyle?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.onScrim,
        ),
      );
    }

    return Text(
      'Kartınızı yaklaştırın...',
      key: const ValueKey('scanning'),
      style: baseStyle?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.onScrim,
      ),
    );
  }
}
