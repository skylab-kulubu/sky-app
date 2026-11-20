import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/presentation/widgets/team_tag_chip.dart';

/// Ekipler başlığının altındaki satır: kullanıcı bir ekipteyse "Ekibin" ve
/// ekipleri; değilse "Alımı açık" ve üye alan ekipler (dokununca carousel
/// kayıyor). Sığmazsa yatayda kayıyor.
class TeamSummaryRow extends StatelessWidget {
  const TeamSummaryRow({
    super.key,
    required this.myTeams,
    required this.recruitingTeams,
    required this.onTeamTap,
  });

  final List<Team> myTeams;
  final List<Team> recruitingTeams;
  final ValueChanged<Team> onTeamTap;

  @override
  Widget build(BuildContext context) {
    final isMember = myTeams.isNotEmpty;
    final teams = isMember ? myTeams : recruitingTeams;

    final label = isMember
        ? (myTeams.length > 1 ? 'Ekiplerin:' : 'Ekibin:')
        : (recruitingTeams.isEmpty ? 'Şu an üye alan ekip yok' : 'Alımı açık');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textTertiary,
            ),
          ),
          for (final team in teams) ...[
            const SizedBox(width: AppSizes.midSpace),
            isMember
                ? TeamTagChip(label: team.name)
                : GestureDetector(
                    onTap: () => onTeamTap(team),
                    child: TeamTagChip(label: team.name),
                  ),
          ],
        ],
      ),
    );
  }
}
