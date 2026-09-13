part of 'contact_page.dart';

abstract class ContactPagemodel extends State<ContactPage> {
  static const String _email = 'info@yildizskylab.com';
  static const String _emailSubject = 'SkyApp Destek';

  /// Depodaki issue şablonlarından (hata, istek, arayüz) seçim ekranı.
  static const String _bugReportUrl =
      'https://github.com/skylab-kulubu/sky-app/issues/new/choose';
  static const String _instagramUrl = 'https://www.instagram.com/ytuskylab';
  static const String _linkedInUrl =
      'https://www.linkedin.com/company/ytuskylab/';

  /// Mail uygulamasını hazır konuyla açar. Gövdenin altına platform
  /// ekleniyor; bir sorun bildirildiğinde ilk sorulan şey bu.
  ///
  /// Cihazda mail uygulaması yoksa adres panoya kopyalanıyor; kullanıcı
  /// eli boş kalmasın.
  Future<void> onEmailTap() async {
    final body = '\n\n---\nPlatform: ${_platformName()}';
    // `queryParameters` boşlukları `+` yapıyor ve bazı mail uygulamaları
    // konuyu öyle gösteriyor; parçalar elle `%20` ile kodlanıyor.
    final uri = Uri.parse(
      'mailto:$_email'
      '?subject=${Uri.encodeComponent(_emailSubject)}'
      '&body=${Uri.encodeComponent(body)}',
    );

    if (await _launch(uri)) return;

    await Clipboard.setData(const ClipboardData(text: _email));
    _showMessage('Mail uygulaması bulunamadı, adres panoya kopyalandı.');
  }

  Future<void> onBugReportTap() => _openExternal(_bugReportUrl);

  Future<void> onInstagramTap() => _openExternal(_instagramUrl);

  Future<void> onLinkedInTap() => _openExternal(_linkedInUrl);

  /// Webview değil, dış uygulama: Instagram ve LinkedIn yüklüyse kendi
  /// uygulamalarında, değilse tarayıcıda açılıyor.
  Future<void> _openExternal(String url) async {
    if (await _launch(Uri.parse(url))) return;
    _showMessage('Bağlantı açılamadı.');
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _platformName() {
    if (kIsWeb) return 'Web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.android => 'Android',
      _ => defaultTargetPlatform.name,
    };
  }
}
