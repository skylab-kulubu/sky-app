part of 'event_create_page.dart';

abstract class EventCreatePagemodel extends State<EventCreatePage> {
  final EventCreateService _service = EventCreateService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController formUrlController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();

  /// Varsayılan süre; başlangıç değişince bitiş bu kadar ileri kayıyor.
  static const Duration _defaultDuration = Duration(hours: 2);

  XFile? cover;

  late DateTime startDate = _nextFullHour();
  late DateTime endDate = startDate.add(_defaultDuration);

  EventModel? get _editing => widget.event;
  bool get isEditing => _editing != null;

  late final User? _user = context.read<UserProvider>().user;

  /// Düzenlemede etkinliğin ekibi listede yoksa (ör. GECEKODU üyesi) başa
  /// ekleniyor ki alan boş kalmasın.
  late final List<String> ownerOptions = () {
    final options = _user?.eventOwnerOptions ?? const <String>[];
    final current = _editing?.ownerTeam ?? '';
    if (current.isEmpty || options.contains(current)) return options;
    return [current, ...options];
  }();

  late String? ownerTeam = isEditing
      ? _editing!.ownerTeam
      : (ownerOptions.isEmpty ? null : ownerOptions.first);

  /// Core yalnız taslağı sildiriyor (`409 event_not_draft`); YK/ADMIN her
  /// etkinliği. Yayındaki etkinlik yönetim menüsünden iptal ediliyor.
  bool get canDelete {
    final editing = _editing;
    final user = _user;
    if (editing == null || user == null) return false;
    return user.canDeleteEvent(editing.ownerTeam) &&
        (editing.isDraft || user.canWriteAsPrivileged);
  }

  /// Sezon satırı yalnız YK/ADMIN'de; diğerlerinde etkinlik sezonsuz oluşuyor.
  late final bool canChooseSeason = _user?.canWriteAsPrivileged ?? false;

  /// Yeni görsel seçilmediyse önizlemede mevcut kapak.
  String get currentCoverUrl => _editing?.coverPageUrl ?? '';

  List<Season> seasons = const [];
  Season? season;
  late bool isLoadingSeasons = canChooseSeason;

  int capacity = 0;

  /// Core'a tersi `registrationClosed` olarak gidiyor.
  bool registrationOpen = true;

  /// Yalnız oluştururken: kapalıysa taslak olarak kaydediliyor ve sonra
  /// yönetim menüsünden yayınlanıyor.
  bool publishNow = true;
  bool isSaving = false;
  bool isDeleting = false;

  bool get isBusy => isSaving || isDeleting;

  @override
  void initState() {
    super.initState();
    final event = _editing;
    if (event != null) {
      nameController.text = event.name;
      locationController.text = event.location;
      descriptionController.text = event.description;
      formUrlController.text = event.formUrl;
      linkedinController.text = event.linkedin;
      capacity = event.capacity;
      registrationOpen = !event.registrationClosed;
      final start = event.startDateTime;
      final end = event.endDateTime;
      if (start != null) startDate = start;
      if (end != null) endDate = end;
    }
    if (canChooseSeason) _loadSeasons();
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    formUrlController.dispose();
    linkedinController.dispose();
    super.dispose();
  }

  static DateTime _nextFullHour() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  Future<void> _loadSeasons() async {
    try {
      final result = await _service.fetchSeasons();
      if (!mounted) return;
      setState(() {
        seasons = result;
        // Düzenlemede etkinliğin sezonu; oluştururken aktif sezon, yoksa ilki.
        final editingSeasonId = _editing?.seasonId ?? '';
        season =
            result.where((s) => s.id == editingSeasonId).firstOrNull ??
            result.where((s) => s.active).firstOrNull ??
            result.firstOrNull;
        isLoadingSeasons = false;
      });
    } catch (e) {
      log('Sezonlar alınamadı: $e');
      if (!mounted) return;
      setState(() => isLoadingSeasons = false);
    }
  }

  String get seasonLabel {
    if (isLoadingSeasons) return 'Yükleniyor…';
    return season?.name ?? (seasons.isEmpty ? 'Sezon yok' : 'Seç');
  }

  /// Zorunlular: ad, konum, sahip ekip ve bitişin başlangıçtan sonra olması.
  /// Sezon isteğe bağlı.
  bool get canSubmit =>
      !isBusy &&
      nameController.text.trim().isNotEmpty &&
      locationController.text.trim().isNotEmpty &&
      ownerTeam != null &&
      endDate.isAfter(startDate);

  void onFormChanged() => setState(() {});

  Future<void> onPickCover() async {
    try {
      final picked = await MediaService.pickImage();
      if (picked == null || !mounted) return;
      setState(() => cover = picked);
    } on PlatformException catch (e) {
      log('Görsel seçilemedi: $e');
      _showMessage('Galeriye erişilemedi. İzinleri kontrol et.');
    }
  }

  String dateTimeLabel(DateTime value) => shortDateTimeLabel(value);

  void onRegistrationOpenChanged(bool value) =>
      setState(() => registrationOpen = value);

  void onPublishNowChanged(bool value) => setState(() => publishNow = value);

