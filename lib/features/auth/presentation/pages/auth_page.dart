import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/features/auth/presentation/widgets/app_button.dart';
import 'package:sky_app/features/auth/presentation/widgets/sky_textfield.dart';
import 'package:go_router/go_router.dart';

part 'auth_pagemodel.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends AuthPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      _buildPrimaryLoginButton(),
                      const SizedBox(height: 32),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildExtraOptions(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- EXTRACT METHODS ---

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 80),
        SvgPicture.asset(
          AppAssets.skylab,
          height: 150,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ), //pembe logoyu beyaza cevirmek icin kullandim
        ),
        const SizedBox(height: 24),
        const Text(
          'SKY LAB',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bilgisayar Bilimleri Kulübü',
          style: TextStyle(fontSize: 12, color: AppColors.unselectedLabelColor),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildPrimaryLoginButton() {
    return AppButton(
      text: 'YTÜ Mail ile Giriş Yap',
      //ytu logosu gelecek
      icon: const Text(
        'YTÜ',
        style: TextStyle(
          color: Color(0xFF1E529B),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      backgroundColor: AppColors.buttonColor,
      onPressed: handleNavigate,
    );
  }

  Widget _buildDivider() {
    return GestureDetector(
      onTap: toggleExtraOptions,
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.unselectedLabelColor, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text(
                  'YTÜ öğrencisi değil misin?',
                  style: TextStyle(
                    color: AppColors.unselectedLabelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  showExtraOptions
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.unselectedLabelColor,
                  size: 16,
                ),
              ],
            ),
          ),
          const Expanded(
            child: Divider(color: AppColors.unselectedLabelColor, thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraOptions() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showExtraOptions
          ? Column(
              children: [
                AppButton(
                  text: 'Google ile Giriş Yap',
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.white,
                    size: 28,
                  ),
                  backgroundColor: AppColors.buttonColor,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'E-posta ile Giriş Yap',
                  icon: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  backgroundColor: AppColors.buttonColor,
                  onPressed: selectEmailLogin,
                ),
                if (emailSelected) _buildEmailForm(),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        const SizedBox(height: 24),
        SkyTextfield(hintText: 'E-posta', controller: emailController),
        const SizedBox(height: 16),
        SkyTextfield(
          hintText: 'Şifre',
          obscureText: obscurePassword,
          controller: passwordController,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.unselectedLabelColor,
              size: 20,
            ),
            onPressed: toggleObscurePassword,
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Giriş Yap',
          backgroundColor: AppColors.primaryColor,
          onPressed: handleNavigate,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {},
          child: const Text.rich(
            TextSpan(
              text: 'Hesabın yok mu? ',
              style: TextStyle(
                color: AppColors.unselectedLabelColor,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: 'Kayıt ol',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Developed by ',
            style: TextStyle(
              color: AppColors.unselectedLabelColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          SvgPicture.asset(
            AppAssets.mobilab,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.unselectedLabelColor,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
