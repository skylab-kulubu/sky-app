part of 'settings_page.dart';

abstract class SettingsPagemodel extends State<SettingsPage> {
  void onLogoutTap() async {
    await context.read<UserProvider>().logout();
    if (mounted) context.go('/auth');
  }

  void onSupportTap() => context.push('/settings/contact');

  void onWebsiteTap() => WebviewService.openLink(context, LinksService.website);

  // Sayfaları henüz yok; bağlanana kadar bir şey yapmıyorlar.
  void onNotificationsTap() {}

  void onPermissionsTap() {}
}
