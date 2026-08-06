part of 'calendar_page.dart';

abstract class CalendarPagemodel extends State<CalendarPage> {
  /// Kartlar arası boşluk. Kartın kendi zemini olduğu için ayraç görevini
  /// de bu boşluk görüyor.
  static const double _cardGap = 16.0;

  /// Liste henüz gösterilemiyor: ya splash'teki ilk yükleme bitmedi ya da
  /// elde gösterilecek bir şey yokken yenileme sürüyor.
  bool isBusy(EventProvider provider) {
    if (!provider.isInitialized && !provider.isLoading) return true;
    return provider.isLoading && provider.events.isEmpty;
  }
}
