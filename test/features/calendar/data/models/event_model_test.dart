import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

void main() {
  group('EventModel', () {
    test('startDateTime and endDateTime parse correctly', () {
      final event = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00Z',
        endDate: '2026-08-16T18:00:00Z',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );

      expect(event.startDateTime, isNotNull);
      expect(event.startDateTime!.year, 2026);
      expect(event.startDateTime!.month, 8);
      expect(event.startDateTime!.day, 14);

      expect(event.endDateTime, isNotNull);
      expect(event.endDateTime!.year, 2026);
      expect(event.endDateTime!.month, 8);
      expect(event.endDateTime!.day, 16);
    });

    test('startDateTime and endDateTime handle empty/invalid strings', () {
      final event = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '',
        endDate: 'invalid-date',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );

      expect(event.startDateTime, isNull);
      expect(event.endDateTime, isNull);
    });

    test('isMultiDay is true for different days and false for same day', () {
      final multiDayEvent = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '2026-08-16T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(multiDayEvent.isMultiDay, isTrue);

      final singleDayEvent = EventModel(
        id: '2',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '2026-08-14T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(singleDayEvent.isMultiDay, isFalse);
    });

    test('eventDays returns all days between start and end dates inclusive', () {
      final event = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '2026-08-16T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );

      final days = event.eventDays;
      expect(days.length, 3);
      expect(days[0].day, 14);
      expect(days[1].day, 15);
      expect(days[2].day, 16);
    });

    test('eventDays returns empty list when dates are invalid', () {
      final event = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '',
        endDate: '',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );

      expect(event.eventDays, isEmpty);
    });

    test('formattedDate returns formatted string or original if parse fails', () {
      final validEvent = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(validEvent.formattedDate, '14.08.2026');

      final invalidEvent = EventModel(
        id: '2',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: 'invalid',
        endDate: '',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(invalidEvent.formattedDate, 'invalid');
    });

    test('formattedTime returns HH:mm or empty if parse fails', () {
      final validEvent = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T09:05:00.000',
        endDate: '',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(validEvent.formattedTime, '09:05');

      final invalidEvent = EventModel(
        id: '2',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: 'invalid',
        endDate: '',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(invalidEvent.formattedTime, isEmpty);
    });

    test('formattedDayLabel handles single and multi-day events correctly', () {
      final singleDayEvent = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000', // Friday
        endDate: '2026-08-14T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(singleDayEvent.formattedDayLabel, '14 Ağustos Cuma');

      final multiDaySameMonth = EventModel(
        id: '2',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '2026-08-16T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(multiDaySameMonth.formattedDayLabel, '14 – 16 Ağustos 2026');

      final multiDayDiffMonth = EventModel(
        id: '3',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-30T10:00:00.000',
        endDate: '2026-09-02T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(multiDayDiffMonth.formattedDayLabel, '30 Ağustos – 2 Eylül 2026');
    });

    test('formattedTimeRange formats correctly for single/multi day and missing end', () {
      final singleDayEvent = EventModel(
        id: '1',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:30:00.000',
        endDate: '2026-08-14T18:45:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(singleDayEvent.formattedTimeRange, '10:30 – 18:45');

      final multiDayEvent = EventModel(
        id: '2',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '2026-08-16T18:00:00.000',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(multiDayEvent.formattedTimeRange, '10:00'); // only start time for multi-day

      final noEndEvent = EventModel(
        id: '3',
        name: 'Test Event',
        coverImageUrl: '',
        description: '',
        location: '',
        startDate: '2026-08-14T10:00:00.000',
        endDate: '',
        formUrl: '',
        active: true,
        typeName: 'Test',
      );
      expect(noEndEvent.formattedTimeRange, '10:00'); // only start time if no end time
    });
  });
}
