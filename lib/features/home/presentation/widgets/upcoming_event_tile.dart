import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/home/presentation/widgets/cover_image.dart';

/// Yaklaşan etkinlik satırı: solda kapak görseli, sağda tür, ad, tarih/saat
/// ve konum.
class UpcomingEventTile extends StatelessWidget {
  const UpcomingEventTile({super.key, required this.event, this.onTap});

  final EventModel event;
  final VoidCallback? onTap;

  static const double _coverSpacing = AppSizes.bigSpace;
  static const double _rowSpacing = AppSizes.smallSpace;
  static const double _metaIconSpacing = AppSizes.midSpace;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: AppPaddings.newsTile,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cover(),
            const SizedBox(width: _coverSpacing),
            Expanded(child: _details(context)),
          ],
        ),
      ),
    );
  }

  Widget _cover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.thumbnail),
      child: SizedBox(
        width: AppSizes.thumbnail,
        height: AppSizes.thumbnail,
        child: CoverImage(imageUrl: event.coverImageUrl),
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.typeName.isNotEmpty) ...[
          Text(
            event.typeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: _rowSpacing),
        ],
        Text(
          event.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _rowSpacing),
        _metaRow(
          context,
          icon: AppIcons.clock,
          // Saat vurgu renginde: Luma'da da satırın taranan bilgisi bu.
          text: [
            event.formattedDate,
            event.formattedTime,
          ].where((part) => part.isNotEmpty).join(' · '),
          color: context.accentColor,
        ),
        if (event.location.isNotEmpty) ...[
          const SizedBox(height: _rowSpacing),
          _metaRow(
            context,
            icon: AppIcons.location,
            text: event.location,
            color: context.textSecondary,
          ),
        ],
      ],
    );
  }

  Widget _metaRow(
    BuildContext context, {
    required String icon,
    required String text,
    required Color color,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        AppIcon(icon, size: AppSizes.iconSmall, color: context.textTertiary),
        const SizedBox(width: _metaIconSpacing),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
