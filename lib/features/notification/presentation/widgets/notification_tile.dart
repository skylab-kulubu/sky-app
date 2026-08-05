import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/notification/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Bildirim listesindeki tek satır: solda yuvarlak ikon, sağda başlık,
/// kısa zaman etiketi ve iki satır açıklama. Kart zemini ve ayraç yok;
/// haber satırları gibi sayfa zemini üzerinde düz durur.
///
/// Okunmamış bildirim, sol dairenin vurgu rengi ve başlığın yanındaki
/// noktadan anlaşılır; okunmuşlar nötr kalır.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, this.onTap});

  final NotificationModel item;
  final VoidCallback? onTap;

  static const double _circleSpacing = AppSizes.bigSpace;
  static const double _rowSpacing = AppSizes.smallSpace;
  static const double _descriptionLineHeight = 1.35;

  /// Okunmamış satırın ikon dairesindeki vurgu zemininin opaklığı.
  static const double _unreadCircleOpacity = 0.16;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppPaddings.notificationTile,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _circle(context),
            const SizedBox(width: _circleSpacing),
            Expanded(child: _details(context)),
          ],
        ),
      ),
    );
  }

  Widget _circle(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: AppSizes.notificationCircle,
      width: AppSizes.notificationCircle,
      decoration: BoxDecoration(
        color: item.isRead
            ? context.elevatedColor
            : context.accentColor.withValues(alpha: _unreadCircleOpacity),
        shape: BoxShape.circle,
      ),
      child: AppIcon(
        AppIcons.announcement,
        filled: !item.isRead,
        size: AppSizes.iconMedium,
        color: item.isRead ? context.textTertiary : context.accentColor,
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleRow(context),
        const SizedBox(height: _rowSpacing),
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
              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        ),
        if (!item.isRead) ...[
          const SizedBox(width: AppSizes.midSpace),
          Container(
            height: AppSizes.badgeDot,
            width: AppSizes.badgeDot,
            decoration: BoxDecoration(
              color: context.accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
        const SizedBox(width: AppSizes.midSpace),
        Text(
          // Kısa biçim ("5dk", "2g"): uzun biçim başlığın yerini yiyor.
          timeago.format(item.dateTime, locale: 'tr_short'),
          style: context.textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }
}
