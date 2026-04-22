import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/profile/data/models/team_model.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  const TeamCard({super.key, required this.team});

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadiuses.cardBorderRadius,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _teamIconWithBackground(),
          const SizedBox(height: 8),
          _teamTitle(),
          const SizedBox(height: 4),
          _teamDescription(),

          const Spacer(),

          _applyButton(),
        ],
      ),
    );
  }

  Widget _teamIconWithBackground() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: team.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(team.icon, color: team.color, size: 28),
  );

  Text _teamTitle() => Text(
    team.name,
    style: const TextStyle(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );

  Text _teamDescription() => Text(
    team.description,
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
  );

  Widget _applyButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        "Başvur",
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
