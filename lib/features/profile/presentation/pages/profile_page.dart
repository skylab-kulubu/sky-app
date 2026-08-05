import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/presentation/widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;

    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        ProfileHeader(
          name: user!.name,
          email: user.email,
          teamName: user.teamsDisplay,
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}
