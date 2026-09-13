import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

/// Aşağı çekerek etkinlikleri yenileme jesti.
///
/// Etkinlikler bir kez yükleniyor ve elde veri varken bir daha
/// istenmiyordu; kulüp yeni bir etkinlik açtığında uygulaması açık olan
/// kullanıcının bunu görmesinin yolu yoktu. Etkinlikler sekmesi ile ana
/// sayfa aynı provider'dan beslendiği için jest tek bir widget'ta toplandı.
///
/// [child] kaydırılabilir olmalı ve `AlwaysScrollableScrollPhysics`
/// taşımalı; içerik ekranı doldurmadığında aksi hâlde çekme hareketi hiç
/// başlamıyor.
///
/// Renkler tek tek verilmiyor: dönen halka `colorScheme.primary`'den (yani
/// `accentColor`), göstergenin zemini `theme.dart`'taki
/// `progressIndicatorTheme`den geliyor.
class EventsRefreshIndicator extends StatelessWidget {
  const EventsRefreshIndicator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // adaptive: iOS'ta Cupertino göstergesi çiziliyor, projedeki
    // `CircularProgressIndicator.adaptive` kullanımıyla aynı çizgide.
    return RefreshIndicator.adaptive(
      onRefresh: () => _refresh(context),
      child: child,
    );
  }

  /// Yenileme hatası eldeki listeyi karartmıyor: etkinlikler ekranda
  /// kalıyor, hata SnackBar ile bildiriliyor. Elde gösterilecek bir şey
  /// yoksa sayfanın kendi hata ekranı zaten görünüyor; üstüne bir de
  /// bildirim çıkmıyor.
  Future<void> _refresh(BuildContext context) async {
    final provider = context.read<EventProvider>();
    // Messenger await'ten önce alınıyor: sonrasında context kullanılırsa
    // widget ağaçtan kalkmış olabilir.
    final messenger = ScaffoldMessenger.of(context);

    await provider.refresh();

    final error = provider.error;
    if (error == null || provider.events.isEmpty) return;

    messenger.showSnackBar(SnackBar(content: Text(error.userMessage)));
  }
}
