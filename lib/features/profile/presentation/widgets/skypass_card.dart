import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/profile/presentation/widgets/tilt_builder.dart';

/// Kulüp üyelik kartı. Banka kartı oranında (85.6 × 53.98 mm) çizilir.
///
/// İki yüzü var: ön yüzde kimlik bilgileri, arkasında üyelik QR'ı. Karta
/// dokunulunca Y ekseninde dönerek diğer yüze geçer.
class SkyPassCard extends StatefulWidget {
  const SkyPassCard({
    super.key,
    required this.name,
    required this.skyNumber,
    required this.subtitle,
  });

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
  void dispose() {
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

  /// Gerçek üyelik QR'ı bağlanana kadar desenin tohumu.
  String get _qrData => 'SKYPASS:${widget.skyNumber}:${widget.name}';

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
          AspectRatio(aspectRatio: 1, child: SkyPassQr(data: _qrData)),
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
          'Girişte bu kodu okut',
          maxLines: 2,
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

/// SkyPass'in arka yüzündeki QR görseli.
///
/// **Gerçek bir QR değil.** İçinde okunabilir veri yok; kartın arka yüzü
/// tasarlanabilsin diye [data]'dan türetilmiş sahte bir desen çiziyor. Aynı
/// [data] için hep aynı desen çıkar, yani kart çevrildikçe kod değişmiyor.
/// Üyelik QR'ı bağlandığında yalnızca bu widget'ın yeri değişecek.
class SkyPassQr extends StatelessWidget {
  const SkyPassQr({super.key, required this.data});

  /// Desenin tohumu. Gerçek uygulamada QR'ın içeriği olacak.
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.skyPassQr,
      decoration: BoxDecoration(
        color: AppColors.onAccent,
        borderRadius: BorderRadius.circular(AppRadiuses.innerTile),
      ),
      child: CustomPaint(size: Size.infinite, painter: _MockQrPainter(data)),
    );
  }
}

class _MockQrPainter extends CustomPainter {
  _MockQrPainter(this.data);

  final String data;

  /// Kenardaki modül sayısı. Gerçek bir QR'ın orta boy sürümüne yakın
  /// sıklıkta görünsün diye seçildi.
  static const int _moduleCount = 25;

  /// Köşelerdeki hizalama karesinin kenarı (gerçek QR'da da 7).
  static const int _finderSize = 7;

  /// Modül köşelerinin yuvarlaklığı; kartın geri kalanı yuvarlak hatlı.
  static const double _moduleRadiusFactor = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    final module = size.shortestSide / _moduleCount;
    final paint = Paint()..color = AppColors.skyPassForeground;

    // Tohum veriden geliyor: aynı kart her açılışta aynı deseni çiziyor.
    final random = Random(data.hashCode);

    for (var row = 0; row < _moduleCount; row++) {
      for (var col = 0; col < _moduleCount; col++) {
        final filled = random.nextBool();
        if (!filled || _isFinderArea(row, col)) continue;
        _paintModule(canvas, paint, module, row, col);
      }
    }

    _paintFinders(canvas, paint, module);
  }

  /// Hizalama karelerinin ve etraflarındaki bir modülük boşluğun alanı;
  /// oraya rastgele modül düşerse kare okunmaz hâle gelir.
  bool _isFinderArea(int row, int col) {
    const int farEdge = _moduleCount - _finderSize - 1;
    final bool nearTop = row <= _finderSize;
    final bool nearLeft = col <= _finderSize;
    final bool nearRight = col >= farEdge;
    final bool nearBottom = row >= farEdge;

    return (nearTop && nearLeft) ||
        (nearTop && nearRight) ||
        (nearBottom && nearLeft);
  }

  void _paintModule(
    Canvas canvas,
    Paint paint,
    double module,
    int row,
    int col,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(col * module, row * module, module, module),
        Radius.circular(module * _moduleRadiusFactor),
      ),
      paint,
    );
  }

  void _paintFinders(Canvas canvas, Paint paint, double module) {
    const double farEdge = (_moduleCount - _finderSize) * 1.0;

    for (final origin in const [
      Offset(0, 0),
      Offset(farEdge, 0),
      Offset(0, farEdge),
    ]) {
      _paintFinder(canvas, paint, module, origin);
    }
  }

  /// İç içe üç kare: dolu 7×7, üstüne oyulan beyaz 5×5, ortada dolu 3×3.
  void _paintFinder(Canvas canvas, Paint paint, double module, Offset origin) {
    void square(double inset, Color color) {
      final side = (_finderSize - inset * 2) * module;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (origin.dx + inset) * module,
            (origin.dy + inset) * module,
            side,
            side,
          ),
          Radius.circular(module * 0.8),
        ),
        Paint()..color = color,
      );
    }

    square(0, paint.color);
    square(1, AppColors.onAccent);
    square(2, paint.color);
  }

  @override
  bool shouldRepaint(_MockQrPainter oldDelegate) => oldDelegate.data != data;
}
