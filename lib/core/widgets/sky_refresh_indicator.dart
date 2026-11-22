import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_colors.dart';

/// Aşağı çekerek yenileme; çekilince içeriğin üstünde açılan boşluğu
/// gökkuşağı parıltıları dolduruyor.
///
/// Her platform kendi kaydırma fiziğinde kalıyor: iOS'ta çekme mesafesi
/// listenin taşması, Android'de liste tepede durduğu için taşma
/// bildirimlerinden sayılıyor (Flutter'ın `RefreshIndicator`'ı gibi).
///
/// [child] `AlwaysScrollableScrollPhysics` taşımalı, yoksa içerik ekranı
/// doldurmadığında çekme başlamıyor.
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

typedef _PlacedSpot = ({Alignment center, double radius});

/// Gezinme her eksende dönem içinde tam sayı tur atıyor ki döngü başa
/// dönerken sıçramasın.
class _Spot {
  _Spot(this.center, this.radius);

  final Alignment center;
  final double radius;

  int turnsX = 1;
  int turnsY = 1;
  double phaseX = 0;
  double phaseY = 0;
  Offset scatter = Offset.zero;

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
  /// Dirençten dolayı parmağın yolu bundan uzun.
  static const double _triggerExtent = 80;

  /// Eşikten büyük olamaz: içerik bırakıldığı an aşağı sıçrar.
  static const double _holdExtent = _triggerExtent;

  static const double _fieldHeight = 92;

  /// İstek çok hızlı bitse de renklerin gezindiği bir an görünsün.
  static const Duration _minRefreshDuration = Duration(milliseconds: 900);

  static const Duration _bloomDuration = Duration(milliseconds: 550);
  static const Duration _wanderPeriod = Duration(seconds: 6);
  static const Duration _wanderFadeDuration = Duration(milliseconds: 400);
  static const Duration _hideDuration = Duration(milliseconds: 320);
  static const Duration _retractDuration = Duration(milliseconds: 300);

  /// `BouncingScrollPhysics`'in katsayısı; Android'de iOS'la aynı ağırlık.
  static const double _pullFriction = 0.52;

  static const double _scatterAmplitude = 0.6;

  static const double _bloomGrowth = 0.45;

  static const SpringDescription _scatterSpring = SpringDescription(
    mass: 1,
    stiffness: 260,
    damping: 12,
  );

  static const double _wanderAmplitude = 0.6;

  static const double _glowStrength = 0.8;

  /// Yarıçaplar genişliğe göre ve çekerken sabit: boşluğa bağlı olsalar
  /// lekeler şişip üst üste biner, renkler kahverengiye çamurlaşır.
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

  /// Her çekişte karılıyor; sabit sırada hep aynı renk baskın kalıyor.
  late List<Color> _spotColors = _shuffledColors();

  List<Color> _shuffledColors() {
    const palette = AppColors.brandGradient;
    final colors = [
      ...palette,
      for (var i = palette.length; i < _spots.length; i++)
        palette[_random.nextInt(palette.length)],
    ];
    return colors..shuffle(_random);
  }

  final ValueNotifier<double> _overscroll = ValueNotifier(0);

  late final AnimationController _pull = AnimationController.unbounded(
    vsync: this,
  );

  /// iOS'ta [_overscroll], Android'de [_pull] çalışıyor; diğeri hep sıfır.
  double get _pullExtent => _overscroll.value + _pull.value;

  /// Yay hedefi aşabildiği için sınırsız.
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

