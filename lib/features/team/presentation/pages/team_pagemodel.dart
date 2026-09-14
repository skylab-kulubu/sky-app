part of 'team_page.dart';

abstract class TeamPagemodel extends State<TeamPage> {
  /// Ortadaki kartın ekran genişliğine oranı; kalan pay iki yandaki
  /// kartların görünen kısmı.
  static const double _viewportFraction = 0.82;

  /// Kartın genişlik/yükseklik oranı. 0.72'de uzun ekranlarda sayfa boş
  /// kalıyordu; bu oranda logo alanı dikey, kart ekranı dolduruyor.
  static const double _cardAspectRatio = 0.6;

  /// Sayfa göstergesinde aktif noktanın hap genişliği.
  static const double _activeDotWidth = 24;

  /// Kartlar arası boşluğun yarısı; her kart iki yanından bu kadar içeride.
  static const EdgeInsets _cardGap = EdgeInsets.symmetric(horizontal: 6);

  /// Yandaki kartın dönüşü ve küçülmesi.
  static const double _sideRotation = pi / 10; // 18°
  static const double _sideScaleLoss = 0.1;

  /// Perspektif katsayısı; etkinlik detayındaki SkyPass dönüşüyle aynı
  /// mertebede. Büyüdükçe yakın kenar abartılı büyüyor.
  static const double _perspective = 0.0008;

  final PageController pageController = PageController(
    viewportFraction: _viewportFraction,
  );

  /// Carousel'in anlık konumu (kesirli sayfa). Controller henüz bağlanmadan
  /// ilk karede 0.
  double get pageOffset {
    if (!pageController.hasClients || !pageController.position.haveDimensions) {
      return pageController.initialPage.toDouble();
    }
    return pageController.page ?? 0;
  }

  static const Duration _jumpDuration = Duration(milliseconds: 450);

  late final TeamProvider _teamProvider = context.read<TeamProvider>();

  /// Görülmüş son "ekibime git" isteği; açılışta bekleyen eski istekler
  /// tetiklenmesin diye mevcut sayaçla başlıyor. `initState`'te atanıyor:
  /// tembel başlatılsaydı ilk basışta artmış değeri okuyup isteği yutardı.
  late int _handledMyTeamRequests;

  @override
  void initState() {
    super.initState();
    _handledMyTeamRequests = _teamProvider.myTeamRequests;
    _teamProvider.addListener(_onTeamProviderChanged);
    // Yükleme senkron bir `notifyListeners` ile başlıyor; build fazında
    // çağrılmasın diye kare bitişi bekleniyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<TeamProvider>().ensureLoaded());
    });
  }

  @override
  void dispose() {
    _teamProvider.removeListener(_onTeamProviderChanged);
    pageController.dispose();
    super.dispose();
  }

  void onRetry() => context.read<TeamProvider>().refresh();

  void _onTeamProviderChanged() {
    if (_teamProvider.myTeamRequests == _handledMyTeamRequests) return;
    _handledMyTeamRequests = _teamProvider.myTeamRequests;
    _jumpToMyTeam();
  }

  /// Kullanıcının ekibine kayar. Birden fazla ekipteyse, şu anki karttan
  /// sonraki ilk ekibine; sonuncusundaysa baştakine döner.
  void _jumpToMyTeam() {
    if (!mounted || !pageController.hasClients) return;

    final roles = context.read<UserProvider>().user?.realmRoles ?? const [];
    final teams = _teamProvider.teams;
    final myIndexes = [
      for (final team in _teamProvider.teamsOf(roles)) teams.indexOf(team),
    ];
    if (myIndexes.isEmpty) return;

    final current = pageOffset.round();
    final target = myIndexes.firstWhere(
      (index) => index > current,
      orElse: () => myIndexes.first,
    );
    _animateTo(target);
  }

  /// Üstteki karttaki ekip hapına dokununca carousel o ekibe kayar.
  void jumpToTeam(Team team) {
    final index = _teamProvider.teams.indexWhere((t) => t.slug == team.slug);
    if (index >= 0) _animateTo(index);
  }

  void _animateTo(int index) {
    if (!pageController.hasClients || index == pageOffset.round()) return;

    pageController.animateToPage(
      index,
      duration: _jumpDuration,
      curve: Curves.easeInOutCubic,
    );
  }
}
