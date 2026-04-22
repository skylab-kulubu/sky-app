import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/profile/presentation/widgets/team_card.dart';
import 'package:sky_app/features/profile/data/models/team_model.dart';

class TeamSocialPage extends StatefulWidget {
  const TeamSocialPage({super.key});

  @override
  State<TeamSocialPage> createState() => _TeamSocialPageState();
}

class _TeamSocialPageState extends State<TeamSocialPage> {
  final List<Team> socialTeams = [
    Team(
      name: "ORGANİZASYON",
      icon: AppAssets.celebration,
      description: "Etkinlik planlama ve organizasyon",
      color: const Color(0xFFE91E63),
    ),
    Team(
      name: "GECEKODU",
      icon: AppAssets.code,
      description: "Gece kodlama etkinlikleri",
      color: const Color(0xFF3F51B5),
    ),
    Team(
      name: "SOCILAB",
      icon: AppAssets.people,
      description: "Sosyal medya ve topluluk yönetimi",
      color: const Color(0xFF9C27B0),
    ),
    Team(
      name: "SKYMEDYA",
      icon: AppAssets.camera,
      description: "Fotoğraf, video ve içerik üretimi",
      color: const Color(0xFFFFC107),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppPaddings.mainPaddingAll,
      itemCount: socialTeams.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return TeamCard(team: socialTeams[index]);
      },
    );
  }
}
