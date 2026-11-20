import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
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
///
/// Geri bildirim formu olan katılımda açıklamanın altında bir satır daha
/// var ve satır dokunulabilir ([onTap]).
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.item, this.onTap});

  final Activity item;

  /// Geri bildirim formlarını açar; formu olmayan satırda `null`.
  final VoidCallback? onTap;

  static const double _circleSpacing = AppSizes.bigSpace;
  static const double _titleSpacing = AppSizes.smallSpace;
  static const double _descriptionLineHeight = 1.35;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _row(context),
    );
  }

  Widget _row(BuildContext context) {
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
        if (item.feedback.isNotEmpty) ...[
          const SizedBox(height: _titleSpacing),
          _feedbackLine(context),
        ],
      ],
    );
  }

  /// Bekleyen form varsa vurgulu, hepsi dolduysa soluk bir teşekkür.
  Widget _feedbackLine(BuildContext context) {
    final pending = item.pendingFeedback;
    final color = pending > 0 ? context.accentColor : context.textTertiary;
    final text = switch (pending) {
      0 => 'Geri bildirimin için teşekkürler',
      1 when item.feedback.length == 1 => 'Geri bildirim formunu doldur',
      _ => '$pending geri bildirim formu seni bekliyor',
    };

    return Row(
      children: [
        AppIcon(
          pending > 0 ? AppIcons.form : AppIcons.checkCircle,
          size: AppSizes.iconSmall,
          color: color,
        ),
        const SizedBox(width: AppSizes.smallSpace),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
          // Kısa Türkçe biçimde gelecek ile geçmiş aynı yazılıyor ("3g");
          // henüz başlamamış bir etkinliğe kayıt bu yüzden ayrı etiketleniyor.
          item.dateTime.isAfter(DateTime.now())
              ? 'yakında'
              : timeago.format(item.dateTime, locale: 'tr_short'),
          style: context.textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }
}
