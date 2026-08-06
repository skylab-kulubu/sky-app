import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_card.dart';

part 'calendar_pagemodel.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends CalendarPagemodel {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (isBusy(eventProvider)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final events = eventProvider.events;

        return Scaffold(body: events.isEmpty ? _empty(context) : _list(events));
      },
    );
  }

  Widget _list(List<EventModel> events) {
    return ListView.separated(
      padding: AppPaddings.mainPaddingAll,
      // Son kart yüzen navbar'ın altında kalmasın diye listeye bir öğe
      // fazla pay bırakılıyor.
      itemCount: events.length + 1,
      separatorBuilder: (_, _) =>
          const SizedBox(height: CalendarPagemodel._cardGap),
      itemBuilder: (context, index) {
        if (index == events.length) {
          return const SizedBox(height: AppSizes.navBarClearance);
        }

        final event = events[index];
        return EventCard(key: Key(event.id), event: event);
      },
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              AppIcons.calendar,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              'Etkinlik Yok',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              'Yeni bir etkinlik açıldığında burada görünecek.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
