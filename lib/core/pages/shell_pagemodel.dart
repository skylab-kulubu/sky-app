part of 'shell_page.dart';

abstract class ShellPagemodel extends State<ShellPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  /// Etkinlikler sekmesindeki arama kutusu açık mı.
  bool isSearchOpen = false;

  /// Core'a göre giriş alınabilecek yaklaşan bir etkinlik var mı
  /// (`/v1/door/events`). Grubunda `team_door_scan` açık ekiplerin üyeleri
  /// yalnızca buradan anlaşılıyor; token'da görünmüyor.
  bool _hasDoorEvents = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    unawaited(_checkDoorEvents());

    // "Ekibi Düzenle" satırı için ekiplerin CMS kaydı gerekiyor; Ekipler
    // sekmesi hiç açılmadan da menüde görünsün. Kare bitişi bekleniyor:
    // yükleme senkron bir `notifyListeners` ile başlıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<UserProvider>().user;
      if (user == null || user.leaderTeams.isEmpty) return;
      unawaited(context.read<TeamProvider>().ensureLoaded());
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkDoorEvents() async {
    try {
      final events = await DoorService().fetchDoorEvents();
      if (!mounted) return;
      setState(() => _hasDoorEvents = events.any((e) => e.isUpcoming));
    } catch (e) {
      // Yerel yetki kuralı yine çalışıyor; sessizce geçiliyor.
      log('Kapı etkinlikleri alınamadı: $e');
    }
  }

  /// Navbar'ın yanındaki yönetim menüsünün satırları; kullanıcının yetkisi
  /// olan işler. Boşsa menü butonu hiç görünmüyor.
  ///
  /// Yetkiler backend'in kurallarının uygulamadaki karşılıkları (bkz.
  /// `User`); asıl kontrol yine backend'de.
  List<NavMenuAction> adminActions(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const [];

    // Yerel kural (token'daki gruplar + etkinlik listesi) anında sonuç
    // veriyor; core'un listesi gelince team_door_scan üyeleri de ekleniyor.
    final canCheckIn =
        _hasDoorEvents ||
        context.watch<EventProvider>().upcomingEvents.any(
          (event) => user.canCheckIn(
            ownerTeam: event.ownerTeam,
            doorStaffIds: event.doorStaffIds,
          ),
        );

    final editableTeams = context
        .watch<TeamProvider>()
        .teamsOf(user.leaderTeams)
        .where((team) => user.canEditTeam(team.key))
        .toList();

    return [
      if (user.canManageNews)
        NavMenuAction(
          icon: AppIcons.createNews,
          label: 'Haber Oluştur',
          onTap: () => NewsEditPage.open(context),
        ),
      if (user.canCreateEvent)
        NavMenuAction(
          icon: AppIcons.calendarAdd,
          label: 'Etkinlik Oluştur',
          onTap: _onCreateEvent,
        ),
      if (canCheckIn)
        NavMenuAction(
          icon: AppIcons.checkIn,
          label: 'Giriş Al',
          onTap: () => DoorScannerPage.open(context),
        ),
      // Birden fazla ekibin lideriyse her ekip ayrı satır, adıyla.
      for (final team in editableTeams)
        NavMenuAction(
          icon: AppIcons.edit,
          label: editableTeams.length == 1
              ? 'Ekibi Düzenle'
              : '${team.name} Düzenle',
          onTap: () => TeamEditPage.open(context, team.slug),
        ),
    ];
  }

  /// Oluşturma sayfasını açar; etkinlik oluşturulduysa detayına geçer.
  Future<void> _onCreateEvent() async {
    final event = (await EventCreatePage.open(context))?.event;
    if (event == null || !mounted) return;
    await EventDetailPage.open(context, event);
  }

  /// Arama metni doğrudan provider'a gidiyor; liste yazdıkça süzülüyor.
  void _onSearchChanged() {
    context.read<EventProvider>().setSearchQuery(searchController.text);
  }

  /// Kutu açılıyor; klavye, genişleme bitince [AppBarSearchField] içinde
  /// açılıyor.
  void openSearch() => setState(() => isSearchOpen = true);

  /// Kutu kapanırken arama da temizleniyor: kapalı bir kutunun arkasında
  /// süzülmüş bir liste kalmamalı.
  void closeSearch() {
    searchFocusNode.unfocus();
    searchController.clear();
    setState(() => isSearchOpen = false);
  }

  /// Sekme değişince açık arama kapanıyor; geri dönüldüğünde liste tam ve
  /// başlık yerinde olmalı.
  ///
  /// `build` içinden çağrılıyor, bu yüzden kapatma bir sonraki kareye
  /// bırakılıyor: temizlik provider'ı bilgilendiriyor ve build sırasında
  /// bildirim hata veriyor.
  void closeSearchIfLeftCalendar(String location) {
    if (!isSearchOpen || location.startsWith('/calendar')) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isSearchOpen) closeSearch();
    });
  }
}
