import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/profile/data/models/feedback_link.dart';

/// Katılınan etkinliğin geri bildirim formları, core'un sırasıyla (oturumlar
/// önce, etkinlik sonda). Doldurulanlar da listede; seçileni döner.
class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({
    super.key,
    required this.eventName,
    required this.links,
  });

  final String eventName;
  final List<FeedbackLink> links;

  static Future<FeedbackLink?> show(
    BuildContext context, {
    required String eventName,
    required List<FeedbackLink> links,
  }) {
    return showModalBottomSheet<FeedbackLink>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => FeedbackSheet(eventName: eventName, links: links),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              'Görüşlerin sonraki etkinlikleri daha iyi yapmamıza yardım '
              'ediyor.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.bigSpace),
            // Çok oturumlu etkinlikte liste ekranı aşabiliyor.
            Flexible(
              child: SingleChildScrollView(
                child: TileGroup(
                  children: [
                    for (final link in links)
                      SettingsTile(
                        icon: link.answered
                            ? AppIcons.checkCircle
                            : AppIcons.form,
                        iconColor: link.answered
                            ? AppColors.green
                            : AppColors.purple,
                        title: link.title.isEmpty
                            ? 'Geri Bildirim'
                            : link.title,
                        subtitle: link.answered
                            ? 'Doldurdun, teşekkürler'
                            : link.sessionId == null
                            ? 'Etkinliğin geneli için'
                            : 'Bu oturum için',
                        trailingIcon: AppIcons.externalLink,
                        onTap: () => Navigator.pop(context, link),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
