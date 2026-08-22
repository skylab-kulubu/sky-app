import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/profile/data/models/nfc_card.dart';
import 'package:sky_app/features/profile/data/services/nfc_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/skypass_card.dart';

/// NFC öğrenci kartı okutma overlay'i.
///
/// Profil sayfasındaki orijinal [SkyPassCard]'ı boyutunu milimetrik olarak
/// %100 aynı tutarak, [Hero] geçişi sırasında 90 derece döndürür (rotate).
/// Kart merkezde beklerken 2 saniyede bir hafifçe titrer ve haptic vibration
/// geri bildirimi verir. NFC kart algılandığında titreme durur, kart mıknatıs
/// efektiyle yukarı çekilirken işlem tamamlanır ve sonuç ekranda gösterilir.
/// Kullanıcı geri çıkmak isterse (pop / arka plana dokunma) NFC oturumu ve
/// animasyonlar anında güvenli bir şekilde iptal edilir.
class NfcScanOverlay extends StatefulWidget {
  const NfcScanOverlay({
    super.key,
    required this.userName,
    required this.skyNumber,
    required this.subtitle,
    required this.routeAnimation,
  });

  final String userName;
  final String skyNumber;
  final String subtitle;
  final Animation<double> routeAnimation;

  /// Overlay'i saydam bir PageRoute olarak kök navigator üzerinde açar.
  static Future<NfcCard?> show(
    BuildContext context, {
    required String userName,
    required String skyNumber,
    required String subtitle,
  }) {
    return Navigator.of(context, rootNavigator: true).push<NfcCard>(
      PageRouteBuilder<NfcCard>(
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
        ),
      ),
    );
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
  bool _showUid = false;
  bool _isFinished = false;
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
    if (_isFinished || _card != null || _errorMessage != null) return;

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

      // 1. NFC kart algılandığı an titreme hemen durur
      _pulseController.stop();

      // 2. YTÜ Öğrenci Kartı Doğrulaması
      if (!card.isYtuStudentCard) {
        HapticFeedback.heavyImpact();
        await _nfcService.finishSession(iosErrorMessage: 'Geçersiz YTÜ Kartı!');
        if (!mounted || _isFinished) return;
        setState(() {
          _errorMessage = 'Geçersiz YTÜ Kartı';
        });
        _completeAndExit(null);
        return;
      }

      // Başarılı okuma titreşimi
      HapticFeedback.mediumImpact();

      await _nfcService.finishSession(
        iosAlertMessage: 'YTÜ Kartı Başarıyla Okundu!',
      );

      if (!mounted || _isFinished) return;

      // 3. Kart geçerli: Mıknatıs efektiyle yukarı çekilme başlar!
      setState(() {
        _card = card;
      });

      final pullFuture = _pullController.forward();

      // Çekilme devam ederken UID'yi göster
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted || _isFinished) return;
      setState(() {
        _showUid = true;
      });

      // 4. Kart en yukarı geldiğinde işlem tamamlanır
      await pullFuture;

      if (!mounted || _isFinished) return;
      _completeAndExit(card);
    } catch (_) {
      if (!mounted || _isFinished) return;
      await _nfcService.finishSession(iosErrorMessage: 'Okuma başarısız.');
      if (!mounted || _isFinished) return;
      _pulseController.stop();
      setState(() {
        _errorMessage = 'Kart okunamadı';
      });
      _completeAndExit(null);
    }
  }

  Future<void> _completeAndExit(NfcCard? result) async {
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
    if (_isFinished || _card != null || _errorMessage != null) return 0.0;
    final value = _pulseController.value;
    // 2000 ms'nin ilk 400 ms'sinde titrer, kalan 1600 ms durağandır.
    if (value > 0.20) return 0.0;
    final t = value / 0.20; // 0.0 -> 1.0
    final decay = 1.0 - t; // sönümleme
    return sin(t * 6 * pi) * 2.8 * decay;
  }

  /// 2 saniyede bir gerçekleşen hafif mikro açı salınımı (~1 derece).
  double get _vibrationAngle {
    if (_isFinished || _card != null || _errorMessage != null) return 0.0;
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
                      color: Colors.black.withValues(alpha: barrierOpacity),
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
                      padding: const EdgeInsets.only(bottom: 56),
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
    final baseStyle = context.textTheme.bodyMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );

    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        key: ValueKey(_errorMessage),
        textAlign: TextAlign.center,
        style: baseStyle?.copyWith(color: AppColors.red),
      );
    }

    if (_showUid && _card != null) {
      return Text(
        'Kart Eşlendi: ${_card!.formattedHex}',
        key: const ValueKey('success'),
        textAlign: TextAlign.center,
        style: baseStyle?.copyWith(color: AppColors.green),
      );
    }

    return Text(
      'Kartınızı yaklaştırın...',
      key: const ValueKey('scanning'),
      style: baseStyle?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.onAccent.withValues(alpha: 0.9),
      ),
    );
  }
}
