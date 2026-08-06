import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/cover_image.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_palette_service.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_detail/event_detail_page.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_cover_hero.dart';

/// Yaklaşan etkinlik satırı: solda kapak görseli, sağda tür, ad, tarih/saat
/// ve konum.
///
/// Dokununca Etkinlikler sekmesindeki kartla aynı geçişle detay sayfasını
/// açar: kapak görseli [Hero] ile uçar, sayfa üstüne biner.
class UpcomingEventTile extends StatefulWidget {
  const UpcomingEventTile({super.key, required this.event});

  final EventModel event;

  @override
  State<UpcomingEventTile> createState() => _UpcomingEventTileState();
}

class _UpcomingEventTileState extends State<UpcomingEventTile> {
  static const double _coverSpacing = AppSizes.bigSpace;
  static const double _rowSpacing = AppSizes.smallSpace;
  static const double _metaIconSpacing = AppSizes.midSpace;

  EventModel get event => widget.event;

  @override
  void initState() {
    super.initState();
    // Detay sayfasının zemini kapağın renklerinden kuruluyor; hesap satır
    // göründüğü anda başlıyor ki sayfa açıldığında hazır olsun.
    unawaited(
      EventPaletteService.resolve(
        eventId: event.id,
        imageUrl: event.coverImageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => EventDetailPage.open(context, event),
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
    return EventCoverHero(
      eventId: event.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadiuses.thumbnail),
        child: SizedBox(
          width: AppSizes.thumbnail,
          height: AppSizes.thumbnail,
          child: CoverImage(imageUrl: event.coverImageUrl),
        ),
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
          text: [
            event.formattedDate,
            event.formattedTime,
          ].where((part) => part.isNotEmpty).join(' · '),
        ),
        if (event.location.isNotEmpty) ...[
          const SizedBox(height: _rowSpacing),
          _metaRow(context, icon: AppIcons.location, text: event.location),
        ],
      ],
    );
  }

  /// Etkinlikler sekmesindeki kartla aynı dil: vurgu rengi yalnızca ikonda,
  /// metin nötr kalıyor.
  Widget _metaRow(
    BuildContext context, {
    required String icon,
    required String text,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        AppIcon(icon, size: AppSizes.iconSmall, color: context.accentColor),
        const SizedBox(width: _metaIconSpacing),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
