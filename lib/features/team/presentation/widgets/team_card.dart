import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/presentation/pages/team_detail/team_detail_page.dart';
import 'package:sky_app/features/team/presentation/widgets/team_logo.dart';
import 'package:sky_app/features/team/presentation/widgets/team_logo_hero.dart';

/// Ekip carousel'indeki büyük kart: üstte logo, altında ad, en altta
/// "Detayları Gör".
///
/// Zemin, köşeler ve iç boşluklar `EventCard` ile aynı. Kartın yüksekliği
/// carousel'den geliyor; logo alanı kalan boşluğu dolduruyor, ad ve buton
/// kendi boylarında kalıyor.
class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team});

  final Team team;

  /// Logonun kendi alanına göre iç boşluğu; logolar kenara yapışmasın.
  static const double _logoInsetFactor = 0.18;

  static const int _descriptionLines = 4;
  static const double _descriptionLineHeight = 1.35;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tileColor,
      borderRadius: AppRadiuses.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppPaddings.eventCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _logoArea(context)),
            Padding(
              padding: AppPaddings.eventCardContent,
              child: Column(
                children: [
                  Text(
                    team.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (team.description.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.midSpace),
                    _description(context),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.bigSpace),
            SkyButton(
              text: 'Detayları Gör',
              onPressed: () => TeamDetailPage.open(context, team),
            ),
          ],
        ),
      ),
    );
  }

  /// Kısa açıklama, [_descriptionLines] satırda kesilir. Satır sayısı sabit
  /// tutuluyor (kısa açıklamada da aynı yeri kaplıyor) ki kartlar arasında logo
  /// alanı ve buton hizası kaymasın.
  Widget _description(BuildContext context) {
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.textSecondary,
      height: _descriptionLineHeight,
    );

    // `Text`'in en az satır ayarı yok; sabit yükseklik yazı boyutu,
    // satır aralığı ve kullanıcının yazı ölçeğinden hesaplanıyor.
    final fontSize = MediaQuery.textScalerOf(
      context,
    ).scale(style?.fontSize ?? 14);

    return SizedBox(
      height: fontSize * _descriptionLineHeight * _descriptionLines,
      child: Text(
        team.description,
        maxLines: _descriptionLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }

  /// Logo, kartın içinde bir tık yükseltilmiş zeminde. Hero bu alanı
  /// detay sayfasının kapağına taşıyor.
  Widget _logoArea(BuildContext context) {
    return TeamLogoHero(
      slug: team.slug,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadiuses.innerTile),
        child: ColoredBox(
          color: context.elevatedColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inset = constraints.biggest.shortestSide * _logoInsetFactor;
              return Padding(
                padding: EdgeInsets.all(inset),
                child: TeamLogo(team: team),
              );
            },
          ),
        ),
      ),
    );
  }
}
