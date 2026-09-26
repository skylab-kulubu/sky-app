part of 'settings_page.dart';

abstract class SettingsPagemodel extends State<SettingsPage> {
  void onLogoutTap() async {
    await context.read<UserProvider>().logout();
    if (mounted) context.go('/auth');
  }

  /// Hesap bilgileri, güvenlik, oturumlar ve kulüp profili Hesap
  /// Merkezi'nde; uygulama onu kendi WebView'inde açıyor.
  void onAccountTap() =>
      HandoffSheet.show(context, target: HandoffTarget.accountCenter);

  void onSupportTap() => context.push('/settings/contact');

  void onWebsiteTap() => WebviewService.openLink(context, LinksService.website);

  /// Tarayıcı sayfası olarak açılıyor; Gizlilik Politikası ve KVKK metni
  /// oradan seçiliyor.
  void onLegalTap() => WebviewService.openLink(context, LinksService.legal);

  void onAppearanceTap() => ThemeModeSheet.show(context);
}
