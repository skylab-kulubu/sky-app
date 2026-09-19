part of 'door_scanner_page.dart';

/// Son okutmanın sonucu; okuyucunun altında gösteriliyor.
enum DoorResultKind { success, already, error }

/// Girişin nasıl alındığı: SkyPass QR'ı kamerayla ya da öğrenci kartı NFC ile.
enum DoorMode { qr, card }

class DoorResult {
  const DoorResult(this.kind, this.title, [this.detail = '']);

  final DoorResultKind kind;
  final String title;
  final String detail;
}

abstract class DoorScannerPagemodel extends State<DoorScannerPage> {
  final DoorService _service = DoorService();

  final MobileScannerController scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  /// Aynı kod bu süre içinde tekrar okunursa yok sayılıyor; kamera aynı
  /// kodu saniyede birkaç kez görüyor.
  static const Duration _repeatWindow = Duration(seconds: 4);

  /// Sonuç kartı bu kadar sonra kayboluyor; sıradaki kişi temiz ekran görsün.
  static const Duration _resultDuration = Duration(seconds: 5);

  late final User? _user = context.read<UserProvider>().user;

  /// Giriş alınabilecek, bitmemiş etkinlikler. Liste core'dan
  /// (`/v1/door/events`); yetkiyi core hesaplıyor.
  List<EventModel> events = const [];
  bool isLoadingEvents = true;
  ApiException? eventsError;

  EventModel? event;
  List<({EventDay day, EventSession session})> sessions = const [];
  ({EventDay day, EventSession session})? selected;
  bool isLoadingSessions = false;
  ApiException? sessionsError;

  DoorResult? result;

  /// Seçili oturumda alınan toplam giriş; bilinmiyorsa `null`.
  int? sessionTotal;

  /// Varsayılan öğrenci kartı: kapıda en hızlı yol, kamera izni de
  /// istemiyor. QR'a geçilince kamera açılıyor.
  DoorMode mode = DoorMode.card;

  /// NFC okuma ya da kartla giriş isteği sürüyor.
  bool isReadingCard = false;

