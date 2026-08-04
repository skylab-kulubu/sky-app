part of 'auth_page.dart';

abstract class AuthPagemodel extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;

  late final AnimationController pressController;

  @override
  void initState() {
    super.initState();
    pressController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    pressController.dispose();
    super.dispose();
  }

  void animatePress(bool pressed) {
    final target = pressed ? 1.0 : 0.0;
    pressController.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 520, damping: 32),
        pressController.value,
        target,
        0,
      ),
    );
  }

  Future<void> handleAuth() async {
    animatePress(false);
    setState(() => isLoading = true);
    final success = await context.read<UserProvider>().login();
    setState(() => isLoading = false);

    if (success && mounted) {
      context.go('/home');
    }
  }
}
