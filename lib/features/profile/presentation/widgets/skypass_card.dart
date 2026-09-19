import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/profile/data/models/skypass_token.dart';
import 'package:sky_app/features/profile/data/services/skypass_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/tilt_builder.dart';

/// [SkyPassCard]'ı karta dokunmadan çevirmek için.
///
/// Kart kendi animasyonunu yönettiği için dönüş durumu burada tutulmuyor;
/// controller yalnızca "çevir" isteğini karta iletiyor.
///
/// Tek değil birden çok kart bağlanabiliyor: profildeki kart [Hero] içinde ve
/// uçuş sırasında aynı widget'tan geçici bir kopya kuruluyor. Tek bağlantı
/// olsaydı kopya asıl kartın yerini alır, uçuş bitip kopya kalkınca buton
/// hiçbir kartı çeviremez hâle gelirdi.
class SkyPassCardController {
  final Set<VoidCallback> _flipCallbacks = {};

  /// Kartı öbür yüzüne çevirir; dönüş sürerken çağrı yok sayılır.
  void flip() {
    for (final callback in _flipCallbacks.toList()) {
      callback();
    }
  }

  void _attach(VoidCallback onFlip) => _flipCallbacks.add(onFlip);

  void _detach(VoidCallback onFlip) => _flipCallbacks.remove(onFlip);
}

/// Kulüp üyelik kartı. Banka kartı oranında (85.6 × 53.98 mm) çizilir.
///
/// İki yüzü var: ön yüzde kimlik bilgileri, arkasında üyelik QR'ı. Karta
/// dokunulunca Y ekseninde dönerek diğer yüze geçer; [controller] verilirse
/// kart dışarıdan da çevrilebilir (profildeki "QR'ı Göster").
class SkyPassCard extends StatefulWidget {
  const SkyPassCard({
    super.key,
    required this.name,
    required this.skyNumber,
    required this.subtitle,
    this.controller,
  });

  final SkyPassCardController? controller;

  final String name;
  final String skyNumber;

  /// Bölüm ya da ekip bilgisi; boşsa satır çizilmez.
  final String subtitle;

  @override
  State<SkyPassCard> createState() => _SkyPassCardState();
}

