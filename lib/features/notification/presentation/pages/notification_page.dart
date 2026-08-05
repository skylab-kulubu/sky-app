import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/notification/data/models/notification_model.dart';
import 'package:sky_app/features/notification/data/services/notification_service.dart';
import 'package:sky_app/features/notification/presentation/widgets/notification_detail_sheet.dart';
import 'package:sky_app/features/notification/presentation/widgets/notification_tile.dart';

part 'notification_pagemodel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends NotificationPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
      ),
      body: notifications.isEmpty ? _empty(context) : _list(),
    );
  }

  Widget _list() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: NotificationPagemodel._listVerticalPadding,
      ),
      itemCount: notifications.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: NotificationPagemodel._itemGap),
      itemBuilder: (context, index) => NotificationTile(
        item: notifications[index],
        onTap: () => openNotification(index),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              AppIcons.bell,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              'Bildirim Yok',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              'Yeni bir şey olduğunda burada göreceksin.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
