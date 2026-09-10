import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/home/presentation/widgets/upcoming_event_tile.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/home/data/services/news_service.dart';
import 'package:sky_app/features/home/presentation/widgets/news_tile.dart';

part 'home_pagemodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends HomePagemodel {
  @override
  void initState() {
    super.initState();
    // Yaklaşan etkinlikler bölümü de aynı provider'dan besleniyor; sayfa
    // kendi verisini istiyor. Çağrı idempotent, Etkinlikler sekmesiyle
    // yarışması sorun değil.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<EventProvider>().ensureLoaded());
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppPaddings.mainPaddingVertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppPaddings.mainPaddingHorizontal,
              child: _sectionHeader(
                context,
                'Yaklaşan Etkinlikler',
                onSeeAll: () => context.go('/calendar'),
              ),
            ),
            const SizedBox(height: HomePagemodel._titleSpacing),
            _upcomingEvents(context),
            const SizedBox(height: HomePagemodel._sectionSpacing),
            Padding(
              padding: AppPaddings.mainPaddingHorizontal,
              child: _sectionHeader(context, 'Haberler'),
            ),
            const SizedBox(height: HomePagemodel._titleSpacing),
            _newsList(),
            const SizedBox(height: AppSizes.navBarClearance),
          ],
        ),
      ),
    );
  }

  Widget _newsList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: NewsService.list.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: HomePagemodel._newsItemGap),
      itemBuilder: (context, index) => NewsTile(item: NewsService.list[index]),
    );
  }

  /// Yaklaşan etkinlikler; hiç yoksa sayfa boş görünmesin diye bilgi kartı,
  /// yüklenemediyse tekrar denenebilen hata satırı.
  Widget _upcomingEvents(BuildContext context) {
    final provider = context.watch<EventProvider>();

    final error = provider.error;
    if (error != null) return _eventsError(context, error);

    final events = provider.upcomingEvents;

    if (events.isEmpty) return _emptyEvents(context);

    final visible = events.take(HomePagemodel._maxUpcomingEvents).toList();

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: HomePagemodel._newsItemGap),
      itemBuilder: (context, index) => UpcomingEventTile(event: visible[index]),
    );
  }

  Widget _emptyEvents(BuildContext context) {
    return Padding(
      padding: AppPaddings.newsTile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon, tile'lardaki görselle aynı genişlikte bir alana ortalanıyor;
          // böylece metinler alttaki haber başlıklarıyla aynı hizada başlıyor.
          SizedBox(
            width: AppSizes.thumbnail,
            child: Center(
              child: AppIcon(
                AppIcons.calendar,
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
                  'Yaklaşan Etkinlik Yok',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.smallSpace),
                Text(
                  'Katılabileceğin etkinlikler burada görünecek.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textTertiary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Etkinlikler yüklenemedi. Boş durumla aynı satır düzeninde duruyor ki
  /// haber başlıklarıyla hizası bozulmasın.
  Widget _eventsError(BuildContext context, ApiException error) {
    return Padding(
      padding: AppPaddings.newsTile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.thumbnail,
            child: Center(
              child: AppIcon(
                error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
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
                  'Etkinlikler Yüklenemedi',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.smallSpace),
                Text(
                  error.userMessage,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textTertiary,
                    height: 1.35,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.read<EventProvider>().refresh(),
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

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Tümünü Gör',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSizes.smallSpace),
                AppIcon(
                  AppIcons.chevronRight,
                  size: AppSizes.iconSmall,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
