import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/profile/presentation/widgets/team_card.dart';
import 'package:sky_app/features/profile/data/models/team_model.dart';

class TeamArgePage extends StatefulWidget {
  const TeamArgePage({super.key});

  @override
  State<TeamArgePage> createState() => _TeamArgePageState();
}

class _TeamArgePageState extends State<TeamArgePage> {
  List<Team> argeTeams = [
    Team(
      name: "MOBİLAB",
      icon: AppAssets.mobilab,
      description: "Mobil uygulama geliştirme ekibi",
      color: const Color(0xFF2196F3),
    ),
    Team(
      name: "AIR LAB",
      icon: AppAssets.robot,
      description: "Yapay zeka ve makine öğrenmesi",
      color: const Color(0xFFFF5252),
    ),
    Team(
      name: "ALGOLAB",
      icon: AppAssets.binary,
      description: "Algoritma ve veri yapıları",
      color: const Color(0xFF4CAF50),
    ),
    Team(
      name: "CHAINLAB",
      icon: AppAssets.link,
      description: "Blockchain ve Web3 teknolojileri",
      color: const Color(0xFFFFD740),
    ),
    Team(
      name: "GAME LAB",
      icon: AppAssets.gameConsole,
      description: "Oyun tasarımı ve geliştirme",
      color: const Color(0xFFE040FB),
    ),
    Team(
      name: "SKY-SEC",
      icon: AppAssets.skysec,
      description: "Siber güvenlik ve CTF",
      color: const Color(0xFFFF9800),
    ),
    Team(
      name: "SKYSIS",
      icon: AppAssets.computer,
      description: "Sistem yönetimi ve DevOps",
      color: const Color(0xFF00BCD4),
    ),
    Team(
      name: "WEBLAB",
      icon: AppAssets.web,
      description: "Web geliştirme ve tasarım",
      color: const Color(0xFF2196F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppPaddings.mainPaddingAll,
      itemCount: argeTeams.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return TeamCard(team: argeTeams[index]);
      },
    );
  }
}
