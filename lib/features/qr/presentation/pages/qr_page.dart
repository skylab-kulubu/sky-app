import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sky_app/core/services/user_service.dart';

const _green = Color(0xFF22C55E);
const _greenLight = Color(0xFF86EFAC);
const _greenBg = Color(0xFF071F10);
const _greenSurface = Color(0xFF166534);

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  MobileScannerController? _controller;

  bool get _isScanning => _controller != null;

  Future<void> _openCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _controller?.dispose();
      final controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
      setState(() => _controller = controller);
      await controller.start();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _closeCamera() async {
    await _controller?.stop();
    await _controller?.dispose();
    setState(() => _controller = null);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final qrValue = capture.barcodes.firstOrNull?.rawValue;
    if (qrValue == null) return;

    _controller?.stop();

    final profile = await UserService.getProfile();
    final name = profile['name'] ?? '';
    final email = profile['email'] ?? '';

    debugPrint('QR: $qrValue | Ad Soyad: $name | Email: $email');

    if (mounted) {
      await _closeCamera();
      _showSuccessDialog(name);
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogContext) => Dialog(
        backgroundColor: _greenBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _green.withValues(alpha: 0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: _greenSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _greenLight.withValues(alpha: 0.5), width: 1.5),
                ),
                child: const Icon(Icons.check_rounded, color: _greenLight, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Yoklama Alındı',
                style: TextStyle(
                  color: _greenLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFFBBF7D0),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: 'Sevgili '),
                    TextSpan(
                      text: name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text: ', bu harika etkinliğe katılımın başarıyla kaydedildi. Seni aramızda görmek çok güzel!',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ana Menüye Dön',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final frameSize = MediaQuery.of(context).size.width - 64;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: const StadiumBorder(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: frameSize, height: frameSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _isScanning
                      ? MobileScanner(controller: _controller!, onDetect: _onDetect)
                      : Center(
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: frameSize * 0.5,
                      color: color.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                for (final a in [
                  Alignment.topLeft, Alignment.topRight,
                  Alignment.bottomLeft, Alignment.bottomRight,
                ])
                  _Corner(color: color, alignment: a),
              ],
            ),
          ),

          const SizedBox(height: 36),

          Text(
            'Etkinlik QR kodunu tarayarak etkinliğe\nkatılım sağlayabilirsiniz.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: _isScanning
                ? ElevatedButton.icon(
              onPressed: _closeCamera,
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Kamerayı Kapat'),
              style: buttonStyle,
            )
                : ElevatedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text('Kamerayı Aç'),
              style: buttonStyle,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Not: QR kod için kamera erişimi gereklidir.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner bracket ─────────────────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  const _Corner({required this.color, required this.alignment});
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y == -1;
    final isLeft = alignment.x == -1;
    return Positioned(
      top: isTop ? 0 : null, bottom: isTop ? null : 0,
      left: isLeft ? 0 : null, right: isLeft ? null : 0,
      child: CustomPaint(
        size: const Size(28, 28),
        painter: _CornerPainter(color: color, isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.color, required this.isTop, required this.isLeft});
  final Color color;
  final bool isTop, isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 3.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    const r = 8.0;
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (isTop && isLeft)  { path.moveTo(0, h); path.lineTo(0, r); path.arcToPoint(Offset(r, 0), radius: const Radius.circular(r)); path.lineTo(w, 0); }
    else if (isTop)       { path.moveTo(0, 0); path.lineTo(w - r, 0); path.arcToPoint(Offset(w, r), radius: const Radius.circular(r)); path.lineTo(w, h); }
    else if (isLeft)      { path.moveTo(w, h); path.lineTo(r, h); path.arcToPoint(Offset(0, h - r), radius: const Radius.circular(r)); path.lineTo(0, 0); }
    else                  { path.moveTo(w, 0); path.lineTo(w, h - r); path.arcToPoint(Offset(w - r, h), radius: const Radius.circular(r)); path.lineTo(0, h); }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}