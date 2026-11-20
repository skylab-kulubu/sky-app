import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Cihazın eğimini açı olarak verir; `Transform` kurmuyor ki kullanan taraf
/// eğimi kendi dönüşüyle tek matriste birleştirsin.
///
/// Açı mutlak eğimden değil, yavaşça kayan bir referans duruştan sapma:
/// telefon sabitken kart düze dönüyor. Mutlak eğimde öne yatık tutan herkeste
/// kart yamuk dururdu.
class TiltBuilder extends StatefulWidget {
  const TiltBuilder({super.key, required this.builder});

  /// [tilt]`.dx` Y ekseni (sağa/sola), `.dy` X ekseni (öne/arkaya) dönüşü;
  /// ikisi de radyan.
  final Widget Function(BuildContext context, Offset tilt) builder;

  /// Eğimin gidebileceği en büyük açı. Efekt fark edilmeli ama içeriği
  /// okumayı zorlaştırmamalı.
  static const double _maxTilt = 0.10;

  /// [_maxTilt]'e karşılık gelen ivme farkı (m/s²); birkaç derece yetsin diye
  /// küçük.
  static const double _tiltRange = 2.6;

  /// Referans duruşun ölçümü izleme hızı (~3 saniyelik dönüş).
  static const double _baselineFollow = 0.006;

  /// Çizilen açının hedefe yaklaşma hızı; ivmeölçer gürültüsünü süzüyor.
  static const double _smoothing = 0.12;

  /// Gözle görülmeyen değişimler kare harcamasın.
  static const double _minStep = 0.0005;

  @override
  State<TiltBuilder> createState() => _TiltBuilderState();
}

class _TiltBuilderState extends State<TiltBuilder> {
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// Referans duruş: ilk ölçümle kuruluyor, sonra ölçümü yavaşça izliyor.
  double? _baseX;
  double? _baseY;

  Offset _tilt = Offset.zero;

  /// `MediaQuery` build dışında okunmamalı; değer burada tutuluyor.
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listen() {
    // Sensörsüz platformlarda (web, masaüstü) akış hata veriyor; kart düz kalıyor.
    _subscription =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.uiInterval,
        ).listen(
          _onEvent,
          onError: (_) => _subscription?.cancel(),
          cancelOnError: true,
        );
  }

  void _onEvent(AccelerometerEvent event) {
    if (!mounted || _reduceMotion) return;

    _baseX = _follow(_baseX, event.x);
    _baseY = _follow(_baseY, event.y);

    final next = Offset(
      _approach(_tilt.dx, _angleOf(event.x - _baseX!)),
      // Öne/arkaya yatırmada kartın üstü kullanıcıya doğru gelmeli; eksen ters.
      _approach(_tilt.dy, -_angleOf(event.y - _baseY!)),
    );

    if ((next - _tilt).distance < TiltBuilder._minStep) return;

    setState(() => _tilt = next);
  }

  double _follow(double? base, double value) => base == null
      ? value
      : base + (value - base) * TiltBuilder._baselineFollow;

  double _approach(double current, double target) =>
      current + (target - current) * TiltBuilder._smoothing;

  double _angleOf(double delta) =>
      (delta / TiltBuilder._tiltRange).clamp(-1.0, 1.0) * TiltBuilder._maxTilt;

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _reduceMotion ? Offset.zero : _tilt);
}
