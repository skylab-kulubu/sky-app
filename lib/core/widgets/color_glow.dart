import 'package:flutter/material.dart';

/// Zemine dağılmış tek bir renk parıltısının yeri, yayılımı ve yoğunluğu.
typedef GlowSpot = ({Alignment center, double radius, double opacity});

/// Sayfa zeminine yumuşak renk parıltıları serer.
///
/// Her leke kenarına doğru tamamen şeffaflaştığı için sınırı belli olmuyor;
/// üst üste bindiklerinde renkler karışıyor ve tek yönlü bir gradyanın
/// mekanik görüntüsü oluşmuyor.
///
/// Renk sayısı leke sayısından az olabilir, sıra başa dönerek devam eder.
class ColorGlow extends StatelessWidget {
  const ColorGlow({
    super.key,
    required this.colors,
    required this.spots,
    this.intensity = 1.0,
  });

  final List<Color> colors;
  final List<GlowSpot> spots;

  /// Bütün lekelerin yoğunluğunu topluca ölçekler. Aynı yerleşimi farklı
  /// zeminlerde kullanabilmek için: koyu bir zeminde renkler açıktakinden
  /// çok daha çabuk doyuyor.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < spots.length; i++)
          _spot(spots[i], colors[i % colors.length]),
      ],
    );
  }

  Widget _spot(GlowSpot spot, Color color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: spot.center,
          radius: spot.radius,
          colors: [
            color.withValues(alpha: spot.opacity * intensity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
