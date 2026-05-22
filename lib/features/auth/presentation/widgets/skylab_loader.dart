import 'package:flutter/material.dart';
import 'package:sky_app/core/widgets/svg_animation_widget.dart';
import 'package:sky_app/features/auth/presentation/widgets/skylab_animation_logo.dart';

// ── Loader path groups (stagger order) ────────────────────────────────────────

const List<List<String>> _skylabLoaderGroups = [
  ['p20f79d00'],
  ['p15984f0', 'p1a20d600'],
  ['p2cc72200', 'p543f872', 'p4c50c00', 'p36c88b00'],
  ['p1cd4e100', 'p3097fa00', 'p12f85900', 'p3cad3800'],
  ['p28bb8280', 'p1dae6200', 'p7800', 'p5ee5d00'],
  ['p9522b80', 'p3b5dc900'],
  ['p596f400', 'pe3cee00'],
];

const double _loaderCycleDuration = 3.2;

final ShimmerLoopRecipe _skylabLoaderRecipe = ShimmerLoopRecipe(
  library: skylabLibrary,
  groups: _skylabLoaderGroups,
  scaleOrigin: const Offset(293, 277),
);

// ── SkylabLoader widget ───────────────────────────────────────────────────────

class SkylabLoader extends StatelessWidget {
  const SkylabLoader({super.key, this.size = 64, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: PulsingGlow(
          color: color,
          cycleDuration: _loaderCycleDuration,
          times: const [0.0, 0.3, 0.5, 0.75, 1.0],
          opacityValues: const [0.0, 0.6, 1.0, 0.6, 0.0],
          child: SvgAnimationWidget(
            library: skylabLibrary,
            effects: _skylabLoaderRecipe.build(),
            totalDuration: _skylabLoaderRecipe.totalDuration(),
            color: color,
            loop: true,
          ),
        ),
      ),
    );
  }
}
