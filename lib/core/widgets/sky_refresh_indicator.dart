import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_colors.dart';

/// Uygulamanın aşağı çekerek yenileme göstergesi; iOS ve Android'de aynı.
///
/// Çekilince AppBar ile içerik arasında açılan boşluğu, etkinlik detayının
/// zemini gibi gökkuşağı parıltıları dolduruyor. Eşik aşılınca lekeler bir
/// nefeste parlayıp yaylanarak yeni yerlerine dağılıyor ve titreşim
/// "bırakabilirsin" diyor; yenileme sürerken rastgele geziniyorlar, iş bitince
/// boşluk kapanıyor.
///
/// İki platformda aynı his için alttaki kaydırılabilirler esnek (bouncing)
/// physics ile çalışıyor: Android'in varsayılanı kenarda duruyor ve hiç
/// taşma üretmiyor. [child] yine `AlwaysScrollableScrollPhysics` taşımalı,
/// yoksa içerik ekranı doldurmadığında çekme başlamıyor.
class SkyRefreshIndicator extends StatefulWidget {
  const SkyRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<SkyRefreshIndicator> createState() => _SkyRefreshIndicatorState();
}

enum _Phase { idle, armed, refreshing }

/// Bir lekenin bu karedeki yeri ve yarıçapı.
typedef _PlacedSpot = ({Alignment center, double radius});

/// Bir parıltının yeri ve hareketi. Gezinme her eksende dönem içinde tam
/// sayı tur atıyor, böylece döngü başa dönerken sıçramıyor.
class _Spot {
  _Spot(this.center, this.radius);

  final Alignment center;
  final double radius;

  int turnsX = 1;
  int turnsY = 1;
  double phaseX = 0;
  double phaseY = 0;
  Offset scatter = Offset.zero;

  /// Her eşikte yeni hedef ve hız: dağılma ve gezinme hep aynı olmasın.
  void shuffle(math.Random random, double scatterAmplitude) {
    turnsX = 1 + random.nextInt(3);
    turnsY = 1 + random.nextInt(3);
    phaseX = random.nextDouble() * 2 * math.pi;
    phaseY = random.nextDouble() * 2 * math.pi;
    scatter = Offset(
      (random.nextDouble() * 2 - 1) * scatterAmplitude,
      (random.nextDouble() * 2 - 1) * scatterAmplitude,
    );
  }
}

