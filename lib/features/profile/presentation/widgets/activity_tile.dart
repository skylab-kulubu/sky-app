import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';
import 'package:sky_app/features/profile/data/models/activity.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Profildeki aktivite satırı: solda renkli ikon dairesi, sağda başlık, kısa
/// zaman etiketi ve iki satır açıklama. Kart zemini yok, sayfa zemini
/// üzerinde düz durur.
///
/// Ana sayfadaki haber satırına **benzer** ama onun widget'ı değil: haberde
/// kapak görseli ve detay sayfasına geçiş var, burada ikon var ve satırın
/// gideceği bir yer yok. Tipografi kasıtlı olarak aynı, iki listedeki
/// satırlar aynı ritimde okunsun diye.
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.item});

  final Activity item;

  static const double _circleSpacing = AppSizes.bigSpace;
  static const double _titleSpacing = AppSizes.smallSpace;
  static const double _descriptionLineHeight = 1.35;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.activityTile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconCircle(
            icon: item.icon,
            color: item.color,
            size: AppSizes.activityIconCircle,
          ),
          const SizedBox(width: _circleSpacing),
          Expanded(child: _details(context)),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleRow(context),
        const SizedBox(height: _titleSpacing),
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
            height: _descriptionLineHeight,
          ),
        ),
      ],
    );
  }

  /// Başlık ve zaman aynı satırda. Başlık tek satır: iki satıra taşan bir
  /// başlık o satırı diğerlerinden uzun yapıp listenin ritmini bozuyor.
  Widget _titleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.midSpace),
        Text(
          // Kısa biçim ("3g", "2ay"): uzun biçim başlığın yerini yiyor.
          timeago.format(item.dateTime, locale: 'tr_short'),
          style: context.textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }
}