  /// Tarihte vazgeçilirse bir şey değişmiyor; saatte vazgeçilirse gün eski
  /// saatle kalıyor.
  Future<void> onPickDateTime({required bool isStart}) async {
    final value = await pickDateTime(context, isStart ? startDate : endDate);
    if (value == null || !mounted) return;
    _setDateTime(isStart: isStart, value: value);
  }

  /// Başlangıç değişince bitiş aynı süreyle kayıyor. Bitiş başlangıcın önüne
  /// alınırsa satır kırmızı ve "Oluştur" pasif.
  void _setDateTime({required bool isStart, required DateTime value}) {
    setState(() {
      if (isStart) {
        final duration = endDate.difference(startDate);
        startDate = value;
        endDate = value.add(
          duration.isNegative || duration == Duration.zero
              ? _defaultDuration
              : duration,
        );
      } else {
        endDate = value;
      }
    });
  }

  Future<void> onEditSchedule() async {
    final editing = _editing;
    if (editing == null) return;
    await EventSchedulePage.open(context, editing);
  }

  Future<void> onChooseOwner() async {
    if (ownerOptions.length <= 1) return;

    final index = await EventOptionSheet.show(
      context,
      title: 'Sahip Ekip',
      options: ownerOptions,
      selectedIndex: ownerTeam == null
          ? null
          : ownerOptions.indexOf(ownerTeam!),
      icon: AppIcons.users2,
      iconColor: AppColors.blue,
    );
    if (index == null || !mounted) return;
    setState(() => ownerTeam = ownerOptions[index]);
  }

  Future<void> onChooseSeason() async {
    if (seasons.isEmpty) return;

    final index = await EventOptionSheet.show(
      context,
      title: 'Sezon',
      options: [for (final s in seasons) s.name],
      selectedIndex: season == null ? null : seasons.indexOf(season!),
      icon: AppIcons.calendar,
      iconColor: AppColors.purple,
    );
    if (index == null || !mounted) return;
    setState(() => season = seasons[index]);
  }

  /// Boş ya da 0 sınırsız.
  Future<void> onEditCapacity() async {
    final result = await EventCapacityDialog.show(
      context,
      initialValue: capacity,
    );
    if (result == null || !mounted) return;
    setState(() => capacity = result);
  }

  Future<void> onSubmit() async {
    final ownerTeam = this.ownerTeam;
    if (ownerTeam == null) return;

    setState(() => isSaving = true);

    try {
      final cover = this.cover;
      final coverId = cover == null ? null : await _service.uploadCover(cover);

      final draft = EventDraft(
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        ownerTeam: ownerTeam,
        startDate: startDate,
        endDate: endDate,
        description: descriptionController.text.trim(),
        formUrl: formUrlController.text.trim(),
        linkedin: linkedinController.text.trim(),
        capacity: capacity,
        registrationClosed: !registrationOpen,
        coverImageId: coverId,
      );

      final editing = _editing;
      final EventModel saved;
      if (editing != null) {
        saved = await _updateAndAssign(editing, draft);
      } else {
        saved = await _service.createEvent(
          draft,
          seasonId: canChooseSeason ? season?.id : null,
          asDraft: !publishNow,
        );
      }
      if (!mounted) return;

      // Listeler yeni hâli göstersin; sonuç beklenmiyor.
      context.read<EventProvider>().refresh();
      Navigator.of(context).pop(EventFormResult.saved(saved));
    } catch (e) {
      final error = ApiException.from(e);
      log('Etkinlik kaydedilemedi: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      _showMessage(_errorMessage(error));
    }
  }

  /// Sezon değiştiyse (yalnız YK/ADMIN) yeniden bağlar; bağlama düşerse
  /// güncelleme yine geçerli, sezon eski kalıyor.
  Future<EventModel> _updateAndAssign(
    EventModel editing,
    EventDraft draft,
  ) async {
    final updated = await _service.updateEvent(editing, draft);
    final seasonId = season?.id;
    if (!canChooseSeason || seasonId == null || seasonId == editing.seasonId) {
      return updated;
    }

    try {
      return await _service.assignSeason(updated.id, seasonId);
    } on ApiException catch (e) {
      log('Sezona bağlanamadı: $e');
      return updated;
    }
  }

  String _errorMessage(ApiException error) {
    return switch (error.statusCode) {
      403 => 'Bu ekip adına etkinlik yönetme yetkin yok.',
      400 => 'Etkinlik kaydedilemedi; alanları kontrol et.',
      _ => error.userMessage,
    };
  }

  /// Onaydan sonra siler.
  Future<void> onDeletePressed() async {
    final editing = _editing;
    if (editing == null) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Etkinlik silinsin mi?',
      message: '${editing.name} taslağı silinecek.',
    );
    if (!confirmed || !mounted) return;

    setState(() => isDeleting = true);
    try {
      await _service.deleteEvent(editing.id);
      if (!mounted) return;
      context.read<EventProvider>().refresh();
      Navigator.of(context).pop(const EventFormResult.deleted());
    } catch (e) {
      final error = ApiException.from(e);
      log('Etkinlik silinemedi: $error');
      if (!mounted) return;
      setState(() => isDeleting = false);
      _showMessage(switch (error.statusCode) {
        403 => 'Bu etkinliği silme yetkin yok.',
        // Bu arada yayınlanmış olabilir (`event_not_draft`).
        409 => 'Yayındaki etkinlik silinemez; iptal edebilirsin.',
        _ => error.userMessage,
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
