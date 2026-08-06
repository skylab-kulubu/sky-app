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

/// Etkinlikler sekmesindeki kart: üstte kapak görseli, altında kart zemini
/// üzerinde ad, açıklama ve saat/konum satırı.
///
/// Metinler görselin üstüne bindirilmiyor; okunurluk kapağın renginden
/// bağımsız. Görselin üstünde hiçbir öğe durmuyor, tüm bilgi altındaki
/// metin bloğunda.
///
/// Dokununca detay sayfası açılır: kapak görseli [Hero] ile kesintisiz
/// büyüyerek sayfanın kapağına dönüşür, sayfanın geri kalanı üstüne
/// yumuşakça biner.
///
/// `OpenContainer` (container transform) burada kullanılmıyor: kutuyu
/// büyütüyor ama iki sayfanın içeriğini birbirine karıştırarak (cross-fade)
/// değiştiriyor — yani görsel yerinden hareket etmiyor, biri sönerken
/// diğeri beliriyordu. İkisi bir arada da kullanılamıyor: hem OpenContainer
/// hem Hero kaynak widget'ı gizleyip kendi katmanında çizdiği için
/// çakışıyorlar.
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
    // Detay sayfasının zemini kapağın renklerinden kuruluyor ve hesabı
    // pahalı. Kart göründüğü anda başlatılıyor ki karta dokunulduğunda
    // sonuç çoktan hazır olsun; sayfa açılışında hesaplanınca geçiş
    // takılıyordu.
    unawaited(
      EventPaletteService.resolve(
        eventId: event.id,
        imageUrl: event.coverImageUrl,
      ),
    );
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

  /// Kapak, detay sayfasındaki kapakla aynı [Hero] etiketini taşıyor;
  /// sayfa açılırken buradan oraya kesintisiz uçuyor.
  ///
  /// [AspectRatio] Hero'nun dışında: uçuş sırasında Hero çocuğuna hedef
  /// boyutu dayatıyor, oran kısıtı içeride kalırsa onunla çakışıyor.
  Widget _cover(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppSizes.eventCoverAspect,
      child: EventCoverHero(
        eventId: event.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadiuses.innerTile),
          child: CoverImage(imageUrl: event.coverImageUrl),
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
        // Başvuruya kapalı etkinlik: detay sayfasındaki pasif butonun
        // listedeki karşılığı.
        // if (!event.active) ...[
        //   const SizedBox(width: AppSizes.midSpace),
        //   _statusChip(context),
        // ],
      ],
    );
  }

  // Widget _statusChip(BuildContext context) {
  //   return Container(
  //     padding: AppPaddings.horizontal8,
  //     decoration: BoxDecoration(
  //       color: AppColors.orange9,
  //       borderRadius: AppRadiuses.stadiumBorderRadius,
  //       border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         const AppIcon(
  //           AppIcons.clock,
  //           size: AppSizes.iconSmall,
  //           color: AppColors.orange,
  //         ),
  //         const SizedBox(width: AppSizes.smallSpace),
  //         Text(
  //           'Yakında',
  //           maxLines: 1,
  //           style: context.textTheme.labelSmall?.copyWith(
  //             color: AppColors.orange,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  /// Tarih, saat ve konum tek satırda ve her biri kendi ikonuyla. Kartın
  /// asıl işlevsel bilgisi bu satır olduğu için silik değil, gövde metniyle
  /// aynı koyulukta duruyor.
  ///
  /// Tarih ve saat kendi genişliklerini alıyor; taşma riski taşıyan tek
  /// alan konum, o yüzden esneyen ve kırpılan da o.
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
        // Vurgu rengi yalnızca ikonda; metin nötr kalıyor ki satır
        // renklenmesin.
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
