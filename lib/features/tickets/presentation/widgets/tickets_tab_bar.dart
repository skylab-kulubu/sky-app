import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/widgets/tab_label.dart';

class TicketsTabBar extends StatefulWidget {
  const TicketsTabBar({super.key, required this.tabController});

  final TabController tabController;

  @override
  State<TicketsTabBar> createState() => _TicketsTabBarState();
}

class _TicketsTabBarState extends State<TicketsTabBar> {
  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.tabController,
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
          child: Tab(child: TabLabel(label: "Aktif Biletlerim")),
        ),
        ClipRRect(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
          child: Tab(child: TabLabel(label: "Geçmiş Biletlerim")),
        ),
      ],
    );
  }
}
