import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

/// Aşağı çekerek etkinlikleri yenileme; Etkinlikler ve ana sayfa aynı
/// provider'dan beslendiği için tek widget.
///
/// [child] kaydırılabilir olmalı ve `AlwaysScrollableScrollPhysics` taşımalı;
/// yoksa içerik ekranı doldurmadığında çekme başlamıyor.
class EventsRefreshIndicator extends StatelessWidget {
  const EventsRefreshIndicator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () => _refresh(context),
      child: child,
    );
  }

  /// Yenileme hatası eldeki listeyi silmiyor, SnackBar ile bildiriliyor. Elde
  /// liste yoksa sayfanın kendi hata ekranı zaten görünüyor.
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
