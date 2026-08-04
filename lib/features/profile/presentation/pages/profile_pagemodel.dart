part of 'profile_page.dart';

abstract class ProfilePagemodel extends State<ProfilePage> {
  void onLogoutTap() async {
    await context.read<UserProvider>().logout();
    if (mounted) context.go('/auth');
  }
}
