part of 'auth_page.dart';

abstract class AuthPagemodel extends State<AuthPage> {
  bool isLoading = false;

  Future<void> handleAuth() async {
    setState(() => isLoading = true);
    final success = await context.read<UserProvider>().login();
    setState(() => isLoading = false);

    if (success && mounted) {
      context.go('/home');
    }
  }
}
