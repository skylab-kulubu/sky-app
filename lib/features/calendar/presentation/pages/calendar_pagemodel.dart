part of 'calendar_page.dart';

abstract class CalendarPagemodel extends State<CalendarPage> {
  /// Kartlar arası boşluk. Kartın kendi zemini olduğu için ayraç görevini
  /// de bu boşluk görüyor.
  static const double _cardGap = 16.0;

  /// Liste henüz gösterilemiyor: ilk yükleme bitmedi.
  ///
  /// Sonraki yüklemelerde ortada spinner yok; ekrandaki liste ya da mesaj
  /// yerinde kalıyor, geri bildirimi aşağı çekme göstergesi veya "Tekrar
  /// Dene" butonu veriyor.
  bool isBusy(EventProvider provider) => !provider.isInitialized;

  void onRetry() => context.read<EventProvider>().refresh();
}
