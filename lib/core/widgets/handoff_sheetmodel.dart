part of 'handoff_sheet.dart';

abstract class HandoffSheetmodel extends State<HandoffSheet> {
  final HandoffService _service = HandoffService();

  HandoffTarget get target => widget.target;

  WebViewController? controller;
  bool isLoading = true;
  ApiException? error;

  /// Hata ekranında gösterilen açıklama; devir reddedilirse sebebini de
  /// yazıyor, Yusuf'a iletmek kolay olsun diye.
  String? errorDetail;

  /// WebView'in geri gidebileceği bir sayfa var mı; sistem geri tuşu buna
  /// göre sayfayı kapatıyor ya da geçmişte geziniyor.
  bool canGoBack = false;

  /// Kullanıcı sitede adını ya da kulüp profilini değiştirmiş olabilir;
  /// sheet kapanırken profil yeniden okunuyor.
  bool _profileNeedsReload = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _open();
  }

  Future<void> _open() async {
    setState(() {
      isLoading = true;
      error = null;
      errorDetail = null;
    });

    final Handoff handoff;
    try {
      handoff = await _service.start(target, path: widget.path);
    } catch (e) {
      final failure = ApiException.from(e);
      log('Devir bağlantısı alınamadı: $failure');
      if (!mounted) return;
      setState(() {
        error = failure;
        isLoading = false;
      });
      return;
    }
    if (!mounted) return;

    final created = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(context.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onUrlChange: (change) => _onUrlChange(change.url),
          onPageFinished: (_) => _onPageFinished(),
          onWebResourceError: _onWebResourceError,
        ),
      )
      // Kanıt başlığı yalnız bu ilk istekte gidiyor; sonraki yönlendirmelere
      // eklenmiyor. Kod tek kullanımlık ve 45 saniye geçerli, o yüzden her
      // açılışta yenisi alınıyor; adres ve kanıt saklanmıyor.
      ..loadRequest(Uri.parse(handoff.url), headers: handoff.headers);

    setState(() => controller = created);
  }

  /// Akış `my.` → `e.` → (gerekirse) Microsoft → `my.` zincirinde geziyor;
  /// bu adresler engellenmemeli. Dışarı çıkan bağlantılar (KVKK metni gibi)
  /// sistem tarayıcısında açılıyor.
  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    if (HandoffService.allowedHostsFor(target).contains(uri.host)) {
      return NavigationDecision.navigate;
    }

    // Alt kaynaklar (yazı tipi, görsel) serbest; yalnız üst seviye gezinme
    // dışarı taşınıyor.
    if (!request.isMainFrame) return NavigationDecision.navigate;

    unawaited(_openExternally(uri));
    return NavigationDecision.prevent;
  }

  Future<void> _openExternally(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log('Bağlantı açılamadı: $e');
    }
  }

  /// Devir başarısız olursa WebView sabit bir hata sayfasına gidiyor
  /// (yeni sözleşme) ya da Hesap Merkezi'nin giriş ekranına düşüyor (eski
  /// uç). İkisinde de kullanıcı çıkmaza giriyor; kendi hata ekranımızı
  /// gösterip yeniden denemesini sağlıyoruz.
  void _onUrlChange(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null) return;

    final String reason;
    if (uri.path == HandoffService.failedPath) {
      reason = uri.queryParameters['reason'] ?? 'unavailable';
    } else if (uri.host == Uri.parse(target.origin).host &&
        uri.path == '/login') {
      reason = uri.queryParameters['error'] ?? 'unavailable';
    } else {
      return;
    }

    log('Devir reddedildi: $reason');
    if (!mounted) return;
    setState(() {
      error = const ApiException(
        ApiErrorType.server,
        message: 'Devir reddedildi',
      );
      errorDetail =
          '${HandoffService.failureMessage(reason)} '
          'Tekrar denemek yeni bir bağlantı alır.';
      isLoading = false;
    });
  }

  Future<void> _onPageFinished() async {
    _profileNeedsReload = true;
    final history = await controller?.canGoBack() ?? false;
    if (!mounted) return;
    setState(() {
      isLoading = false;
      canGoBack = history;
    });
  }

  void _onWebResourceError(WebResourceError failure) {
    // Alt kaynak hataları sayfayı bozmuyor; yalnız ana çerçeve önemli.
    if (failure.isForMainFrame == false) return;
    log(
      'Hesap Merkezi yüklenemedi: ${failure.errorCode} ${failure.description}',
    );
    if (!mounted) return;
    setState(() {
      error = const ApiException(
        ApiErrorType.network,
        message: 'Sayfa yüklenemedi',
      );
      errorDetail = failure.description;
      isLoading = false;
    });
  }

  void onRetry() => _open();

  /// Sistem geri tuşu: önce sayfa geçmişi, sonra sheet kapanır.
  Future<void> onBack() async {
    if (await controller?.canGoBack() ?? false) {
      await controller?.goBack();
      return;
    }
    onClose();
  }

  /// Soldaki çarpı: nerede olursa olsun sheet'i kapatıyor.
  void onClose() {
    if (!mounted) return;
    _reloadProfile();
    Navigator.of(context).pop();
  }

  /// Kullanıcı oturumlarını kapattıysa token da geçersiz
  /// olabilir; bu çağrı ya profili tazeliyor ya da oturumu düşürüyor.
  void _reloadProfile() {
    if (!_profileNeedsReload) return;
    unawaited(context.read<UserProvider>().reloadProfile());
  }
}
