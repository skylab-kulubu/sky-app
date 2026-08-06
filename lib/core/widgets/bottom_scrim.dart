import 'package:flutter/material.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Yüzen bir alt çubuğun (navbar, katılım butonu) arkasından geçen içeriği
/// yumuşatan alt gradyan.
///
/// Zemin rengi temadan geliyor: koyu temada siyaha, açık temada beyaza
/// gidiyor. Sabit siyah verilseydi açık temada içeriğin üstüne koyu bir
/// bant binerdi.
///
/// [Positioned] döndürdüğü için doğrudan bir [Stack]'in çocuğu olmalı.
class BottomScrim extends StatelessWidget {
  const BottomScrim({super.key, this.height = _defaultHeight, this.color});

  /// Gradyanın kapladığı yükseklik. Çubuğun hizasını rahatça aşmalı, aksi
  /// hâlde içerik çubuğun iki yanından net biçimde sızıyor.
  final double height;

  /// Gradyanın gittiği renk. Sayfanın zemini tema renginden farklıysa
  /// (etkinlik detayındaki renkli zemin gibi) verilmeli; yoksa karartma
  /// sayfanın altında ayrı bir bant gibi durur.
  final Color? color;

  static const double _defaultHeight = 100;

  /// Çubuğun hizasına gelmeden önce büyük ölçüde koyulaşsın diye ara
  /// duraklar yukarı çekildi.
  static const List<double> _stops = [0.0, 0.15, 0.6, 1.0];
  static const List<double> _opacities = [0.0, 0.3, 0.7, 1.0];

  @override
  Widget build(BuildContext context) {
    final base = color ?? context.backgroundColor;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: _stops,
              colors: [
                for (final opacity in _opacities)
                  base.withValues(alpha: opacity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
