import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/profile/presentation/pages/teams/team_arge_page.dart';
import 'package:sky_app/features/profile/presentation/pages/teams/team_social_page.dart';
import 'package:sky_app/features/profile/presentation/widgets/tab_label.dart';

//revome appbar and bottom navigator bar
part 'teams_pagemodel.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends TeamPagesmodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: _appBar(context),
      body: Column(children: [_tabBarContainer(), _tabViewArea()]),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleSpacing: 12,
    title: const Text(
      "Ekipler",
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _tabBarContainer() => Padding(
    padding: AppPaddings.horizontal16Vertical8,
    child: Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadiuses.containerBorderRadius,
      ),
      child: _tabBar(),
    ),
  );

  TabBar _tabBar() => TabBar(
    controller: tabController,
    labelColor: AppColors.textWhite,
    unselectedLabelColor: AppColors.unselectedLabelColor,
    dividerColor: Colors.transparent,

    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
    indicatorSize: TabBarIndicatorSize.label,
    splashBorderRadius: BorderRadius.circular(AppRadiuses.containerRadius),

    indicator: const BoxDecoration(
      borderRadius: AppRadiuses.containerBorderRadius,
      color: AppColors.indicatorColor,
    ),

    tabs: const [
      ClipRRect(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
        child: Tab(
          child: TabLabel(icon: Icons.biotech, label: "AR-GE"),
        ),
      ),
      Tab(
        child: TabLabel(icon: Icons.groups, label: "Sosyal"),
      ),
    ],
  );

  Widget _tabViewArea() => Expanded(
    child: TabBarView(
      controller: tabController,
      children: const [TeamArgePage(), TeamSocialPage()],
    ),
  );
}
