part of 'event_detail_page.dart';

abstract class EventDetailPagemodel extends State<EventDetailPage> {
  final ScrollController scrollController = ScrollController();

  /// İstek sürerken buton kilitli kalıyor; çift kayıt oluşmasın diye.
  bool isJoining = false;

  /// Kapak görselinden çıkarılan renkler; sayfanın zemini bunlardan
  /// türetiliyor. Palet çözülene kadar boş, o sürede zemin düz taban rengi.
  List<Color> backdropTints = const [];

  EventModel get event => widget.event;

  @override
  void initState() {
    super.initState();

    // Renkler kart göründüğünde hesaplanmaya başlamıştı; çoğu zaman burada
    // hazır ve zemin ilk karede doğru renkte açılıyor.
    backdropTints = EventPaletteService.cached(event.id);

    // Hazır değilse beklemek gerekiyor ama sayfa açılırken değil: palet
    // çıkarımı ana iş parçacığında çalıştığı için açılış animasyonunu
    // takıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterTransition());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Renk hesabını açılış animasyonu bittikten sonra başlatır.
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

  /// Zemin renklerini bekler.
  ///
  /// Hesabın kendisi [EventPaletteService]'te; buraya yalnızca sonucu
  /// almak kalıyor. Kart göründüğünde başlatıldığı için bu çağrı çoğu zaman
  /// süren bir işe bağlanıyor, yenisini başlatmıyor.
  Future<void> _resolveBackdropTint() async {
    final tints = await EventPaletteService.resolve(
      eventId: event.id,
      imageUrl: event.coverImageUrl,
    );

    // Görsel indirilemediyse zemin düz taban renginde kalır; sayfanın geri
    // kalanı bundan etkilenmiyor.
    if (!mounted || tints.isEmpty) return;
    setState(() => backdropTints = tints);
  }

  String get joinButtonLabel => event.active ? 'Katıl' : 'Başvuru Kapalı';

  /// Etkinliği sistem paylaşım sayfasıyla paylaşır.
  ///
  /// Metin, etkinliğin kendi sayfası olmadığı için elle kuruluyor: ad, tarih,
  /// konum ve varsa başvuru bağlantısı.
  Future<void> onSharePressed() async {
    final lines = <String>[
      event.name,
      [
        event.formattedDayLabel,
        event.formattedTimeRange,
      ].where((part) => part.isNotEmpty).join(' · '),
      event.location,
      event.formUrl,
    ].where((line) => line.isNotEmpty);

    await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  /// Katılım kaydı geri alınamadığı için önce onay soruluyor.
  Future<void> onJoinPressed() async {
    final confirmed = await _askConfirmation();
    if (confirmed != true || !mounted) return;

    setState(() => isJoining = true);
    final joined = await context.read<EventProvider>().joinEvent(event.id);
    if (!mounted) return;
    setState(() => isJoining = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          joined ? 'Kaydın başarıyla alındı!' : 'Katılım kaydı oluşturulamadı.',
        ),
      ),
    );
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
