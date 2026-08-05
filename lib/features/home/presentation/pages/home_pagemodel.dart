part of 'home_page.dart';

abstract class HomePagemodel extends State<HomePage> {
  static const double _sectionSpacing = 32.0;
  static const double _titleSpacing = 16.0;
  static const double _newsItemGap = 4.0;

  /// Ana sayfada gösterilen yaklaşan etkinlik sayısı; gerisi Etkinlikler
  /// sekmesinde.
  static const int _maxUpcomingEvents = 3;
}