class _SkyPassCardState extends State<SkyPassCard>
    with SingleTickerProviderStateMixin {
  static const double _cardAspectRatio = 1.586;

  static const Duration _flipDuration = Duration(milliseconds: 520);

  /// Dönüşe derinlik veren perspektif katsayısı. Bunsuz kart düz bir
  /// dikdörtgen gibi yassılıp genişler, kâğıt dönme hissi oluşmaz. Yükseldikçe
  /// yakın kenar hızla büyüyor ve kart altındaki içeriğin üstüne taşıyor.
  static const double _perspective = 0.0008;

  /// Dönüşün ortasında karta uygulanan küçülme. Perspektif yakın kenarı
  /// büyüttüğü için kart tam yandayken kutusundan taşıyordu; bu onu dengeliyor.
  static const double _flipShrink = 0.08;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _flipDuration,
  );

  late final Animation<double> _turn = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_flip);
  }

  @override
  void didUpdateWidget(SkyPassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?._detach(_flip);
    widget.controller?._attach(_flip);
  }

  @override
  void dispose() {
    widget.controller?._detach(_flip);
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AspectRatio(
        aspectRatio: _cardAspectRatio,
        // Eğim ile çevirme tek matriste birleşiyor. İki ayrı Transform iç içe
        // geçtiğinde perspektif katsayıları çarpılıyor ve kart dönerken
        // katlanarak büyüyordu.
        child: TiltBuilder(
          builder: (context, tilt) => AnimatedBuilder(
            animation: _turn,
            builder: (context, _) {
              final angle = _turn.value * pi;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, _perspective)
                  // Derinlik (z) ölçeklenmiyor; yalnızca ekrandaki boyut
                  // küçülüyor, perspektifin kendisi olduğu gibi kalıyor.
                  ..scaleByDouble(_scaleAt(angle), _scaleAt(angle), 1, 1)
                  // Eğimin öne/arkaya bileşeni dönüşten sonra, ekran
                  // düzleminde uygulanıyor; yoksa kart arka yüzdeyken
                  // yukarı-aşağı ters tepki verirdi.
                  ..rotateX(tilt.dy)
                  ..rotateY(angle + tilt.dx),
                child: angle < pi / 2 ? _front() : _mirrored(_back()),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Kart tam yandayken (π/2) en çok küçülür, iki uçta 1'e döner.
  double _scaleAt(double angle) => 1 - sin(angle) * _flipShrink;

  /// Arka yüz, dönen kartın ters tarafında çizildiği için kendi içinde bir kez
  /// daha çevrilir; yoksa ayna görüntüsü olarak görünür.
  Widget _mirrored(Widget child) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: child,
    );
  }

  /// İki yüzün ortak zemini: gradyan ve yuvarlak köşeler.
  Widget _surface({required Widget child}) {
    return Container(
      padding: AppPaddings.skyPassCard,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.skyPassGradientStart,
            AppColors.skyPassGradientEnd,
          ],
        ),
        borderRadius: AppRadiuses.skyPassCardBorderRadius,
      ),
      child: child,
    );
  }

  Widget _front() {
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_header(), const Spacer(), _footer()],
      ),
    );
  }

  Widget _back() {
    return _surface(
      // stretch olmadan QR kendi içerik boyutuna düşer; kartın yüksekliğini
      // kaplaması gerekiyor ki kare oranı yükseklikten hesaplansın.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            // Kod dönüş bitince çiziliyor: yoğun QR'ı dönüş sırasında
            // kurmak animasyonu takıyordu.
            child: SkyPassQr(
              owner: widget.skyNumber,
              active: _controller.status == AnimationStatus.completed,
            ),
          ),
          const SizedBox(width: AppSizes.bigSpace),
          Expanded(child: _backDetails()),
        ],
      ),
    );
  }

  Widget _backDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.name.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _nameStyle,
        ),
        if (widget.skyNumber.isNotEmpty) ...[
          const SizedBox(height: AppSizes.smallSpace),
          Text(widget.skyNumber, style: _mutedStyle),
        ],
        const SizedBox(height: AppSizes.bigSpace),
        Text(
          'Girişte bu kodu okut. Kod her dakika yenilenir.',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: _mutedStyle,
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            'SkyPass',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.skyPassForeground,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SvgPicture.asset(
          AppAssets.skylab,
          width: AppSizes.iconLarge,
          height: AppSizes.iconLarge,
          // Logo beyaz monokrom; kartın koyu metin rengine boyanıyor.
          colorFilter: const ColorFilter.mode(
            AppColors.skyPassForeground,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            AppIcon(
              AppIcons.nfc,
              size: AppSizes.iconMedium,
              color: AppColors.skyPassForegroundMuted,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.bigSpace),
        Text(
          widget.name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _nameStyle,
        ),
        const SizedBox(height: AppSizes.smallSpace),
        Row(
          children: [
            if (widget.skyNumber.isNotEmpty) ...[
              Text(widget.skyNumber, style: _mutedStyle),
              if (widget.subtitle.isNotEmpty) Text('  •  ', style: _mutedStyle),
            ],
            if (widget.subtitle.isNotEmpty)
              Expanded(
                child: Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _mutedStyle,
                ),
              ),
          ],
        ),
      ],
    );
  }

  TextStyle get _nameStyle => const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.skyPassForeground,
    letterSpacing: 0.8,
  );

  TextStyle get _mutedStyle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.skyPassForegroundMuted,
    letterSpacing: 0.5,
  );
}

