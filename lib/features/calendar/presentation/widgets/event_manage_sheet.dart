import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

enum EventManageAction { edit, publish, unpublish, cancel, uncancel, copy }

/// Etkinliği düzenleyebilenin menüsü: durumuna göre yayınla, taslağa al,
/// iptal et ya da iptali geri al; her durumda düzenle ve kopyala.
class EventManageSheet extends StatelessWidget {
  const EventManageSheet({super.key, required this.event});

  final EventModel event;

  static Future<EventManageAction?> show(
    BuildContext context,
    EventModel event,
  ) {
    return showModalBottomSheet<EventManageAction>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => EventManageSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    void pick(EventManageAction action) => Navigator.pop(context, action);
    // Bitmiş etkinlik iptal edilemiyor (`409 event_ended`).
    final canCancel = !event.isDraft && !event.isCancelled && !event.hasEnded;

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.bigSpace),
            TileGroup(
              children: [
                SettingsTile(
                  icon: AppIcons.edit,
                  iconColor: AppColors.blue,
                  title: 'Düzenle',
                  onTap: () => pick(EventManageAction.edit),
                ),
                if (event.isDraft)
                  SettingsTile(
                    icon: AppIcons.publish,
                    iconColor: AppColors.green,
                    title: 'Yayınla',
                    subtitle: 'Herkes görür, başvurular açılır',
                    onTap: () => pick(EventManageAction.publish),
                  ),
                if (event.isCancelled)
                  SettingsTile(
                    icon: AppIcons.undo,
                    iconColor: AppColors.green,
                    title: 'İptali Geri Al',
                    subtitle: 'Etkinlik yeniden yayına alınır',
                    onTap: () => pick(EventManageAction.uncancel),
                  ),
                SettingsTile(
                  icon: AppIcons.copy,
                  iconColor: AppColors.purple,
                  title: 'Kopyasını Oluştur',
                  subtitle: 'Yeni tarihle taslak olarak',
                  onTap: () => pick(EventManageAction.copy),
                ),
                if (!event.isDraft && !event.isCancelled)
                  SettingsTile(
                    icon: AppIcons.unpublish,
                    iconColor: AppColors.orange,
                    title: 'Taslağa Al',
                    subtitle: 'Yalnız kaydı yokken',
                    onTap: () => pick(EventManageAction.unpublish),
                  ),
                if (canCancel)
                  SettingsTile(
                    icon: AppIcons.cancelEvent,
                    iconColor: AppColors.red,
                    title: 'Etkinliği İptal Et',
                    titleColor: AppColors.red,
                    onTap: () => pick(EventManageAction.cancel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