class _SkyRefreshIndicatorState extends State<SkyRefreshIndicator>
    with TickerProviderStateMixin {
  /// Bu kadar taşınca bırakmak yenilemeyi başlatıyor. Esnek physics parmağın
  /// yolunu kısalttığı için taşma, parmağın kat ettiği mesafeden az; 110'da
  /// fazla çekmek gerekiyordu.
  static const double _triggerExtent = 80;

  /// Yenileme sürerken içeriğin renk alanına bıraktığı boşluk. Eşikten büyük
  /// olursa içerik bırakıldığı an aşağı sıçrıyor.
  static const double _holdExtent = _triggerExtent;

  /// Lekelerin yerleştiği alanın yüksekliği; görünüm bu boya göre ayarlandı.
  static const double _fieldHeight = 92;

  /// İstek çok hızlı bitse de renklerin gezindiği bir an görünsün.
  static const Duration _minRefreshDuration = Duration(milliseconds: 900);

  static const Duration _bloomDuration = Duration(milliseconds: 550);
  static const Duration _wanderPeriod = Duration(seconds: 6);
  static const Duration _wanderFadeDuration = Duration(milliseconds: 400);
  static const Duration _hideDuration = Duration(milliseconds: 320);

  /// Eşikte lekelerin yerinden en fazla ne kadar kaydığı (Alignment birimi).
  static const double _scatterAmplitude = 0.6;

  /// Eşikteki parlamanın tepesinde lekelerin büyüme oranı.
  static const double _bloomGrowth = 0.45;

  /// Dağılmanın yayı: hedefi biraz aşıp geri oturuyor, sert değil.
  static const SpringDescription _scatterSpring = SpringDescription(
    mass: 1,
    stiffness: 260,
    damping: 12,
  );

  /// Gezinirken lekelerin yerinden en fazla ne kadar uzaklaştığı.
  static const double _wanderAmplitude = 0.6;

  /// Renklerin tepe yoğunluğu; tam doygun marka renkleri neon gibi duruyordu.
  static const double _glowStrength = 0.8;

  /// Yarıçaplar alanın genişliğine göre ve çekerken sabit: alan pencere gibi
  /// açılıyor. Boşluğun yüksekliğine bağlıyken lekeler çektikçe şişip birbirine
  /// fazla biniyor, renkler kahverengimsi bir tona çamurlaşıyordu.
  ///
  /// Yedi orta boy leke iki sıra hâlinde sık dizili: az sayıda leke arada
  /// beyaz boşluk bırakıyordu.
  final List<_Spot> _spots = [
    _Spot(const Alignment(-1.0, -0.3), 0.46),
    _Spot(const Alignment(-0.65, 0.6), 0.42),
    _Spot(const Alignment(-0.3, -0.5), 0.44),
    _Spot(const Alignment(0.05, 0.55), 0.42),
    _Spot(const Alignment(0.35, -0.45), 0.44),
    _Spot(const Alignment(0.7, 0.5), 0.42),
    _Spot(const Alignment(1.0, -0.3), 0.46),
  ];

  final math.Random _random = math.Random();

  /// Lekelerin renkleri; her yeni çekişte karılıyor. Sabit sırada ilk ve
  /// son leke aynı (turkuaz) renge düşüyor, büyük sol leke de hep turkuaz
  /// olduğundan çekişlerin çoğu turkuaz görünüyordu.
  late List<Color> _spotColors = _shuffledColors();

  /// Her renk en az bir kez; artan lekeler rastgele bir renk alıyor.
  List<Color> _shuffledColors() {
    const palette = AppColors.brandGradient;
    final colors = [
      ...palette,
      for (var i = palette.length; i < _spots.length; i++)
        palette[_random.nextInt(palette.length)],
    ];
    return colors..shuffle(_random);
  }

  /// Ekranın üstünden taşma miktarı; çekerken ve geri yaylanırken değişiyor.
  final ValueNotifier<double> _overscroll = ValueNotifier(0);

  /// Dağılmanın ilerlemesi; yay hedefi aşabildiği için sınırsız.
  late final AnimationController _scatter = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _bloom = AnimationController(
    vsync: this,
    duration: _bloomDuration,
  );
  late final AnimationController _wander = AnimationController(
    vsync: this,
    duration: _wanderPeriod,
  );

  /// Gezinmenin ne kadar açık olduğu; lekeler yerinden yumuşakça kopuyor.
  late final AnimationController _wanderIn = AnimationController(
    vsync: this,
    duration: _wanderFadeDuration,
  );

  /// Yenileme boyunca 1; bitince 0'a inip renk alanını kapatıyor.
  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: _hideDuration,
  );

  _Phase _phase = _Phase.idle;

  @override
  void dispose() {
    _overscroll.dispose();
    _scatter.dispose();
    _bloom.dispose();
    _wander.dispose();
    _wanderIn.dispose();
    _presence.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final metrics = notification.metrics;
    final previous = _overscroll.value;
    _overscroll.value = math.max(0, metrics.minScrollExtent - metrics.pixels);

    // Yeni bir çekiş başlıyor; alan henüz görünmezken renkler karılıyor.
    if (_phase == _Phase.idle && previous == 0 && _overscroll.value > 0) {
      _spotColors = _shuffledColors();
    }

    final isDragging =
        notification is ScrollUpdateNotification &&
        notification.dragDetails != null;

    switch (_phase) {
      case _Phase.idle:
        // Yalnız parmakla çekme kurar; yukarı fırlatılan liste tepeye
        // çarpıp taşınca yenilemesin.
        if (isDragging && _overscroll.value >= _triggerExtent) _arm();
      case _Phase.armed:
        if (isDragging && _overscroll.value < _triggerExtent) {
          setState(() => _phase = _Phase.idle);
          _springScatter(0);
        } else if (!isDragging &&
            (notification is ScrollUpdateNotification ||
                notification is ScrollEndNotification)) {
          // Parmak kalktı: liste yaylanarak geri dönüyor.
          unawaited(_refresh());
        }
      case _Phase.refreshing:
        break;
    }
    return false;
  }

  void _arm() {
    for (final spot in _spots) {
      spot.shuffle(_random, _scatterAmplitude);
    }
    setState(() => _phase = _Phase.armed);
    unawaited(HapticFeedback.mediumImpact());
    unawaited(_bloom.forward(from: 0));
    _scatter.value = 0;
    _springScatter(1);
  }

  void _springScatter(double target) {
    unawaited(
      _scatter.animateWith(
        SpringSimulation(
          _scatterSpring,
          _scatter.value,
          target,
          _scatter.velocity,
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _phase = _Phase.refreshing);
    _presence.value = 1;
    unawaited(_wander.repeat());
    unawaited(_wanderIn.forward(from: 0));

    try {
      await Future.wait([
        widget.onRefresh(),
        Future<void>.delayed(_minRefreshDuration),
      ]);
    } finally {
      if (mounted) await _finish();
    }
  }

  Future<void> _finish() async {
    await _presence.animateTo(0, curve: Curves.easeInCubic);
    if (!mounted) return;

    _wander.stop();
    _wanderIn.value = 0;
    _scatter.value = 0;
    setState(() => _phase = _Phase.idle);
  }

  bool get _isHolding => _phase == _Phase.refreshing;

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(
      context,
    ).copyWith(physics: const BouncingScrollPhysics());
    final animation = Listenable.merge([
      _overscroll,
      _scatter,
      _bloom,
      _wander,
      _wanderIn,
      _presence,
    ]);
    final content = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ScrollConfiguration(behavior: behavior, child: widget.child),
    );
    // Renkler her karede yeniden çiziliyor; içerik kendi katmanında kalmazsa
    // yenileme boyunca o da her karede baştan çiziliyordu.

    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final overscroll = _overscroll.value;
          final hold = _isHolding ? _holdExtent * _presence.value : 0.0;
          // Liste geri yaylanırken boşluğu doldurup içeriği renk alanının
          // altında tutuyor; toplam boşluk taşma ile tutma payının büyüğü.
          final shift = math.max(0.0, hold - overscroll);
          final gap = overscroll + shift;

          return Stack(
            children: [
              if (gap > 0) _glow(context, gap),
              Transform.translate(offset: Offset(0, shift), child: child),
            ],
          );
        },
        child: RepaintBoundary(child: content),
      ),
    );
  }

  Widget _glow(BuildContext context, double gap) {
    final progress = _isHolding
        ? _presence.value
        : (_overscroll.value / _triggerExtent).clamp(0.0, 1.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: gap,
      child: CustomPaint(
        painter: _GlowPainter(
          spots: [for (final spot in _spots) _placed(spot)],
          colors: _spotColors,
          fieldHeight: _fieldHeight,
          intensity: _glowStrength * Curves.easeOut.transform(progress),
        ),
      ),
    );
  }

  /// Lekenin bu karedeki yeri ve boyu: eşikteki yaylı dağılma ve parlama ile
  /// yenileme sırasındaki gezinmenin toplamı.
  _PlacedSpot _placed(_Spot spot) {
    var offset = spot.scatter * _scatter.value;

    if (_wanderIn.value > 0) {
      final t = _wander.value * 2 * math.pi;
      offset +=
          Offset(
            math.sin(spot.turnsX * t + spot.phaseX),
            math.sin(spot.turnsY * t + spot.phaseY),
          ) *
          (_wanderAmplitude * Curves.easeInOut.transform(_wanderIn.value));
    }

    // Tek bir nefes: hızla şişip yavaşça iniyor.
    final bloom = _bloom.isAnimating
        ? math.sin(math.pi * Curves.easeOutQuad.transform(_bloom.value)) *
              _bloomGrowth
        : 0.0;

    return (
      center: spot.center + Alignment(offset.dx, offset.dy),
      radius: spot.radius * (1 + bloom),
    );
  }
}

