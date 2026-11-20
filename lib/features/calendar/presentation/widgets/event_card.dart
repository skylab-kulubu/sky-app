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

/// Etkinlikler sekmesindeki kart: kapak ve altında ad, açıklama, saat/konum;
/// metin görselin üstüne binmiyor. Dokununca kapak [Hero] ile detayın
/// kapağına uçuyor.
///
/// `OpenContainer` kullanılmıyor: içerikleri cross-fade ettiği için görsel
/// yerinden hareket etmiyordu; Hero ile de birlikte çalışmıyor.
class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});

  final EventModel event;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  static const double _descriptionLineHeight = 1.35;

  EventModel get event => widget.event;

  @override
  void initState() {
    super.initState();
    // Detayın zemini kapak renklerinden ve hesabı pahalı; kart görünür görünmez
    // başlıyor, sayfa açılışında hesaplanınca geçiş takılıyordu. Sunucu
    // renkleri geldiyse gerek yok.
    if (event.coverColors.isEmpty) {
      unawaited(EventPaletteService.resolve(event.coverImageUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tileColor,
      borderRadius: AppRadiuses.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => EventDetailPage.open(context, event),
        child: _card(context),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Padding(
      padding: AppPaddings.eventCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cover(context),
          Padding(
            padding: AppPaddings.eventCardContent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(context),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.midSpace),
                  _description(context),
                ],
                const SizedBox(height: AppSizes.bigSpace),
                _metaRow(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kapak detaydakiyle aynı [Hero] etiketini taşıyor. [AspectRatio] Hero'nun
  /// dışında: uçuşta Hero çocuğuna hedef boyutu dayatıyor.
  Widget _cover(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppSizes.eventCoverAspect,
      child: EventCoverHero(
        eventId: event.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadiuses.innerTile),
          child: CoverImage(imageUrl: event.coverCardUrl),
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            event.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _description(BuildContext context) {
    return Text(
      event.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.textSecondary,
        fontWeight: FontWeight.w500,
        height: _descriptionLineHeight,
      ),
    );
  }

  /// Tarih, saat ve konum tek satırda; kartın asıl bilgisi olduğu için gövde
  /// metniyle aynı koyulukta. Taşabilecek tek alan konum, esneyen o.
  Widget _metaRow(BuildContext context) {
    return Row(
      children: [
        if (event.formattedDate.isNotEmpty) ...[
          _meta(context, icon: AppIcons.calendar, text: event.formattedDate),
          const SizedBox(width: AppSizes.bigSpace),
        ],
        if (event.formattedTime.isNotEmpty) ...[
          _meta(context, icon: AppIcons.clock, text: event.formattedTime),
          const SizedBox(width: AppSizes.bigSpace),
        ],
        if (event.location.isNotEmpty)
          Flexible(
            child: _meta(
              context,
              icon: AppIcons.location,
              text: event.location,
            ),
          ),
      ],
    );
  }

  Widget _meta(
    BuildContext context, {
    required String icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vurgu yalnızca ikonda; satır renklenmesin.
        AppIcon(icon, size: AppSizes.iconSmall, color: context.accentColor),
        const SizedBox(width: AppSizes.midSpace),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
