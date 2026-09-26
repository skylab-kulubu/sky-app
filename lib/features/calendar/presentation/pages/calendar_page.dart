import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/events_refresh_indicator.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_card.dart';

part 'calendar_pagemodel.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends CalendarPagemodel {
  @override
  void initState() {
    super.initState();
    // Sayfa ihtiyacı olan veriyi kendisi istiyor; splash'teki çağrı yalnızca
    // bir ön yükleme. Yoksa splash'i atlayan her giriş yolunda (taze giriş,
    // web callback) liste kalıcı olarak boş kalıyordu.
    //
    // Kare bitişi bekleniyor: initState hâlâ build fazının içinde ve
    // yükleme senkron bir `notifyListeners` ile başlıyor — build sırasında
    // çağrılırsa markNeedsBuild hatası veriyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<EventProvider>().ensureLoaded());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          body: EventsRefreshIndicator(child: _body(context, eventProvider)),
        );
      },
    );
  }

  /// Sayfanın durumu: ilk yükleme, hata, boş liste, aramada sonuç yok ya da
  /// listenin kendisi.
  ///
  /// Hepsi tek bir [EventsRefreshIndicator]'ın altında kalıyor; yoksa
  /// durum değiştiğinde gösterge ağaçtan kalkıp jest yarıda kesiliyor.
  Widget _body(BuildContext context, EventProvider eventProvider) {
    if (isBusy(eventProvider)) {
      return _scrollable(
        const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // Hata boş durumdan ayrı: "etkinlik yok" bilgi, "yüklenemedi" ise
    // kullanıcının tekrar deneyebileceği bir arıza. Elde liste varken
    // yenileme hatası sayfayı kaplamıyor, SnackBar'a düşüyor.
    final error = eventProvider.error;
    if (error != null && eventProvider.events.isEmpty) {
      return _scrollable(_error(context, error, eventProvider.isLoading));
    }

    if (eventProvider.events.isEmpty) return _scrollable(_empty(context));

    final events = eventProvider.searchedEvents;
    if (events.isEmpty) return _scrollable(_noResults(context));

    return _list(events);
  }

  /// Liste dışındaki durumları kaydırılabilir yapar.
  ///
  /// [RefreshIndicator] altında kaydırılabilir bir çocuk ister; `Center`
  /// doğrudan verilirse liste boşken — aşağı çekmenin en çok gerektiği
  /// durumda — jest hiç başlamıyor.
  Widget _scrollable(Widget child) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );
  }

  Widget _error(BuildContext context, ApiException error, bool isRetrying) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              'Etkinlikler Yüklenemedi',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            const SizedBox(height: AppSizes.largeSpace),
            SkyButton(
              text: 'Tekrar Dene',
              onPressed: onRetry,
              isLoading: isRetrying,
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<EventModel> events) {
    return ListView.separated(
      // Liste ekranı doldurmasa da aşağı çekilebilsin.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppPaddings.mainPaddingAll,
      // Son kart yüzen navbar'ın altında kalmasın diye listeye bir öğe
      // fazla pay bırakılıyor.
      itemCount: events.length + 1,
      separatorBuilder: (_, _) =>
          const SizedBox(height: CalendarPagemodel._cardGap),
      itemBuilder: (context, index) {
        if (index == events.length) {
          return const SizedBox(height: AppSizes.navBarClearance);
        }

        final event = events[index];
        return EventCard(key: Key(event.id), event: event);
      },
    );
  }

  Widget _empty(BuildContext context) {
    return _message(
      context,
      icon: AppIcons.calendar,
      title: 'Etkinlik Yok',
      message: 'Yeni bir etkinlik açıldığında burada görünecek.',
    );
  }

  Widget _noResults(BuildContext context) {
    return _message(
      context,
      icon: AppIcons.search,
      title: 'Sonuç Yok',
      message: 'Aramana uyan bir etkinlik bulunamadı.',
    );
  }

  Widget _message(
    BuildContext context, {
    required String icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              message,
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
