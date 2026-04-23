part of 'auth_page.dart';

abstract class AuthPagemodel extends State<AuthPage> {
  bool showExtraOptions = false;
  bool emailSelected = false;
  bool obscurePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- FONKSİYONLAR ---

  void handleNavigate() {
    context.go('/home');  // sadece yönlendiriyor, mail kaydı yok
  }

  void toggleExtraOptions() {
    setState(() {
      showExtraOptions = !showExtraOptions;
      if (!showExtraOptions) emailSelected = false;
    });
  }

  void selectEmailLogin() {
    setState(() {
      emailSelected = true;
    });
  }

  void toggleObscurePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }
}
