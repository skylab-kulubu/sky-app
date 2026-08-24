import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/features/calendar/data/services/event_palette_service.dart';

void main() {
  group('EventPaletteService', () {
    testWidgets('cached returns empty list for unknown event', (tester) async {
      final colors = EventPaletteService.cached('unknown-event');
      expect(colors, isEmpty);
    });

    testWidgets(
      'resolve handles empty url gracefully and caches the future for concurrent calls',
      (tester) async {
        final eventId = 'empty-url-event';

        final future = EventPaletteService.resolve(
          eventId: eventId,
          imageUrl: '',
        );

        // Schedule a frame so SchedulerBinding.instance.endOfFrame can complete
        await tester.pumpWidget(const SizedBox());
        await tester.pump();

        final colors = await future;

        expect(colors, isEmpty);
        expect(EventPaletteService.cached(eventId), isEmpty);

        // Second part: concurrent calls
        final eventId2 = 'concurrent-event';
        final future1 = EventPaletteService.resolve(
          eventId: eventId2,
          imageUrl: '',
        );
        final future2 = EventPaletteService.resolve(
          eventId: eventId2,
          imageUrl: '',
        );

        expect(identical(future1, future2), isTrue);

        // Schedule a frame so the pending future can complete cleanly
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        await future1;
      },
    );
  });
}
