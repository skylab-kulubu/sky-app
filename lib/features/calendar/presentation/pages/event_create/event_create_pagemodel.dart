part of 'event_create_page.dart';

abstract class EventCreatePagemodel extends State<EventCreatePage> {
  final EventCreateService _service = EventCreateService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController formUrlController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();

  /// Varsayılan etkinlik süresi; bitiş, başlangıç değişince bu kadar ileri
  /// kayıyor.
  static const Duration _defaultDuration = Duration(hours: 2);

  /// Kapak kalitesi: afişler çoğu zaman çok büyük geliyor; bu sınırlarla
  /// yükleme hızlı, görünüm etkilenmiyor.
  static const double _coverMaxSide = 2000;
  static const int _coverQuality = 85;

  XFile? cover;

  late DateTime startDate = _nextFullHour();
  late DateTime endDate = startDate.add(_defaultDuration);

  EventModel? get _editing => widget.event;
  bool get isEditing => _editing != null;

  late final User? _user = context.read<UserProvider>().user;

  /// Seçilebilir sahip ekipler. Düzenlemede etkinliğin mevcut ekibi listede
  /// yoksa (ör. GECEKODU üyesi) başa ekleniyor ki alan boş kalmasın.
  late final List<String> ownerOptions = () {
    final options = _user?.eventOwnerOptions ?? const <String>[];
    final current = _editing?.ownerTeam ?? '';
    if (current.isEmpty || options.contains(current)) return options;
    return [current, ...options];
  }();

  late String? ownerTeam = isEditing
      ? _editing!.ownerTeam
      : (ownerOptions.isEmpty ? null : ownerOptions.first);

  /// Silme yalnızca liderlere ve YK/DK/ADMIN'e; GECEKODU üyeleri silemiyor.
  bool get canDelete =>
      isEditing && (_user?.canDeleteEvent(_editing!.ownerTeam) ?? false);

  /// Etkinliği sezona yalnızca YK/DK/ADMIN bağlayabiliyor; diğerlerinde
  /// sezon satırı görünmüyor ve etkinlik sezonsuz oluşuyor.
  late final bool canChooseSeason = _user?.isPrivileged ?? false;

  /// Düzenlenen etkinliğin mevcut kapağı; yeni görsel seçilmediyse
  /// önizlemede bu görünüyor.
  String get currentCoverUrl => _editing?.coverImageUrl ?? '';

  List<Season> seasons = const [];
  Season? season;
  late bool isLoadingSeasons = canChooseSeason;

  int capacity = 0;
  bool isActive = true;
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
      isActive = event.active;
      capacity = event.capacity;
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
        // Düzenlemede etkinliğin sezonu; oluştururken aktif sezon varsa o,
        // yoksa ilki (çoğu zaman tek aktif sezon var).
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
  /// Sezon isteğe bağlı (bağlamayı YK panelden de yapabiliyor). Tarihler
  /// varsayılanla dolu geldiği için ayrıca boş kontrolü yok.
  bool get canSubmit =>
      !isBusy &&
      nameController.text.trim().isNotEmpty &&
      locationController.text.trim().isNotEmpty &&
      ownerTeam != null &&
      endDate.isAfter(startDate);

  void onFormChanged() => setState(() {});

  void onActiveChanged(bool value) => setState(() => isActive = value);

  Future<void> onPickCover() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: _coverMaxSide,
        maxHeight: _coverMaxSide,
        imageQuality: _coverQuality,
      );
      if (picked == null || !mounted) return;
      setState(() => cover = picked);
    } on PlatformException catch (e) {
      // Galeri izni reddedildiğinde buraya düşüyor.
      log('Görsel seçilemedi: $e');
      _showMessage('Galeriye erişilemedi. İzinleri kontrol et.');
    }
  }

  static const List<String> _months = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', //
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  /// "14 Eyl · 21:00"
  String dateTimeLabel(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.day} ${_months[value.month - 1]} · '
        '${two(value.hour)}:${two(value.minute)}';
  }

  /// Önce tarih, ardından saat seçtirir. Tarihte vazgeçilirse hiçbir şey
  /// değişmez; saatte vazgeçilirse seçilen gün eski saatle kalır.
  Future<void> onPickDateTime({required bool isStart}) async {
    final current = isStart ? startDate : endDate;
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!mounted) return;

    final hour = time?.hour ?? current.hour;
    final minute = time?.minute ?? current.minute;
    _setDateTime(
      isStart: isStart,
      value: DateTime(date.year, date.month, date.day, hour, minute),
    );
  }

  /// Başlangıç değişince bitiş aynı süreyle kayıyor. Bitiş başlangıcın
  /// önüne alınırsa "Bitiş" satırı kırmızı olur ve "Oluştur" pasifleşir.
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

  /// Kontenjan: boş ya da 0 sınırsız.
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
        active: isActive,
        description: descriptionController.text.trim(),
        formUrl: formUrlController.text.trim(),
        linkedin: linkedinController.text.trim(),
        capacity: capacity,
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

  /// Günceller; sezon değiştiyse (yalnızca YK/DK/ADMIN) yeni sezona bağlar.
  /// Bağlama düşerse güncelleme yine geçerli, sezon eski kalıyor.
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

  /// Onaydan sonra siler. Core etkinlikle birlikte biletleri, yoklamaları
  /// ve sertifikaları da siliyor; onay metni bunu söylüyor.
  Future<void> onDeletePressed() async {
    final editing = _editing;
    if (editing == null) return;

    final confirmed = await _confirmDelete(editing);
    if (confirmed != true || !mounted) return;

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
        _ => error.userMessage,
      });
    }
  }

  Future<bool?> _confirmDelete(EventModel event) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.tileColor,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        title: Text(
          'Etkinlik silinsin mi?',
          style: dialogContext.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${event.name} kalıcı olarak silinecek. Etkinliğe ait kayıtlar, '
          'yoklamalar ve sertifikalar da silinir. Bu işlem geri alınamaz.',
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
              'Sil',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
