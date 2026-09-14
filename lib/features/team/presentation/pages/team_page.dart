import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/presentation/providers/team_provider.dart';
import 'package:sky_app/features/team/presentation/widgets/team_card.dart';
import 'package:sky_app/features/team/presentation/widgets/team_summary_row.dart';

part 'team_pagemodel.dart';

/// Ekip sekmesi: AR-GE ekiplerinin yatay kaydırılan kartları.
///
/// Ortadaki kart tam boyda; yandakiler kenarlardan görünüyor, perspektifle
/// içe dönük ve bir tık küçük duruyor. Kaydırdıkça bu değerler kartın
/// ortaya olan uzaklığına göre sürekli değişiyor.
class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends TeamPagemodel {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    if (!provider.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final error = provider.error;
    if (error != null && provider.teams.isEmpty) {
      return Scaffold(body: _error(context, error, provider.isLoading));
    }

    if (provider.teams.isEmpty) return Scaffold(body: _empty(context));

    return Scaffold(body: _carousel(provider.teams));
  }

  Widget _carousel(List<Team> teams) {
    return Padding(
      // Altta yüzen navbar'ın payı ve onunla içerik arasında ayrıca boşluk;
      // yalnızca navbar payı bırakıldığında kart navbar'a değiyordu.
      padding: const EdgeInsets.only(
        top: AppSizes.bigSpace,
        bottom: AppSizes.navBarClearance + AppSizes.largeSpace,
      ),
      child: Column(
        children: [
          Padding(
            padding: AppPaddings.mainPaddingHorizontal,
            child: _summaryRow(teams),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          // Kart ve noktalar tek grup olarak dikeyde ortalanıyor. Kart
          // kalan alanın tamamını alıp içinde ortalandığında boşluk kartın
          // altına da düşüyor, noktalar karttan kopuk duruyordu.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardHeight = _cardHeight(constraints);
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: cardHeight, child: _pageView(teams)),
                      const SizedBox(height: AppSizes.bigSpace),
                      _pageIndicator(teams.length),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(List<Team> teams) {
    final roles = context.watch<UserProvider>().user?.realmRoles ?? const [];

    return TeamSummaryRow(
      myTeams: context.read<TeamProvider>().teamsOf(roles),
      recruitingTeams: [
        for (final team in teams)
          if (team.isRecruiting) team,
      ],
      onTeamTap: jumpToTeam,
    );
  }

  /// Kaçıncı ekipte olunduğunu gösteren noktalar; aktif olan hap şeklinde
  /// uzuyor. Kaydırma sırasında iki nokta arasında akıcı geçiyor.
  Widget _pageIndicator(int count) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [for (var i = 0; i < count; i++) _dot(context, i)],
      ),
    );
  }

  Widget _dot(BuildContext context, int index) {
    // 0: tam aktif, 1 ve üstü: pasif.
    final distance = (pageOffset - index).abs().clamp(0.0, 1.0);
    final width =
        AppSizes.badgeDot +
        (TeamPagemodel._activeDotWidth - AppSizes.badgeDot) * (1 - distance);

    return Container(
      width: width,
      height: AppSizes.badgeDot,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.smallSpace),
      decoration: BoxDecoration(
        color: Color.lerp(context.accentColor, context.elevatedColor, distance),
        borderRadius: AppRadiuses.stadiumBorderRadius,
      ),
    );
  }

  /// Kartın oranından gelen yüksekliği; alan yetmezse (kısa ekran) noktaların
  /// payı düşülmüş alana sığacak kadar.
  double _cardHeight(BoxConstraints constraints) {
    final cardWidth =
        constraints.maxWidth * TeamPagemodel._viewportFraction -
        TeamPagemodel._cardGap.horizontal;
    final available =
        constraints.maxHeight - AppSizes.bigSpace - AppSizes.badgeDot;
    return (cardWidth / TeamPagemodel._cardAspectRatio).clamp(0.0, available);
  }

  Widget _pageView(List<Team> teams) {
    return PageView.builder(
      controller: pageController,
      itemCount: teams.length,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: pageController,
        // Kart kaydırmadan etkilenmiyor; her karede baştan kurulmasın.
        // Yükseklik dışarıda belirlendi; oran yalnızca kısa ekranda
        // genişliği daraltıyor.
        child: Center(
          child: Padding(
            padding: TeamPagemodel._cardGap,
            child: AspectRatio(
              aspectRatio: TeamPagemodel._cardAspectRatio,
              child: TeamCard(team: teams[index]),
            ),
          ),
        ),
        builder: (context, child) => _transformed(index, child!),
      ),
    );
  }

  /// Kartın ortaya uzaklığına göre dönüş ve küçülme.
  ///
  /// Dönüş ekseni kartın ortaya bakan kenarı değil ortası; kenardan
  /// döndürüldüğünde yandaki kart ortadakinin altına giriyordu.
  Widget _transformed(int index, Widget child) {
    final distance = (pageOffset - index).clamp(-1.0, 1.0);
    final scale = 1 - distance.abs() * TeamPagemodel._sideScaleLoss;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, TeamPagemodel._perspective)
      ..rotateY(distance * TeamPagemodel._sideRotation)
      ..scaleByDouble(scale, scale, 1, 1);

    return Transform(
      alignment: Alignment.center,
      transform: matrix,
      child: child,
    );
  }

  Widget _error(BuildContext context, ApiException error, bool isRetrying) {
    return _message(
      context,
      icon: error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
      title: 'Ekipler Yüklenemedi',
      message: error.userMessage,
      action: SkyButton(
        text: 'Tekrar Dene',
        onPressed: onRetry,
        isLoading: isRetrying,
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return _message(
      context,
      icon: AppIcons.users2,
      title: 'Ekip Yok',
      message: 'Ekipler eklendiğinde burada görünecek.',
    );
  }

  Widget _message(
    BuildContext context, {
    required String icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSizes.largeSpace),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