/// Parıltı lekelerini düz saydam bindirmeyle çizer. Çarpma ve ekran kipleri
/// denendi: kesişimler kararıyordu.
class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.spots,
    required this.colors,
    required this.fieldHeight,
    required this.intensity,
  });

  final List<_PlacedSpot> spots;
  final List<Color> colors;

  /// Lekelerin yerleştiği alanın en küçük yüksekliği. Çekmenin başında alan
  /// bundan kısa; lekeler yine bu boyda yerleşip yalnız görünen kısmı çiziliyor.
  final double fieldHeight;
  final double intensity;

  /// Merkez geniş bir düzlük, kenar yavaşça sönüyor (çan eğrisine yakın);
  /// doğrusal geçişte ortada belirgin bir nokta kalıyordu.
  static const List<double> _stops = [0, 0.25, 0.45, 0.65, 0.82, 1];
  static const List<double> _alphas = [1, 0.95, 0.82, 0.58, 0.28, 0];

  /// Tabanın opaklığı; lekelerin altında kalıp yalnız araları dolduruyor.
  static const double _baseAlpha = 0.45;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0 || size.isEmpty) return;

    final rect = Offset.zero & size;
    final field = Rect.fromLTWH(
      0,
      0,
      size.width,
      math.max(size.height, fieldHeight),
    );

    // Lekelerin altında aynı renklerle soluk bir taban: lekeler arasında
    // zeminin (açık temada beyaz) görünmesini engelliyor.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.centerLeft,
          rect.centerRight,
          [
            for (final color in colors)
              color.withValues(alpha: _baseAlpha * intensity),
          ],
          [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)],
        ),
    );

    for (var i = 0; i < spots.length; i++) {
      final spot = spots[i];
      final color = colors[i % colors.length];
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          spot.center.withinRect(field),
          spot.radius * size.width,
          [for (final a in _alphas) color.withValues(alpha: intensity * a)],
          _stops,
        );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => true;
}
