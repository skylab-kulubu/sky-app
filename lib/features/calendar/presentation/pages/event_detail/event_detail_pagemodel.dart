part of 'event_detail_page.dart';

abstract class EventDetailPagemodel extends State<EventDetailPage> {
  final ScrollController scrollController = ScrollController();

  /// İstek sürerken buton kilitli kalıyor; çift kayıt oluşmasın diye.
  bool isJoining = false;

  /// Kapaktan çıkarılan renkler; çözülene kadar boş, zemin düz taban.
  List<Color> backdropTints = const [];

  late EventModel event = widget.event;

  final ScheduleService _scheduleService = ScheduleService();

  /// Programı herkese gösteriliyor; yüklenemezse bölüm görünmüyor.
  List<ScheduleDay> schedule = const [];

  bool get hasSchedule => schedule.any((entry) => entry.sessions.isNotEmpty);

  Future<void> _loadSchedule() async {
    try {
      final result = await _scheduleService.fetchSchedule(event.id);
      if (!mounted) return;
      setState(() => schedule = result);
    } catch (e) {
      log('Program alınamadı: $e');
    }
  }

  Future<void> onEditSchedule() async {
    final changed = await EventSchedulePage.open(context, event);
    if (changed && mounted) await _loadSchedule();
  }

  bool get canEdit =>
      context.watch<UserProvider>().user?.canEditEvent(event.ownerTeam) ??
      false;

  /// Kaydedildiyse sayfayı yeni hâliyle yeniler, silindiyse detaydan çıkar.
  Future<void> onEditPressed() async {
    final result = await EventCreatePage.edit(context, event);
    if (result == null || !mounted) return;

    if (result.deleted) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Etkinlik silindi.')),
      );
      return;
    }

    final updated = result.event;
    if (updated == null) return;

    // Kapak değiştiyse zemin yeni görselin renklerine geçiyor.
    final coverChanged = updated.coverImageUrl != event.coverImageUrl;
    setState(() {
      event = updated;
      if (coverChanged) {
        backdropTints = EventPaletteService.cached(
          updated.coverImageUrl,
          known: updated.coverColors,
        );
      }
    });
    if (coverChanged && backdropTints.isEmpty) {
      unawaited(_resolveBackdropTint());
    }
  }

  @override
  void initState() {
    super.initState();

    // Renkler kart göründüğünde hesaplanmaya başladı; çoğu zaman hazır ve zemin
    // ilk karede doğru renkte.
    backdropTints = EventPaletteService.cached(
      event.coverImageUrl,
      known: event.coverColors,
    );

    // Hazır değilse açılış animasyonundan sonra bekleniyor: palet ana iş
    // parçacığında çalışıp animasyonu takıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterTransition());

    _loadSchedule();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _afterTransition() {
    if (!mounted || backdropTints.isNotEmpty) return;

    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _resolveBackdropTint();
      return;
    }

    void onStatus(AnimationStatus status) {
      if (!mounted) {
        animation.removeStatusListener(onStatus);
        return;
      }
      if (status != AnimationStatus.completed) return;

      animation.removeStatusListener(onStatus);
      _resolveBackdropTint();
    }

    animation.addStatusListener(onStatus);
  }

  /// Zemin renklerini bekler; kart göründüğünde başlayan işe bağlanıyor, yenisini
  /// başlatmıyor.
  Future<void> _resolveBackdropTint() async {
    final imageUrl = event.coverImageUrl;
    final tints = await EventPaletteService.resolve(
      imageUrl,
      known: event.coverColors,
    );

    // Görsel indirilemediyse zemin düz kalıyor; beklerken kapak değiştiyse sonuç
    // eski.
    if (!mounted || tints.isEmpty || imageUrl != event.coverImageUrl) return;
    setState(() => backdropTints = tints);
  }

  String get joinButtonLabel => switch (event.phase) {
    EventPhase.open => 'Katıl',
    EventPhase.closed => 'Başvuru Kapalı',
    EventPhase.ended => 'Etkinlik Bitti',
    EventPhase.draft => 'Yayında Değil',
    EventPhase.cancelled => 'İptal Edildi',
  };

  /// Ad, tarih, konum ve uygulamada etkinliği açan bağlantıyla paylaşır.
  Future<void> onSharePressed() async {
    final lines = <String>[
      event.name,
      [
        event.formattedDayLabel,
        event.formattedTimeRange,
      ].where((part) => part.isNotEmpty).join(' · '),
      event.location,
      LinksService.eventLink(event.id),
    ].where((line) => line.isNotEmpty);

    await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  /// SKYFORMS formları uygulama içinde girişli (web handoff), başka adresteki
  /// form (Google Forms gibi) tarayıcıda açılıyor.
  String? get _formsPath =>
      HandoffService.pathOf(HandoffTarget.forms, event.formUrl);

  String get formSubtitle =>
      _formsPath != null ? 'SKY LAB hesabınla açılır' : 'Tarayıcıda açılır';

  Future<void> onFormTap() async {
    final path = _formsPath;
    if (path != null) {
      await HandoffSheet.show(context, target: HandoffTarget.forms, path: path);
      return;
    }
    if (!mounted) return;
    await WebviewService.openLink(
      context,
      LinkItem(
        name: 'Başvuru Formu',
        description: '',
        icon: AppIcons.form,
        color: AppColors.purple,
        url: event.formUrl,
      ),
    );
  }

  /// Katılım kaydı geri alınamadığı için önce onay soruluyor.
  Future<void> onJoinPressed() async {
    final confirmed = await _askConfirmation();
    if (confirmed != true || !mounted) return;

    setState(() => isJoining = true);
    final result = await context.read<EventProvider>().joinEvent(event.id);
    if (!mounted) return;
    setState(() => isJoining = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
    if (result.hasTicket) {
      final userId = context.read<UserProvider>().user?.id;
      if (userId != null) {
        unawaited(context.read<ActivityProvider>().refresh(userId));
      }
    }
  }

  Future<bool?> _askConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.tileColor,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        title: Text(
          'Emin misin?',
          style: dialogContext.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${event.name} etkinliğine katılım kaydın oluşturulacak.',
          style: dialogContext.textTheme.bodyMedium?.copyWith(
            color: dialogContext.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Vazgeç',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: dialogContext.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Onayla',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: dialogContext.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
