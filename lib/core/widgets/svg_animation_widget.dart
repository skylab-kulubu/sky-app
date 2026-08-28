import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 1. SVG Parser
// ═══════════════════════════════════════════════════════════════════════════════

final RegExp _tokenRegex = RegExp(
  r'([MmLlCcHhVvZz])|(-?\d*\.?\d+(?:e[-+]?\d+)?)',
);

bool _isCommand(String token) {
  return token.length == 1 && 'MmLlCcHhVvZz'.contains(token);
}

double _readNumber(List<String> tokens, int index) {
  return double.parse(tokens[index]);
}

/// SVG `d` attribute string'ini Flutter Path objesine çevirir.
/// Desteklenen komutlar: M/m, L/l, C/c, H/h, V/v, Z/z.
/// Fill type evenodd olarak set edilir.
ui.Path parseSvgPath(String d) {
  final path = ui.Path();
  final tokens = _tokenRegex
      .allMatches(d)
      .map((match) => match.group(0)!)
      .toList();

  String? cmd;
  double cx = 0;
  double cy = 0;
  var index = 0;

  while (index < tokens.length) {
    final token = tokens[index];

    if (_isCommand(token)) {
      cmd = token;
      index++;

      if (cmd == 'Z' || cmd == 'z') {
        path.close();
        continue;
      }
    } else if (cmd == null) {
      index++;
      continue;
    }

    final upper = cmd.toUpperCase();
    final relative = cmd != upper;

    if (upper == 'M') {
      final x = _readNumber(tokens, index);
      final y = _readNumber(tokens, index + 1);
      index += 2;

      final absX = relative ? cx + x : x;
      final absY = relative ? cy + y : y;
      path.moveTo(absX, absY);
      cx = absX;
      cy = absY;

      cmd = relative ? 'l' : 'L';
      continue;
    }

    if (upper == 'L') {
      final x = _readNumber(tokens, index);
      final y = _readNumber(tokens, index + 1);
      index += 2;

      final absX = relative ? cx + x : x;
      final absY = relative ? cy + y : y;
      path.lineTo(absX, absY);
      cx = absX;
      cy = absY;
    } else if (upper == 'H') {
      final x = _readNumber(tokens, index);
      index += 1;

      final absX = relative ? cx + x : x;
      path.lineTo(absX, cy);
      cx = absX;
    } else if (upper == 'V') {
      final y = _readNumber(tokens, index);
      index += 1;

      final absY = relative ? cy + y : y;
      path.lineTo(cx, absY);
      cy = absY;
    } else if (upper == 'C') {
      final x1 = _readNumber(tokens, index);
      final y1 = _readNumber(tokens, index + 1);
      final x2 = _readNumber(tokens, index + 2);
      final y2 = _readNumber(tokens, index + 3);
      final x = _readNumber(tokens, index + 4);
      final y = _readNumber(tokens, index + 5);
      index += 6;

      final absX1 = relative ? cx + x1 : x1;
      final absY1 = relative ? cy + y1 : y1;
      final absX2 = relative ? cx + x2 : x2;
      final absY2 = relative ? cy + y2 : y2;
      final absX = relative ? cx + x : x;
      final absY = relative ? cy + y : y;

      path.cubicTo(absX1, absY1, absX2, absY2, absX, absY);
      cx = absX;
      cy = absY;
    } else {
      index++;
    }
  }

  path.fillType = ui.PathFillType.evenOdd;
  return path;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. ParsedSvgPath & SvgPathLibrary
// ═══════════════════════════════════════════════════════════════════════════════

/// Parse edilmiş bir SVG path. Hem ui.Path hem de PathMetric listesi cache'li.
class ParsedSvgPath {
  ParsedSvgPath._({
    required this.key,
    required this.path,
    required this.metrics,
  });

  factory ParsedSvgPath.fromSvgData(String key, String d) {
    final path = parseSvgPath(d);
    return ParsedSvgPath._(
      key: key,
      path: path,
      metrics: path.computeMetrics().toList(growable: false),
    );
  }

  final String key;
  final ui.Path path;
  final List<ui.PathMetric> metrics;

  /// Cached total length (her metric'in length'inin toplamı).
  late final double totalLength = metrics.fold(0.0, (sum, m) => sum + m.length);
}

/// Bir SVG'nin tüm path'lerini ve viewBox bilgisini taşıyan container.
class SvgPathLibrary {
  SvgPathLibrary({
    required this.viewBoxWidth,
    required this.viewBoxHeight,
    required Map<String, String> rawPaths,
  }) : paths = List<ParsedSvgPath>.unmodifiable(
         rawPaths.entries
             .map((e) => ParsedSvgPath.fromSvgData(e.key, e.value))
             .toList(growable: false),
       );

  final double viewBoxWidth;
  final double viewBoxHeight;
  final List<ParsedSvgPath> paths;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. Animation primitives
// ═══════════════════════════════════════════════════════════════════════════════

/// Eased progress in [0, 1] for a time window.
double timeWindow(double t, double start, double duration, Curve curve) {
  if (duration <= 0) {
    return t >= start ? 1.0 : 0.0;
  }
  final raw = ((t - start) / duration).clamp(0.0, 1.0);
  return curve.transform(raw);
}

/// Keyframe interpolation (Framer Motion'daki `times` + `values` davranışı).
double interpolateKeyframes({
  required double t,
  required List<double> times,
  required List<double> values,
  Curve curve = Curves.easeInOut,
}) {
  assert(times.length == values.length);
  assert(times.length >= 2);

  if (t <= times.first) {
    return values.first;
  }
  if (t >= times.last) {
    return values.last;
  }

  for (var i = 0; i < times.length - 1; i++) {
    if (t >= times[i] && t <= times[i + 1]) {
      final segmentT = (t - times[i]) / (times[i + 1] - times[i]);
      final eased = curve.transform(segmentT);
      return values[i] + (values[i + 1] - values[i]) * eased;
    }
  }
  return values.last;
}

/// Modulo-based wrapping for looping animations.
double loopT(double t, double delay) {
  return ((t - delay) % 1.0 + 1.0) % 1.0;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. PathRenderState
// ═══════════════════════════════════════════════════════════════════════════════

class PathRenderState {
  double drawProgress = 0;
  double strokeOpacity = 0;
  double fillOpacity = 0;
  Matrix4? transform;
  Shader? fillShader;

  void reset() {
    drawProgress = 0;
    strokeOpacity = 0;
    fillOpacity = 0;
    transform = null;
    fillShader = null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. SvgAnimationContext
// ═══════════════════════════════════════════════════════════════════════════════

/// Tüm effect'lerin paylaştığı bağlam: paint'ler (reuse için), color, vb.
class SvgAnimationContext {
  SvgAnimationContext({required this.color, required this.strokeWidth});

  Color color;
  double strokeWidth;

  final Paint fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final Paint strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  final ui.Path scratchPath = ui.Path();
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. SvgAnimationEffect (abstract)
// ═══════════════════════════════════════════════════════════════════════════════

/// Effect bir path'in render state'ini modifiye eder.
abstract class SvgAnimationEffect {
  const SvgAnimationEffect();

  void modify({
    required PathRenderState state,
    required int pathIndex,
    required ParsedSvgPath path,
    required double t,
    required SvgAnimationContext context,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// 7. Effect implementations
// ═══════════════════════════════════════════════════════════════════════════════

class DrawEffect extends SvgAnimationEffect {
  const DrawEffect({
    required this.duration,
    required this.stagger,
    required this.initialDelay,
    this.curve = const Cubic(0.22, 1.0, 0.36, 1.0),
    this.initialStrokeOpacity = 1.0,
  });

  final double duration;
  final double stagger;
  final double initialDelay;
  final Curve curve;
  final double initialStrokeOpacity;

  @override
  void modify({
    required PathRenderState state,
    required int pathIndex,
    required ParsedSvgPath path,
    required double t,
    required SvgAnimationContext context,
  }) {
    final start = initialDelay + pathIndex * stagger;
    final progress = timeWindow(t, start, duration, curve);
    if (progress <= 0) {
      return;
    }
    state.drawProgress = progress;
    state.strokeOpacity = initialStrokeOpacity;
  }
}

class FillEffect extends SvgAnimationEffect {
  const FillEffect({
    required this.duration,
    required this.stagger,
    required this.startDelay,
    this.curve = Curves.easeOut,
  });

  final double duration;
  final double stagger;
  final double startDelay;
  final Curve curve;

  @override
  void modify({
    required PathRenderState state,
    required int pathIndex,
    required ParsedSvgPath path,
    required double t,
    required SvgAnimationContext context,
  }) {
    final start = startDelay + pathIndex * stagger;
    state.fillOpacity = timeWindow(t, start, duration, curve);
  }
}

class StrokeFadeEffect extends SvgAnimationEffect {
  const StrokeFadeEffect({
    required this.duration,
    required this.stagger,
    required this.startDelay,
    this.curve = Curves.easeOut,
  });

  final double duration;
  final double stagger;
  final double startDelay;
  final Curve curve;

  @override
  void modify({
    required PathRenderState state,
    required int pathIndex,
    required ParsedSvgPath path,
    required double t,
    required SvgAnimationContext context,
  }) {
    final start = startDelay + pathIndex * stagger;
    final fadeProgress = timeWindow(t, start, duration, curve);
    state.strokeOpacity *= 1.0 - fadeProgress;
  }
}

class ShimmerFillEffect extends SvgAnimationEffect {
  const ShimmerFillEffect({
    required this.cycleDuration,
    required this.viewBoxHeight,
    this.x1Range = const (-100.0, 700.0),
    this.x2Range = const (100.0, 900.0),
    this.curve = Curves.easeInOut,
  });

  final double cycleDuration;
  final double viewBoxHeight;
  final (double, double) x1Range;
  final (double, double) x2Range;
  final Curve curve;

  @override
  void modify({
    required PathRenderState state,
    required int pathIndex,
    required ParsedSvgPath path,
    required double t,
    required SvgAnimationContext context,
  }) {
    final normalizedT = (t / cycleDuration).clamp(0.0, 1.0);
    final shimmerT = curve.transform(normalizedT);
    final x1 = x1Range.$1 + (x1Range.$2 - x1Range.$1) * shimmerT;
    final x2 = x2Range.$1 + (x2Range.$2 - x2Range.$1) * shimmerT;

    state.fillShader = ui.Gradient.linear(
      Offset(x1, viewBoxHeight / 2),
      Offset(x2, viewBoxHeight / 2),
      [
        context.color.withValues(alpha: context.color.a * 0.4),
        context.color.withValues(alpha: context.color.a),
        context.color.withValues(alpha: context.color.a * 0.4),
      ],
      const [0.0, 0.5, 1.0],
    );
  }
}

class ScalePulseEffect extends SvgAnimationEffect {
  const ScalePulseEffect({
    required this.times,
    required this.scaleValues,
    required this.opacityValues,
    required this.cycleDuration,
    required this.staggerByGroupKey,
    required this.staggerStep,
    required this.origin,
    this.defaultGroupIndex = 7,
    this.curve = Curves.easeInOut,
  });

  final List<double> times;
  final List<double> scaleValues;
  final List<double> opacityValues;
  final double cycleDuration;
  final Map<String, int> staggerByGroupKey;
  final double staggerStep;
  final Offset origin;
  final int defaultGroupIndex;
  final Curve curve;

  @override
  void modify({
    required PathRenderState state,
    required int pathIndex,
    required ParsedSvgPath path,
    required double t,
    required SvgAnimationContext context,
  }) {
    final groupIndex = staggerByGroupKey[path.key] ?? defaultGroupIndex;
    final controllerT = t / cycleDuration;
    final delay = (groupIndex * staggerStep) / cycleDuration;
    final localT = loopT(controllerT, delay);

    final scale = interpolateKeyframes(
      t: localT,
      times: times,
      values: scaleValues,
      curve: curve,
    );
    final opacity = interpolateKeyframes(
      t: localT,
      times: times,
      values: opacityValues,
      curve: curve,
    );

    state.transform = Matrix4.identity()
      ..translateByDouble(origin.dx, origin.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-origin.dx, -origin.dy, 0, 1);
    state.fillOpacity = opacity;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 8. PulsingGlow widget
// ═══════════════════════════════════════════════════════════════════════════════

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.intensity, required this.color});

  final double intensity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) / 2;
    final baseAlpha = 0.08 * intensity;

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          color.withValues(alpha: baseAlpha),
          color.withValues(alpha: baseAlpha * 0.35),
          color.withValues(alpha: 0),
        ],
        const [0.0, 0.35, 0.7],
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.intensity != intensity || oldDelegate.color != color;
  }
}

class PulsingGlow extends StatefulWidget {
  const PulsingGlow({
    super.key,
    required this.color,
    required this.cycleDuration,
    required this.times,
    required this.opacityValues,
    this.blurSigma = 8.0,
    required this.child,
  });

  final Color color;
  final double cycleDuration;
  final List<double> times;
  final List<double> opacityValues;
  final double blurSigma;
  final Widget child;

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.cycleDuration * 1000).ceil()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final intensity = interpolateKeyframes(
              t: _controller.value,
              times: widget.times,
              values: widget.opacityValues,
            );
            return ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: widget.blurSigma,
                sigmaY: widget.blurSigma,
              ),
              child: CustomPaint(
                painter: _GlowPainter(
                  intensity: intensity,
                  color: widget.color,
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 9. _SvgAnimationPainter
// ═══════════════════════════════════════════════════════════════════════════════

class _SvgAnimationPainter extends CustomPainter {
  _SvgAnimationPainter({
    required this.library,
    required this.effects,
    required this.t,
    required this.context,
  }) : _renderStates = List.generate(
         library.paths.length,
         (_) => PathRenderState(),
         growable: false,
       );

  final SvgPathLibrary library;
  final List<SvgAnimationEffect> effects;
  final double t;
  final SvgAnimationContext context;

  final List<PathRenderState> _renderStates;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / library.viewBoxWidth,
      size.height / library.viewBoxHeight,
    );
    final dx = (size.width - library.viewBoxWidth * scale) / 2;
    final dy = (size.height - library.viewBoxHeight * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    for (var i = 0; i < library.paths.length; i++) {
      final path = library.paths[i];
      final state = _renderStates[i]..reset();

      for (final effect in effects) {
        effect.modify(
          state: state,
          pathIndex: i,
          path: path,
          t: t,
          context: context,
        );
      }

      _renderPath(canvas, path, state);
    }

    canvas.restore();
  }

  void _renderPath(Canvas canvas, ParsedSvgPath path, PathRenderState state) {
    final hasTransform = state.transform != null;
    if (hasTransform) {
      canvas.save();
      canvas.transform(state.transform!.storage);
    }

    if (state.drawProgress > 0 && state.strokeOpacity > 0) {
      context.scratchPath.reset();
      for (final metric in path.metrics) {
        final len = metric.length * state.drawProgress;
        if (len > 0) {
          context.scratchPath.addPath(metric.extractPath(0, len), Offset.zero);
        }
      }

      if (!context.scratchPath.getBounds().isEmpty) {
        context.strokePaint
          ..strokeWidth = context.strokeWidth
          ..color = context.color.withValues(
            alpha: context.color.a * state.strokeOpacity,
          )
          ..shader = null;
        canvas.drawPath(context.scratchPath, context.strokePaint);
      }
    }

    if (state.fillOpacity > 0) {
      if (state.fillShader != null) {
        context.fillPaint
          ..shader = state.fillShader
          ..color = Color.fromRGBO(0, 0, 0, state.fillOpacity);
      } else {
        context.fillPaint
          ..shader = null
          ..color = context.color.withValues(
            alpha: context.color.a * state.fillOpacity,
          );
      }
      canvas.drawPath(path.path, context.fillPaint);
    }

    if (hasTransform) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SvgAnimationPainter old) {
    return old.t != t ||
        old.library != library ||
        old.context.color != context.color ||
        old.context.strokeWidth != context.strokeWidth;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 10. SvgAnimationWidget
// ═══════════════════════════════════════════════════════════════════════════════

class SvgAnimationWidget extends StatefulWidget {
  const SvgAnimationWidget({
    super.key,
    required this.library,
    required this.effects,
    required this.totalDuration,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
    this.loop = false,
    this.autoStart = true,
  });

  final SvgPathLibrary library;
  final List<SvgAnimationEffect> effects;
  final Duration totalDuration;
  final Color color;
  final double strokeWidth;
  final bool loop;
  final bool autoStart;

  @override
  State<SvgAnimationWidget> createState() => _SvgAnimationWidgetState();
}

class _SvgAnimationWidgetState extends State<SvgAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final SvgAnimationContext _context;

  double get _totalSeconds => widget.totalDuration.inMilliseconds / 1000.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );
    _context = SvgAnimationContext(
      color: widget.color,
      strokeWidth: widget.strokeWidth,
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward().whenComplete(_controller.stop);
    }
  }

  @override
  void didUpdateWidget(covariant SvgAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _context.color = widget.color;
    _context.strokeWidth = widget.strokeWidth;

    if (oldWidget.totalDuration != widget.totalDuration) {
      _controller.duration = widget.totalDuration;
    }

    if (widget.autoStart &&
        !_controller.isAnimating &&
        _controller.value == 0) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SvgAnimationPainter(
              library: widget.library,
              effects: widget.effects,
              t: _controller.value * _totalSeconds,
              context: _context,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 11. Recipes
// ═══════════════════════════════════════════════════════════════════════════════

/// Draw → fill → stroke fade one-shot animation recipe.
class DrawAndFillRecipe {
  const DrawAndFillRecipe({
    required this.library,
    this.drawDuration = 2.0,
    this.stagger = 0.08,
    this.initialDelay = 0.6,
    this.fillDelay = 0.3,
    this.fillDuration = 0.8,
    this.strokeFadeDuration = 0.5,
  });

  final SvgPathLibrary library;
  final double drawDuration;
  final double stagger;
  final double initialDelay;
  final double fillDelay;
  final double fillDuration;
  final double strokeFadeDuration;

  List<SvgAnimationEffect> build() => [
    DrawEffect(
      duration: drawDuration,
      stagger: stagger,
      initialDelay: initialDelay,
    ),
    FillEffect(
      duration: fillDuration,
      stagger: stagger,
      startDelay: initialDelay + drawDuration * 0.6 + fillDelay,
    ),
    StrokeFadeEffect(
      duration: strokeFadeDuration,
      stagger: stagger,
      startDelay: initialDelay + drawDuration + fillDelay,
    ),
  ];

  Duration totalDuration() {
    final pathCount = library.paths.length;
    if (pathCount == 0) {
      return Duration.zero;
    }
    final lastPathStart = initialDelay + (pathCount - 1) * stagger;
    final seconds =
        lastPathStart + drawDuration + fillDelay + strokeFadeDuration;
    return Duration(milliseconds: (seconds * 1000).ceil());
  }
}

/// Shimmer gradient + scale pulse looping animation recipe.
class ShimmerLoopRecipe {
  const ShimmerLoopRecipe({
    required this.library,
    required this.groups,
    required this.scaleOrigin,
    this.cycleDuration = 3.2,
    this.drawPhase = 1.2,
    this.holdPhase = 1.0,
    this.staggerStep = 0.1,
  });

  final SvgPathLibrary library;
  final List<List<String>> groups;
  final Offset scaleOrigin;
  final double cycleDuration;
  final double drawPhase;
  final double holdPhase;
  final double staggerStep;

  Map<String, int> _buildGroupMap() {
    final map = <String, int>{};
    for (var g = 0; g < groups.length; g++) {
      for (final key in groups[g]) {
        map[key] = g;
      }
    }
    return map;
  }

  List<SvgAnimationEffect> build() {
    final groupMap = _buildGroupMap();
    final times = [
      0.0,
      drawPhase / cycleDuration,
      (drawPhase + holdPhase) / cycleDuration,
      1.0,
    ];
    return [
      ShimmerFillEffect(
        cycleDuration: cycleDuration,
        viewBoxHeight: library.viewBoxHeight,
      ),
      ScalePulseEffect(
        times: times,
        scaleValues: const [0.97, 1.0, 1.0, 0.97],
        opacityValues: const [0.0, 1.0, 1.0, 0.0],
        cycleDuration: cycleDuration,
        staggerByGroupKey: groupMap,
        staggerStep: staggerStep,
        origin: scaleOrigin,
        defaultGroupIndex: groups.length,
      ),
    ];
  }

  Duration totalDuration() {
    return Duration(milliseconds: (cycleDuration * 1000).ceil());
  }
}
