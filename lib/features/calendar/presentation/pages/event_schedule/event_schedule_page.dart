import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/schedule_service.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_schedule/schedule_day_form_page.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_schedule/schedule_session_form_page.dart';

part 'event_schedule_pagemodel.dart';

/// Etkinlik programını düzenleme: günler ve her günün oturumları. Günün
/// satırına dokununca gün, oturuma dokununca oturum formu açılıyor.
///
/// Etkinliği düzenleyebilen herkes açabiliyor; silme yalnızca liderlere ve
/// YK/DK/ADMIN'e ([User.canDeleteEvent]). Yoklama oturum bazında alındığı
/// için kapı okuyucusu da buradaki oturumları kullanıyor.
class EventSchedulePage extends StatefulWidget {
  const EventSchedulePage({super.key, required this.event});

  final EventModel event;

  /// Tam ekran açar; program değiştiyse `true` döner.
  static Future<bool> open(BuildContext context, EventModel event) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => EventSchedulePage(event: event)),
    );
    return changed ?? false;
  }

  @override
  State<EventSchedulePage> createState() => _EventSchedulePageState();
}

class _EventSchedulePageState extends EventSchedulePagemodel {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Program'),
          leading: IconButton(
            icon: const AppIcon(AppIcons.arrowBack),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: RefreshIndicator.adaptive(onRefresh: reload, child: _body()),
        bottomNavigationBar: SafeArea(
          minimum: AppPaddings.mainPaddingAll,
          child: SkyButton(text: 'Gün Ekle', onPressed: onAddDay),
        ),
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final error = this.error;
    if (error != null && schedule.isEmpty) {
      return _message(
        icon: error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
        title: 'Program Yüklenemedi',
        message: error.userMessage,
      );
    }

    if (schedule.isEmpty) {
      return _message(
        icon: AppIcons.calendarAdd,
        title: 'Program Boş',
        message:
            'Önce bir gün ekle, sonra o güne oturumlar. Yoklama oturum '
            'bazında alınıyor; kapı okuyucusu bu oturumları kullanıyor.',
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppPaddings.mainPaddingAll,
      children: [
        for (final (index, entry) in schedule.indexed) ...[
          SectionHeader(
            entry.day.label.isEmpty ? '${index + 1}. Gün' : entry.day.label,
            isFirst: index == 0,
          ),
          _dayGroup(entry),
        ],
      ],
    );
  }

  Widget _dayGroup(ScheduleDay entry) {
    return TileGroup(
      children: [
        SettingsTile(
          icon: AppIcons.calendarEdit,
          iconColor: AppColors.blue,
          title: 'Günü düzenle',
          value: entry.day.dateLabel,
          onTap: () => onEditDay(entry.day),
        ),
        for (final session in entry.sessions)
          SettingsTile(
            icon: session.cancelled
                ? AppIcons.closeCircle
                : AppIcons.microphone,
            iconColor: session.cancelled ? AppColors.red : AppColors.purple,
            title: session.title,
            subtitle: [
              if (session.timeRange.isNotEmpty) session.timeRange,
              session.cancelled ? 'İptal edildi' : session.speakerName,
            ].join('  •  '),
            onTap: () => onEditSession(entry, session),
          ),
        SettingsTile(
          icon: AppIcons.add,
          iconColor: AppColors.green,
          title: 'Oturum Ekle',
          trailingIcon: null,
          onTap: () => onAddSession(entry),
        ),
      ],
    );
  }

  /// Boş ya da hata durumu; aşağı çekerek yenilenebilsin diye kaydırılabilir.
  Widget _message({
    required String icon,
    required String title,
    required String message,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
