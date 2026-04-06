import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/profile/presentation/pages/team_arge_page.dart';
import 'package:sky_app/features/profile/presentation/pages/team_social_page.dart';
import 'package:sky_app/features/profile/presentation/widgets/tab_label.dart';

//revome appbar and bottom navigator bar
part 'profile_team_pagemodel.dart';

class ProfileTeamPage extends StatefulWidget {
  const ProfileTeamPage({super.key});

  @override
  State<ProfileTeamPage> createState() => _ProfileTeamPageState();
}

class _ProfileTeamPageState extends ProfileTeamPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: _appBar(context),
      body: Column(children: [_tabBarContainer(), _tabViewArea()]),
    );
  }

  AppBar _appBar(BuildContext context) => AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text("Ekipler", style: TextStyle(color: AppColors.textWhite)),
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




