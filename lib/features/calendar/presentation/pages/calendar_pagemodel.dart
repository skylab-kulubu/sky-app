part of 'calendar_page.dart';

abstract class CalendarPagemodel extends State<CalendarPage> {
  /// Kartlar arası boşluk; ayraç görevini de görüyor.
  static const double _cardGap = 16.0;

  /// İlk yükleme bitmedi. Sonraki yüklemelerde ortada spinner yok; liste ya da
  /// mesaj yerinde kalıyor.
  bool isBusy(EventProvider provider) => !provider.isInitialized;

  void onRetry() => context.read<EventProvider>().refresh();
}
