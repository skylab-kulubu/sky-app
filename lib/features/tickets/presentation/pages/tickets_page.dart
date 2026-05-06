import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/tickets/presentation/pages/active_tickets_page.dart';
import 'package:sky_app/features/tickets/presentation/pages/past_tickets_page.dart';
import 'package:sky_app/features/tickets/presentation/widgets/tickets_tab_bar.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final activeEvents = context.watch<EventProvider>().activeEvents;
    final activeEventTypeNames = activeEvents.map((event) => event.typeName);
    final isOrganizer = user?.isOrganizerForAny(activeEventTypeNames) ?? false;

    log(
      'User teams: ${user?.teamsDisplay}, Active event types: ${activeEvents.map((e) => e.typeName).join(', ')}, Is organizer: $isOrganizer',
    );

    return Scaffold(
      body: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TicketsTabBar(tabController: tabController),
            if (isOrganizer) ...[
              const SizedBox(height: AppSizes.bigSpace),
              const _OrganizerButton(),
            ],
            const SizedBox(height: AppSizes.bigSpace),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [ActiveTicketsPage(), PastTicketsPage()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizerButton extends StatelessWidget {
  const _OrganizerButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: AppPaddings.cardContentPaddingHorizontal,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadiuses.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            'Bilet Tarayıcı',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.white),
          ),
          onPressed: () {
            context.push('/tickets/qr');
          },
        ),
      ),
    );
  }
}
