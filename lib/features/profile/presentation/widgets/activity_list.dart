import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/profile/presentation/providers/activity_provider.dart';
import 'package:sky_app/features/profile/presentation/widgets/activity_tile.dart';

/// Profildeki "Aktivitelerim" bölümünün içeriği: liste, yükleniyor, boş ve
/// hata durumları.
///
/// Profil sayfası stateless kalsın diye yükleme tetiği burada. Boş ve hata
/// durumları ana sayfadaki yaklaşan etkinlik bölümüyle aynı satır düzeninde:
/// ikon, [ActivityTile]'daki daire genişliğinde bir alana ortalanıyor.
class ActivityList extends StatefulWidget {
  const ActivityList({super.key, required this.userId});

  final String userId;

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  static const double _messageLineHeight = 1.35;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<ActivityProvider>().ensureLoaded(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();

    if (provider.isBusyFor(widget.userId)) {
      return const Padding(
        padding: AppPaddings.activityTile,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final error = provider.error;
    if (error != null) return _error(context, error);

    final activities = provider.activities;
    if (activities.isEmpty) {
      return _message(
        context,
        icon: AppIcons.task,
        title: 'Henüz Aktivite Yok',
        message: 'Etkinliklere kaydoldukça ve katıldıkça burada görünecek.',
      );
    }

    return Column(
      children: [
        for (final activity in activities) ActivityTile(item: activity),
      ],
    );
  }

  Widget _error(BuildContext context, ApiException error) {
    return _message(
      context,
      icon: error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
      title: 'Aktiviteler Yüklenemedi',
      message: error.userMessage,
      onRetry: () => context.read<ActivityProvider>().refresh(widget.userId),
    );
  }

  Widget _message(
    BuildContext context, {
    required String icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: AppPaddings.activityTile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.activityIconCircle,
            child: Center(
              child: AppIcon(
                icon,
                size: AppSizes.iconLarge,
                color: context.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.bigSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.smallSpace),
                Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textTertiary,
                    height: _messageLineHeight,
                  ),
                ),
                if (onRetry != null)
                  GestureDetector(
                    onTap: onRetry,
                    child: Padding(
                      padding: AppPaddings.buttonInternalPadding,
                      child: Text(
                        'Tekrar Dene',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
