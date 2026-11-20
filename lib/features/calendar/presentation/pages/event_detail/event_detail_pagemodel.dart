part of 'event_detail_page.dart';

abstract class EventDetailPagemodel extends State<EventDetailPage> {
  final ScrollController scrollController = ScrollController();

  /// İstek sürerken buton kilitli kalıyor; çift kayıt oluşmasın diye.
  bool isJoining = false;

  /// Yayınlama, iptal gibi durum isteği sürüyor.
  bool isUpdatingStatus = false;

  /// Kullanıcının bileti var mı; bilinmiyorsa (girişsiz, hata) `null`.
  bool? hasTicket;

  final EventService _eventService = EventService();
  final EventStatusService _statusService = EventStatusService();

  /// Kapaktan çıkarılan renkler; çözülene kadar boş, zemin düz taban.
  List<Color> backdropTints = const [];

  late EventModel event = widget.event;

  /// Kapağın adresleri bundan okunuyor; yalnız asıl kapak değişince
  /// güncelleniyor. Yeniden okunan yanıttaki boyut adresleri listedekinden
  /// farklı olunca görsel baştan yükleniyor ve titriyordu.
  late EventModel coverSource = widget.event;

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

  Future<void> _loadTicket() async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    if (userId.isEmpty || event.isDraft) return;
    final result = await _eventService.hasTicket(
      userId: userId,
      eventId: event.id,
    );
    if (!mounted) return;
    setState(() => hasTicket = result);
  }

  Future<void> onManagePressed() async {
    final action = await EventManageSheet.show(context, event);
    if (action == null || !mounted) return;

    switch (action) {
      case EventManageAction.edit:
        await onEditPressed();
      case EventManageAction.publish:
        await onPublishPressed();
      case EventManageAction.unpublish:
        await _onUnpublish();
      case EventManageAction.cancel:
        await _onCancel();
      case EventManageAction.uncancel:
        await _onUncancel();
      case EventManageAction.copy:
        await _onCopy();
    }
  }

  Future<void> onPublishPressed() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Etkinlik yayınlansın mı?',
      message: '${event.name} herkese görünecek ve başvurular açılacak.',
      confirmLabel: 'Yayınla',
      confirmColor: AppColors.green,
    );
    if (!confirmed || !mounted) return;
    await _changeStatus(
      () => _statusService.publish(event.id),
      'Etkinlik yayınlandı.',
    );
  }

  Future<void> _onUnpublish() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Taslağa alınsın mı?',
      message:
          '${event.name} listelerden kalkacak; yalnız düzenleyebilenler '
          'görecek.',
      confirmLabel: 'Taslağa Al',
      confirmColor: AppColors.orange,
    );
    if (!confirmed || !mounted) return;
    await _changeStatus(
      () => _statusService.unpublish(event.id),
      'Etkinlik taslağa alındı.',
    );
  }

  Future<void> _onCancel() async {
    final choice = await EventCancelDialog.show(context, eventName: event.name);
    if (choice == null || !mounted) return;
    await _changeStatus(
      () => _statusService.cancel(
        event.id,
        reason: choice.reason,
        notify: choice.notify,
      ),
      'Etkinlik iptal edildi.',
    );
  }

  /// İptal e-postası gittiyse aynı kişilere "geri geldi" e-postası da gidiyor.
  Future<void> _onUncancel() async {
    final notify = event.cancelNotified;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'İptal geri alınsın mı?',
      message: [
        '${event.name} yeniden yayına alınacak.',
        if (notify) 'İptal e-postası alanlara tekrar haber verilecek.',
      ].join(' '),
      confirmLabel: 'Geri Al',
      confirmColor: AppColors.green,
    );
    if (!confirmed || !mounted) return;
    await _changeStatus(
      () => _statusService.uncancel(event.id, notify: notify),
      'İptal geri alındı.',
    );
  }

  /// Kopya taslak olarak açılıyor; geri tuşu kaynağa dönüyor.
  Future<void> _onCopy() async {
    final choice = await EventCopyDialog.show(context, source: event);
    if (choice == null || !mounted) return;

    setState(() => isUpdatingStatus = true);
    try {
      final copy = await _statusService.copy(
        event.id,
        name: choice.name,
        startDate: choice.startDate,
      );
      if (!mounted) return;
      setState(() => isUpdatingStatus = false);
      unawaited(context.read<EventProvider>().refresh());
      _showMessage('Kopya taslak olarak oluşturuldu.');
      await EventDetailPage.open(context, copy);
    } catch (e) {
      _onStatusError(e);
    }
  }

  Future<void> _changeStatus(
    Future<EventModel> Function() request,
    String successMessage,
  ) async {
    setState(() => isUpdatingStatus = true);
    try {
      final updated = await request();
      if (!mounted) return;
      setState(() {
        event = updated;
        isUpdatingStatus = false;
      });
      unawaited(context.read<EventProvider>().refresh());
      _showMessage(successMessage);
    } catch (e) {
      _onStatusError(e);
    }
  }

  void _onStatusError(Object e) {
    final error = ApiException.from(e);
    log('Etkinlik durumu değiştirilemedi: $error');
    if (!mounted) return;
    setState(() => isUpdatingStatus = false);
    _showMessage(EventStatusService.messageFor(error));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
    if (updated != null) _applyUpdated(updated);
  }

  /// Liste eski olabilir (bu arada iptal edilmiş, başvurusu kapanmış); sayfa
  /// açılınca etkinlik sessizce yeniden okunuyor. Hata olursa eldeki kalıyor.
  Future<void> _refreshEvent() async {
    try {
      final fresh = await _eventService.fetchEvent(event.id);
      if (mounted) _applyUpdated(fresh);
    } catch (e) {
      log('Etkinlik yenilenemedi: $e');
    }
  }

  void _applyUpdated(EventModel updated) {
    // Kapak değiştiyse zemin yeni görselin renklerine geçiyor.
    final coverChanged = updated.coverImageUrl != event.coverImageUrl;
    setState(() {
      event = updated;
      if (coverChanged) {
        coverSource = updated;
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
    _loadTicket();
    _refreshEvent();
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

  /// Taslağı düzenleyebilene buton "Yayınla"; bileti olana "Kayıtlısın".
  bool get _publishFromBar => event.isDraft && canEdit;

  bool get _showRegistered =>
      hasTicket == true &&
      (event.phase == EventPhase.open || event.phase == EventPhase.closed);

  String get joinButtonLabel {
    if (_publishFromBar) return 'Yayınla';
    if (_showRegistered) return 'Kayıtlısın';
    return switch (event.phase) {
      EventPhase.open => 'Katıl',
      EventPhase.closed => 'Başvuru Kapalı',
      EventPhase.ended => 'Etkinlik Bitti',
      EventPhase.draft => 'Yayında Değil',
      EventPhase.cancelled => 'İptal Edildi',
    };
  }

  /// `null` ise buton pasif.
  VoidCallback? get joinButtonAction {
    if (_publishFromBar) return onPublishPressed;
    if (_showRegistered || event.phase != EventPhase.open) return null;
    return onJoinPressed;
  }

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

    _showMessage(result.message);
    if (result.hasTicket) {
      setState(() => hasTicket = true);
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
