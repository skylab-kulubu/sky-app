part of 'auth_page.dart';

abstract class AuthPagemodel extends State<AuthPage> {
  /// İstek sürerken buton kilitleniyor ve yerinde ilerleme göstergesi çiziyor.
  bool isLoading = false;

  Future<void> handleAuth() async {
    setState(() => isLoading = true);
    final success = await context.read<UserProvider>().login();
    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) context.go('/home');
  }
}