/// SkyPass'in arka yüzündeki kapı kodu.
///
/// Core'un imzaladığı kısa ömürlü belirteci ([SkyPassService.token]) QR
/// olarak çiziyor ve süresi dolmadan yeniliyor. Kod arka yüz göründüğü anda
/// istenmeye başlıyor ama QR ancak [active] olunca (kartın dönüşü bitince)
/// kurulup yumuşakça beliriyor; o zamana kadar yükleniyor göstergesi var.
/// Kart ön yüze dönünce widget kalkıyor, zamanlayıcı da duruyor. Kod
/// alınamazsa (bağlantı yok) dokununca yeniden deneniyor.
class SkyPassQr extends StatefulWidget {
  const SkyPassQr({super.key, required this.owner, required this.active});

  /// Kartın sahibi (SKY numarası); önbellekteki kodun başkasına ait
  /// olmadığını anlamak için.
  final String owner;

  /// Kart yüzü tam görünüyor mu; değilse QR çizilmiyor.
  final bool active;

  @override
  State<SkyPassQr> createState() => _SkyPassQrState();
}

class _SkyPassQrState extends State<SkyPassQr> {
  /// Zamanlayıcı en az bu kadar bekliyor; cihaz saati sunucudan gerideyse
  /// art arda istek atılmasın.
  static const Duration _minRefreshDelay = Duration(seconds: 5);

  static const Duration _fadeDuration = Duration(milliseconds: 250);

  SkyPassToken? _token;

  /// Çizime hazır QR; token ve [SkyPassQr.active] ikisi de varken kuruluyor.
  QrImage? _qr;
  String? _qrValue;

  bool _failed = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SkyPassQr oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _prepareQr();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    _refreshTimer?.cancel();
    try {
      final token = await SkyPassService.token(owner: widget.owner);
      if (!mounted) return;
      setState(() {
        _token = token;
        _failed = false;
      });
      _scheduleRefresh(token);
      _prepareQr();
    } catch (e) {
      log('SkyPass kodu alınamadı: $e');
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  /// QR matrisini bir sonraki karede kurar; dönüş ya da açılış karesine
  /// denk gelmesin.
  void _prepareQr() {
    final token = _token;
    if (!widget.active || token == null || token.value == _qrValue) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) return;
      final qr = QrImage(
        QrCode.fromData(
          data: token.value,
          errorCorrectLevel: QrErrorCorrectLevel.L,
        ),
      );
      setState(() {
        _qr = qr;
        _qrValue = token.value;
      });
    });
  }

  void _scheduleRefresh(SkyPassToken token) {
    var delay = token.expiresAt
        .subtract(SkyPassService.refreshMargin)
        .difference(DateTime.now());
    if (delay < _minRefreshDelay) delay = _minRefreshDelay;
    _refreshTimer = Timer(delay, _load);
  }

  void _retry() {
    setState(() => _failed = false);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final qr = widget.active ? _qr : null;

    final Widget child;
    if (_failed && qr == null) {
      child = _error();
    } else if (qr == null) {
      child = Center(
        key: const ValueKey('loading'),
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(AppColors.skyPassForegroundMuted),
        ),
      );
    } else {
      child = PrettyQrView(
        key: ValueKey(_qrValue),
        qrImage: qr,
        decoration: const PrettyQrDecoration(
          shape: PrettyQrSmoothSymbol(color: AppColors.skyPassForeground),
        ),
      );
    }

    return Container(
      padding: AppPaddings.skyPassQr,
      decoration: BoxDecoration(
        color: AppColors.onAccent,
        borderRadius: BorderRadius.circular(AppRadiuses.innerTile),
      ),
      child: AnimatedSwitcher(duration: _fadeDuration, child: child),
    );
  }

  /// Kartın kendi dokunuşu (çevirme) burada yeniden denemeye dönüşüyor.
  Widget _error() {
    return GestureDetector(
      key: const ValueKey('error'),
      onTap: _retry,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            AppIcons.refresh,
            size: AppSizes.iconMedium,
            color: AppColors.skyPassForegroundMuted,
          ),
          const SizedBox(height: AppSizes.smallSpace),
          Text(
            'Kod alınamadı',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.skyPassForegroundMuted,
            ),
          ),
        ],
      ),
    );
  }
}
