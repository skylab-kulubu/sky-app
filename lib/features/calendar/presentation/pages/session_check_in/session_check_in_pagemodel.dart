part of 'session_check_in_page.dart';

abstract class SessionCheckInPagemodel extends State<SessionCheckInPage> {
  final AttendanceService _service = AttendanceService();

  final MobileScannerController scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  /// Aynı kod bu süre içinde tekrar okunursa yok sayılıyor; kamera aynı
  /// kodu saniyede birkaç kez görüyor.
  static const Duration _repeatWindow = Duration(seconds: 4);

  /// Hata sonucu bu kadar sonra kayboluyor; başarı ekranda kalıyor.
  static const Duration _errorDuration = Duration(seconds: 5);

  ScanResult? result;

  /// Oturum sorgusu ya da giriş isteği sürüyor.
  bool isBusy = false;

  String? _lastRaw;
  DateTime? _lastRawAt;
  Timer? _resultTimer;

  @override
  void dispose() {
    _resultTimer?.cancel();
    scanner.dispose();
    super.dispose();
  }

  /// Kameranın gördüğü kod. Bir istek sürerken ya da aynı kod az önce
  /// okunduysa yok sayılıyor.
  Future<void> onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty || isBusy) return;

    final now = DateTime.now();
    if (raw == _lastRaw &&
        _lastRawAt != null &&
        now.difference(_lastRawAt!) < _repeatWindow) {
      return;
    }
    _lastRaw = raw;
    _lastRawAt = now;

    final sessionId = AttendanceService.sessionIdFromQr(raw);
    if (sessionId == null) {
      _show(
        const ScanResult(
          ScanResultKind.error,
          'Bu bir oturum kodu değil',
          'Etkinlikte perdede gösterilen oturum QR\'ını okut.',
        ),
      );
      return;
    }

    setState(() => isBusy = true);
    try {
      await _checkIn(sessionId);
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  /// Önce oturum okunuyor: yoksa ya da iptal edildiyse giriş denenmiyor,
  /// başarıda da sonuçta oturumun adı gösteriliyor.
  Future<void> _checkIn(String sessionId) async {
    try {
      final session = await _service.fetchSession(sessionId);
      if (session.cancelled) {
        _show(
          ScanResult(
            ScanResultKind.error,
            'Bu oturum iptal edildi',
            session.title,
          ),
        );
        return;
      }

      try {
        await _service.checkIn(sessionId);
      } on ApiException catch (error) {
        log('Oturum girişi alınamadı: $error');
        _show(_resultForError(error, sessionTitle: session.title));
        return;
      }

      final eventName = await _service.eventName(session);
      _show(
        ScanResult(
          ScanResultKind.success,
          'Katılımın alındı',
          [
            if (session.title.isNotEmpty) session.title,
            if (eventName.isNotEmpty) eventName,
          ].join('  •  '),
        ),
      );
      _refreshActivities();
    } catch (e) {
      final error = ApiException.from(e);
      log('Oturum okunamadı: $error');
      _show(
        error.statusCode == 404
            ? const ScanResult(ScanResultKind.error, 'Oturum bulunamadı')
            : ScanResult(ScanResultKind.error, error.userMessage),
      );
    }
  }

  static ScanResult _resultForError(
    ApiException error, {
    required String sessionTitle,
  }) {
    return switch (error.statusCode) {
      409 => ScanResult(
        ScanResultKind.already,
        'Bu oturuma zaten katıldın',
        sessionTitle,
      ),
      // Oturum var; 404 kullanıcının bu etkinlikte bileti olmadığı demek.
      404 => const ScanResult(
        ScanResultKind.error,
        'Bu etkinliğe kaydın yok',
        'Önce etkinliğin sayfasından katıl.',
      ),
      _ => ScanResult(ScanResultKind.error, error.userMessage),
    };
  }

  /// Profildeki "Aktivitelerim" yeni katılımı göstersin.
  void _refreshActivities() {
    final userId = context.read<UserProvider>().user?.id;
    if (userId == null) return;
    unawaited(context.read<ActivityProvider>().refresh(userId));
  }

  void _show(ScanResult value) {
    if (!mounted) return;
    switch (value.kind) {
      case ScanResultKind.success:
        HapticFeedback.mediumImpact();
      case ScanResultKind.already:
      case ScanResultKind.error:
        HapticFeedback.heavyImpact();
    }
    _resultTimer?.cancel();
    setState(() => result = value);
    if (value.kind == ScanResultKind.success) return;
    _resultTimer = Timer(_errorDuration, () {
      if (mounted) setState(() => result = null);
    });
  }
}
