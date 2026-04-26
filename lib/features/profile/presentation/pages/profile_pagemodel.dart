part of 'profile_page.dart';

abstract class ProfilePageModel extends State<ProfilePage> {
  void onLogoutTap() async {
    await context.read<UserProvider>().logout();
    if (mounted) context.go('/auth');
  }
}
