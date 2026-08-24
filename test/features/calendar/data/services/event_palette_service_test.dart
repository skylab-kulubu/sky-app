import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/features/calendar/data/services/event_palette_service.dart';

void main() {
  group('EventPaletteService', () {
    testWidgets('cached returns empty list for unknown event', (tester) async {
      final colors = EventPaletteService.cached('unknown-event');
      expect(colors, isEmpty);
    });

    testWidgets('resolve handles empty url gracefully and returns empty list', (tester) async {
      final eventId = 'empty-url-event';
      
      // Start the resolve process
      final future = EventPaletteService.resolve(eventId: eventId, imageUrl: '');
      
      // EventPaletteService waits for SchedulerBinding.instance.endOfFrame
      // We need to pump the frame to trigger endOfFrame
      await tester.pumpAndSettle();

      final colors = await future;
      
      // Since url is empty, providerFor should be null or fail, resulting in empty list
      expect(colors, isEmpty);
      
      // After resolving, cached should also return the stored empty list
      expect(EventPaletteService.cached(eventId), isEmpty);
    });

    testWidgets('resolve caches the future so concurrent calls return the same future', (tester) async {
      final eventId = 'concurrent-event';
      
      final future1 = EventPaletteService.resolve(eventId: eventId, imageUrl: '');
      final future2 = EventPaletteService.resolve(eventId: eventId, imageUrl: '');
      
      // Same future instance should be returned from _pending
      expect(identical(future1, future2), isTrue);
      
      await tester.pumpAndSettle();
      await future1;
    });
  });
}