  final NfcService _nfc = NfcService();
  bool _busy = false;
  String? _lastRaw;
  DateTime? _lastRawAt;
  Timer? _resultTimer;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoadingEvents = true;
      eventsError = null;
    });
    try {
      final all = await _service.fetchDoorEvents();
      if (!mounted) return;
      final upcoming = all.where((e) => e.isUpcoming).toList()
        ..sort((a, b) {
          final aStart = a.startDateTime;
          final bStart = b.startDateTime;
          if (aStart == null || bStart == null) return 0;
          return aStart.compareTo(bStart);
        });
      setState(() {
        events = upcoming;
        isLoadingEvents = false;
      });
      final first = upcoming.firstOrNull;
      if (first != null) await _selectEvent(first);
    } catch (e) {
      final error = ApiException.from(e);
      log('Kapı etkinlikleri alınamadı: $error');
      if (!mounted) return;
      setState(() {
        eventsError = error;
        isLoadingEvents = false;
      });
    }
  }

  void onRetryEvents() => _loadEvents();

  @override
  void dispose() {
    _resultTimer?.cancel();
    scanner.dispose();
    super.dispose();
  }

  String get eventLabel => event?.name ?? 'Seç';

  /// Oturum satırının alt yazısı: saat ve alınan giriş sayısı.
  String? get sessionSubtitle {
    final parts = [
      if (selected?.session.timeRange.isNotEmpty ?? false)
        selected!.session.timeRange,
      if (sessionTotal != null) '$sessionTotal giriş',
    ];
    return parts.isEmpty ? null : parts.join('  •  ');
  }

  String get sessionLabel {
    if (isLoadingSessions) return 'Yükleniyor…';
    final s = selected;
    if (s == null) return sessions.isEmpty ? 'Oturum yok' : 'Seç';
    return s.session.title.isEmpty ? s.day.name : s.session.title;
  }

  Future<void> _selectEvent(EventModel value) async {
    setState(() {
      event = value;
      sessions = const [];
      selected = null;
      sessionTotal = null;
      sessionsError = null;
      isLoadingSessions = true;
    });

    try {
      final result = await _service.fetchSessions(value.id);
      if (!mounted || event?.id != value.id) return;
      setState(() {
        sessions = result;
        selected = _defaultSession(result);
        isLoadingSessions = false;
      });
      _loadTotal();
    } catch (e) {
      final error = ApiException.from(e);
      log('Oturumlar alınamadı: $error');
      if (!mounted || event?.id != value.id) return;
      setState(() {
        sessionsError = error;
        isLoadingSessions = false;
      });
    }
  }

  /// Şu an süren oturum; yoksa bitmemiş ilk oturum; o da yoksa ilki.
  static ({EventDay day, EventSession session})? _defaultSession(
    List<({EventDay day, EventSession session})> all,
  ) {
    final now = DateTime.now();
    return all.where((s) => s.session.isNow).firstOrNull ??
        all
            .where((s) => s.session.endTime?.isAfter(now) ?? false)
            .firstOrNull ??
        all.firstOrNull;
  }

  /// Seçili etkinliğin programını düzenleyebilir mi (oturum yoksa buton).
  bool get canEditSchedule {
    final current = event;
    if (current == null) return false;
    return _user?.canEditEvent(current.ownerTeam) ?? false;
  }

  /// Programı açar; dönünce oturumları yeniden yükler.
  Future<void> onEditSchedule() async {
    final current = event;
    if (current == null) return;
    final changed = await EventSchedulePage.open(context, current);
    if (changed && mounted) await _selectEvent(current);
  }

  void onRetrySessions() {
    final current = event;
    if (current != null) _selectEvent(current);
  }

  Future<void> onChooseEvent() async {
    if (events.length <= 1) return;
    final index = await EventOptionSheet.show(
      context,
      title: 'Etkinlik',
      options: [for (final e in events) e.name],
      selectedIndex: event == null ? null : events.indexOf(event!),
      icon: AppIcons.calendar,
      iconColor: AppColors.blue,
    );
    if (index == null || !mounted) return;
    await _selectEvent(events[index]);
  }

  Future<void> onChooseSession() async {
    if (sessions.length <= 1) return;
    final index = await EventOptionSheet.show(
      context,
      title: 'Oturum',
      options: [
        for (final s in sessions)
          [
            if (s.session.title.isNotEmpty) s.session.title,
            if (s.session.timeRange.isNotEmpty) s.session.timeRange,
          ].join('  •  '),
      ],
      selectedIndex: selected == null ? null : sessions.indexOf(selected!),
      icon: AppIcons.clock,
      iconColor: AppColors.purple,
    );
    if (index == null || !mounted) return;
    setState(() {
      selected = sessions[index];
      sessionTotal = null;
    });
    _loadTotal();
  }

  /// Seçili oturumdaki giriş sayısı; alınamazsa gösterilmiyor.
  Future<void> _loadTotal() async {
    final sessionId = selected?.session.id;
    if (sessionId == null) return;
    try {
      final activity = await _service.sessionActivity(sessionId);
      if (!mounted || selected?.session.id != sessionId) return;
      setState(() => sessionTotal = activity.total);
    } catch (e) {
      log('Giriş sayısı alınamadı: $e');
    }
  }

  /// QR ile kart arasında geçer. Kart modunda kamera kapatılıyor; QR'a
  /// dönünce okuyucu widget'ı kamerayı yeniden başlatıyor.
  Future<void> onModeChanged(DoorMode value) async {
    if (value == mode || isReadingCard) return;
    if (value == DoorMode.card) await scanner.stop();
    if (!mounted) return;
    setState(() {
      mode = value;
      result = null;
    });
  }

  /// Öğrenci kartını NFC ile okur ve girişi alır. iOS her okumada sistem
  /// penceresini açtığı için okuma her kişi için butonla başlatılıyor.
  Future<void> onReadCard() async {
    final session = selected?.session;
    if (session == null || isReadingCard) return;

    final availability = await _nfc.checkAvailability();
    if (!mounted) return;
    if (availability == NFCAvailability.not_supported) {
      _show(const DoorResult(DoorResultKind.error, 'Bu cihazda NFC yok'));
      return;
    }
    if (availability == NFCAvailability.disabled) {
      _show(
        const DoorResult(
          DoorResultKind.error,
          'NFC kapalı',
          'Telefonun ayarlarından NFC\'yi açıp tekrar dene.',
        ),
      );
      return;
    }

    setState(() => isReadingCard = true);
    try {
      final NfcCard card;
      try {
        card = await _nfc.pollCard(
          iosAlertMessage: 'Öğrenci kartını telefonun arkasına yaklaştır',
        );
      } catch (e) {
        log('Kart okunamadı: $e');
        await _nfc.finishSession(iosErrorMessage: 'Kart okunamadı');
        _show(const DoorResult(DoorResultKind.error, 'Kart okunamadı'));
        return;
      }
      await _nfc.finishSession(iosAlertMessage: 'Kart okundu');

      try {
        final done = await _service.checkIn(
          session.id,
          uid: card.normalizedHex,
        );
        _showSuccess(done);
      } catch (e) {
        final error = ApiException.from(e);
        log('Kartla giriş alınamadı: $error');
        _show(_resultForError(error, byCard: true));
      }
    } finally {
      if (mounted) setState(() => isReadingCard = false);
    }
  }

  /// Kameranın gördüğü kod. Bir istek sürerken ya da aynı kod az önce
  /// okunduysa yok sayılıyor.
  Future<void> onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    final session = selected?.session;
    if (raw == null || raw.isEmpty || session == null || _busy) return;

    final now = DateTime.now();
    if (raw == _lastRaw &&
        _lastRawAt != null &&
        now.difference(_lastRawAt!) < _repeatWindow) {
      return;
    }
    _lastRaw = raw;
    _lastRawAt = now;

    if (!DoorService.isSkyPassToken(raw)) {
      _show(
        const DoorResult(DoorResultKind.error, 'Bu bir SkyPass kodu değil'),
      );
      return;
    }

    _busy = true;
    try {
      final done = await _service.checkIn(session.id, token: raw);
      _showSuccess(done);
    } catch (e) {
      final error = ApiException.from(e);
      log('Kapı girişi alınamadı: $error');
      _show(_resultForError(error, byCard: false));
    } finally {
      _busy = false;
    }
  }

  /// Başarılı girişte kimin girdiği görünüyor; görevli karşısındakinin o kişi
  /// olduğunu teyit edebilsin. Sayaç da güncelleniyor.
  void _showSuccess(DoorCheckIn done) {
    if (done.total != null) setState(() => sessionTotal = done.total);
    _show(DoorResult(DoorResultKind.success, 'Giriş alındı', done.personName));
  }

  static DoorResult _resultForError(
    ApiException error, {
    required bool byCard,
  }) {
    return switch (error.statusCode) {
      409 => const DoorResult(DoorResultKind.already, 'Zaten giriş yapmış'),
      // Kartta 404 iki anlama geliyor: kart kimseye eşli değil ya da kişinin
      // bu etkinlikte bileti yok; core ikisini ayırmıyor.
      404 when byCard => const DoorResult(
        DoorResultKind.error,
        'Giriş alınamadı',
        'Kart bir hesaba eşli değil ya da kişinin bu etkinlikte kaydı yok.',
      ),
      404 => const DoorResult(DoorResultKind.error, 'Bu etkinliğe kaydı yok'),
      401 => const DoorResult(
        DoorResultKind.error,
        'Kodun süresi dolmuş',
        'Kişiden kartını yeniden açmasını iste.',
      ),
      403 => const DoorResult(
        DoorResultKind.error,
        'Bu etkinlikte okutma yetkin yok',
      ),
      400 when byCard => const DoorResult(
        DoorResultKind.error,
        'Kart numarası okunamadı',
      ),
      _ => DoorResult(DoorResultKind.error, error.userMessage),
    };
  }

  void _show(DoorResult value) {
    if (!mounted) return;
    switch (value.kind) {
      case DoorResultKind.success:
        HapticFeedback.mediumImpact();
      case DoorResultKind.already:
      case DoorResultKind.error:
        HapticFeedback.heavyImpact();
    }
    _resultTimer?.cancel();
    setState(() => result = value);
    _resultTimer = Timer(_resultDuration, () {
      if (mounted) setState(() => result = null);
    });
  }
}
