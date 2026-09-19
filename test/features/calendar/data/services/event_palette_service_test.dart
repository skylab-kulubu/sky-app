import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/features/calendar/data/services/event_palette_service.dart';

void main() {
  group('EventPaletteService', () {
    test('cached returns empty list for an unknown cover', () {
      final colors = EventPaletteService.cached('https://example.com/x.jpg');
      expect(colors, isEmpty);
    });

    test('resolve returns empty list for an empty url', () async {
      final colors = await EventPaletteService.resolve('');

      expect(colors, isEmpty);
      expect(EventPaletteService.cached(''), isEmpty);
    });
  });
}
