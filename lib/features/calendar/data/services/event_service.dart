import 'dart:convert';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  static List<EventModel>? _cache;

  static Future<void> prefetch() async {
    _cache = await _fetch();
  }

  static Future<List<EventModel>> fetchEvents() async {
    if (_cache != null) return _cache!;
    _cache = await _fetch();
    return _cache!;
  }

  static Future<List<EventModel>> _fetch() async {
    const String rawJson = '''
{
  "success": true,
  "message": "event.success.get.all.events",
  "httpStatus": "OK",
  "path": "/api/events",
  "timeStamp": "2026-04-26 21:13:55",
  "data": [
    {
      "id": "74ec0626-1577-462e-b036-efa90dcda833",
      "name": "AGC",
      "coverImageUrl": "https://cdn.yildizskylab.com/images/0f42d00e-f880-498f-9d4b-ca89b0bd4dfa",
      "description": "AGC ETKİNLİK BRA",
      "location": "YTÜ Davutpaşa Kampüsü",
      "type": {
        "id": "e486e051-3f97-43ed-9ce6-8863a9225207",
        "name": "AGC",
        "authorizedRoles": ["ALGOLAB", "ALGOLAB_LEADER"]
      },
      "formUrl": "https://forms.gle/example",
      "startDate": "2026-04-10T10:00:00",
      "endDate": "2026-04-10T18:00:00",
      "linkedin": "https://linkedin.com/company/ytuskylab",
      "active": true,
      "season": {
        "id": "18b7adaa-df06-4c7d-a025-17c9a6e85b5e",
        "name": "2025-2026 DÖNEMİ AGC SEZONU",
        "startDate": "2025-05-01T12:00:00",
        "endDate": "2026-05-01T12:00:00",
        "active": true
      },
      "imageUrls": [],
      "ranked": false
    },
    {
      "id": "e96aefc0-8f9e-41cb-8f7e-8fbb754984f0",
      "name": "BİZBİZE TEST",
      "coverImageUrl": "https://cdn.yildizskylab.com/images/58e96cf4-39b2-4a75-b9fd-6da1597367db",
      "description": "BİZBİZE TEST ETKİNLİĞİ",
      "location": "YTÜ Davutpaşa Kamoüsü Şevket Erk Salonu",
      "type": {
        "id": "110201c5-b5e9-4ceb-ab8e-14d07582b62d",
        "name": "BIZBIZE",
        "authorizedRoles": ["BIZBIZE_LEADER", "BIZBIZE"]
      },
      "formUrl": "https://skyl.app/bizbize",
      "startDate": "2026-04-10T10:00:00",
      "endDate": "2026-04-10T18:00:00",
      "linkedin": "https://linkedin.com/company/ytuskylab",
      "active": true,
      "season": {
        "id": "65973f17-c66d-42c3-a88a-c0f7852f30f7",
        "name": "2025-2026 DÖNEMİ BİZBİZE SEZONU",
        "startDate": "2026-05-01T12:00:00",
        "endDate": "2025-05-01T12:00:00",
        "active": true
      },
      "imageUrls": [],
      "ranked": false
    },
    {
      "id": "3ff2e674-8b56-4bef-a929-206954f0ec50",
      "name": "BİZBİZE ESKİ",
      "coverImageUrl": "https://cdn.yildizskylab.com/images/8df21883-84b6-4c6b-b92e-95f056fcbc72",
      "description": "BİZBİZE TEST ETKİNLİĞİ",
      "location": "YTÜ Davutpaşa Kamoüsü Şevket Erk Salonu",
      "type": {
        "id": "110201c5-b5e9-4ceb-ab8e-14d07582b62d",
        "name": "BIZBIZE",
        "authorizedRoles": ["BIZBIZE_LEADER", "BIZBIZE"]
      },
      "formUrl": "https://skyl.app/bizbize",
      "startDate": "2026-04-10T10:00:00",
      "endDate": "2026-04-10T18:00:00",
      "linkedin": "https://linkedin.com/company/ytuskylab",
      "active": false,
      "season": {
        "id": "65973f17-c66d-42c3-a88a-c0f7852f30f7",
        "name": "2025-2026 DÖNEMİ BİZBİZE SEZONU",
        "startDate": "2026-05-01T12:00:00",
        "endDate": "2025-05-01T12:00:00",
        "active": true
      },
      "imageUrls": [],
      "ranked": false
    }
  ]
}
''';

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(rawJson);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => EventModel.fromJson(json as Map<String, dynamic>)).toList().cast<EventModel>();
      }
    } catch (e) {
      return [];
    }

    return [];
  }
}