  late final AnimationController _wanderIn = AnimationController(
    vsync: this,
    duration: _wanderFadeDuration,
  );

  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: _hideDuration,
  );

  _Phase _phase = _Phase.idle;

  /// Yalnız liste tepede dururken başlayan çekme sayılıyor. Tepeye fırlayıp
  /// esneyen listeyi yakalamak, esneme zaten taştığı için azıcık çekmeyle
  /// eşiği aşardı.
  bool _pullStarted = false;

  @override
  void dispose() {
    _overscroll.dispose();
    _pull.dispose();
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
    final previous = _pullExtent;
    _overscroll.value = math.max(0, metrics.minScrollExtent - metrics.pixels);

    if (notification is ScrollStartNotification) {
      final atRest = (metrics.pixels - metrics.minScrollExtent).abs() < 1;
      _pullStarted = notification.dragDetails != null && atRest;
    }

    final isDragging = switch (notification) {
      ScrollUpdateNotification(:final dragDetails) => dragDetails != null,
      OverscrollNotification(:final dragDetails) => dragDetails != null,
      _ => false,
    };

    if (_pullStarted) _trackPull(notification, isDragging);

    if (_phase == _Phase.idle && previous == 0 && _pullExtent > 0) {
      _spotColors = _shuffledColors();
    }

    switch (_phase) {
      case _Phase.idle:
        if (isDragging && _pullStarted && _pullExtent >= _triggerExtent) {
          _arm();
        }
      case _Phase.armed:
        if (isDragging && _pullExtent < _triggerExtent) {
          setState(() => _phase = _Phase.idle);
          _springScatter(0);
        } else if (!isDragging &&
            (notification is ScrollUpdateNotification ||
                notification is OverscrollNotification ||
                notification is ScrollEndNotification)) {
          unawaited(_refresh());
        }
      case _Phase.refreshing:
        break;
    }
    return false;
  }

  /// Yalnız Android: iOS'ta liste kendisi taştığı için taşma bildirimi gelmiyor.
  void _trackPull(ScrollNotification notification, bool isDragging) {
    if (notification is OverscrollNotification &&
        isDragging &&
        notification.overscroll < 0) {
      final fraction = _pull.value / notification.metrics.viewportDimension;
      final resistance = _pullFriction * math.pow(1 - fraction, 2);
      _pull.value += -notification.overscroll * resistance;
      return;
    }

    if (_pull.value == 0) return;

    if (notification is ScrollUpdateNotification && isDragging) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 0) _pull.value = math.max(0, _pull.value - delta);
      return;
    }

    if (!isDragging) {
      unawaited(
        _pull.animateTo(
          0,
          duration: _retractDuration,
          curve: Curves.easeOutCubic,
        ),
      );
    }
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
    final animation = Listenable.merge([
      _overscroll,
      _pull,
      _scatter,
      _bloom,
      _wander,
      _wanderIn,
      _presence,
    ]);
    final content = NotificationListener<OverscrollIndicatorNotification>(
      // Android'in kenar esnemesi renk alanıyla çakışmasın.
      onNotification: (notification) {
        if (notification.leading && _pullStarted) {
          notification.disallowIndicator();
        }
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      ),
    );

    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final overscroll = _overscroll.value;
          final hold = _isHolding ? _holdExtent * _presence.value : 0.0;
          // Yenilerken liste geri yaylanırsa boşluğu tutma payı dolduruyor.
          final shift = math.max(_pull.value, hold - overscroll);
          final gap = overscroll + math.max(0.0, shift);

          // Gevşek kısıtta SingleChildScrollView içeriği kadar küçülüp
          // altındaki boşluktan çekilemez.
          return Stack(
            fit: StackFit.expand,
            children: [
              if (gap > 0 && (_pullStarted || _isHolding)) _glow(context, gap),
              Transform.translate(offset: Offset(0, shift), child: child),
            ],
          );
        },
        // Renkler her karede çiziliyor; içerik kendi katmanında kalsın.
        child: RepaintBoundary(child: content),
      ),
    );
  }

  Widget _glow(BuildContext context, double gap) {
    final progress = _isHolding
        ? _presence.value
        : (_pullExtent / _triggerExtent).clamp(0.0, 1.0);

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

/// Düz saydam bindirme: çarpma ve ekran kiplerinde kesişimler kararıyor.
class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.spots,
    required this.colors,
    required this.fieldHeight,
    required this.intensity,
  });

  final List<_PlacedSpot> spots;
  final List<Color> colors;

  /// Alan bundan kısayken de lekeler bu boya göre yerleşiyor; çekerken
  /// yerlerinden kaymıyorlar.
  final double fieldHeight;
  final double intensity;

  /// Çan eğrisine yakın sönüş; doğrusal geçişte merkezde nokta belli oluyor.
  static const List<double> _stops = [0, 0.25, 0.45, 0.65, 0.82, 1];
  static const List<double> _alphas = [1, 0.95, 0.82, 0.58, 0.28, 0];

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

    // Soluk taban lekelerin arasında zeminin görünmesini engelliyor.
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
