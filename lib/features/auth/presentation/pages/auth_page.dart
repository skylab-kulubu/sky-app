import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';

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
                    children: [_header(), SizedBox(height: 24), _loginButton()],
                  ),
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        const SizedBox(height: 80),
        SvgPicture.asset(AppAssets.skylab, height: 150),
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

  Widget _loginButton() {
    return SkyButton(
      text: 'e-skylab ile Giriş Yap',
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : SvgPicture.asset(
              AppAssets.skylab,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
      backgroundColor: AppColors.buttonColor,
      onPressed: () {
        isLoading ? null : handleAuth();
      },
    );
  }

  Widget _footer() {
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
