import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/notification/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Bildirim satırına dokununca açılan içerik sheet'i.
///
/// İçerik uzun düz metin olduğu için dialog yerine sheet: metin ekranın
/// tamamına yakınını kullanabiliyor ve uzun içerik kendi içinde kayıyor.
class NotificationDetailSheet extends StatelessWidget {
  const NotificationDetailSheet({super.key, required this.item});

  final NotificationModel item;

  static const double _maxHeightFactor = 0.75;
  static const double _contentLineHeight = 1.5;

  static Future<void> show(BuildContext context, NotificationModel item) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      isScrollControlled: true,
      builder: (_) => NotificationDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _handle(context),
              Text(
                item.title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.smallSpace),
              Text(
                timeago.format(item.dateTime, locale: 'tr'),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: AppSizes.bigSpace),
              Flexible(child: _content(context)),
              const SizedBox(height: AppSizes.bigSpace),
              SkyButton(text: 'Tamam', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSizes.bigSpace),
        decoration: BoxDecoration(
          color: context.dividerColor,
          borderRadius: AppRadiuses.stadiumBorderRadius,
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        item.content,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.textSecondary,
          height: _contentLineHeight,
        ),
      ),
    );
  }
}
