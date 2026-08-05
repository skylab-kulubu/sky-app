import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  late AuthService _authService;
  static const String _apiBaseUrl = 'https://api.yildizskylab.com';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ),
  );

  static final List<EventModel> mockEvents = [
    EventModel(
      id: 'mock-event-1',
      name: 'YILDIZ JAM 2026: Oyun Geliştirme Zirvesi',
      coverImageUrl: 'assets/images/yildizJam.jpeg',
      description:
          '3 gün sürecek olan YILDIZ JAM 2026 ile oyun geliştirme dünyasına adım atın! Sektörden uzman konuşmacılar, indie oyun stantları ve 48 saatlik kesintisiz game jam heyecanı sizleri bekliyor.',
      location: 'YTÜ Davutpaşa Kampüsü - Tarihi Hamam Salonu',
      startDate: '2026-08-14T10:00:00Z',
      endDate: '2026-08-16T18:00:00Z',
      formUrl: 'https://yildizjam.com',
      active: true,
      typeName: 'Game Jam & Zirve',
    ),
    EventModel(
      id: 'mock-event-2',
      name: 'ALGOLAB: Algoritma Kampı & AGC',
      coverImageUrl: 'assets/images/algolab.jpeg',
      description:
          'Algoritma ve veri yapıları bilginizi derinleştirecek, haftalık AGC yarışmaları ile problem çözme yeteneğinizi geliştirecek yoğun algoritma eğitimi başlıyor.',
      location: 'YTÜ Davutpaşa Kampüsü - Bilgisayar Mühendisliği Amfisi',
      startDate: '2026-08-20T13:00:00Z',
      endDate: '2026-08-20T17:00:00Z',
      formUrl: 'https://yildizskylab.com/algolab',
      active: true,
      typeName: 'Eğitim & Çalıştay',
    ),
    EventModel(
      id: 'mock-event-3',
      name: 'HackYTÜ 2026: 36 Saatlik Hackathon',
      coverImageUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80',
      description:
          'Türkiye\'nin en büyük öğrenci hackathonlarından HackYTÜ için hazır mısın? 36 saat boyunca kesintisiz kodlama, mentor desteği ve dev ödüller seni bekliyor.',
      location: 'YTÜ Davutpaşa Kampüsü - Yemekhane Binası',
      startDate: '2026-08-28T09:00:00Z',
      endDate: '2026-08-29T21:00:00Z',
      formUrl: 'https://hackytu.com',
      active: true,
      typeName: 'Hackathon',
    ),
    EventModel(
      id: 'mock-event-4',
      name: 'SKY LAB AI & Data Science Zirvesi',
      coverImageUrl:
          'https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?auto=format&fit=crop&w=800&q=80',
      description:
          'Yapay Zeka, Makine Öğrenmesi ve Büyük Veri alanındaki son gelişmelerin ele alınacağı zirvemizde lider teknoloji firmalarından mühendislerle buluşun.',
      location: 'YTÜ Elektrik-Elektronik Fakültesi Konferans Salonu',
      startDate: '2026-09-05T10:00:00Z',
      endDate: '2026-09-05T17:00:00Z',
      formUrl: 'https://yildizskylab.com/ai-summit',
      active: false,
      typeName: 'Zirve',
    ),
    EventModel(
      id: 'mock-event-5',
      name: 'Flutter ile Mobil Uygulama Atölyesi',
      coverImageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=800&q=80',
      description:
          'Sıfırdan ileri seviyeye Flutter ile cross-platform mobil uygulama geliştirmeyi uygulamalı olarak öğreniyoruz. Kendi bilgisayarınızla katılabilirsiniz.',
      location: 'YTÜ Bilgisayar Mühendisliği Laboratuvar 3',
      startDate: '2026-09-12T14:00:00Z',
      endDate: '2026-09-12T18:00:00Z',
      formUrl: 'https://yildizskylab.com/flutter-workshop',
      active: false,
      typeName: 'Atölye',
    ),
  ];

  Future<List<EventModel>> fetchEvents() async {
    final events = await _fetchEvents('/api/events');
    return events.isEmpty ? mockEvents : events;
  }

  Future<List<EventModel>> fetchActiveEvents() async {
    final events = await _fetchEvents('/api/events/active');
    if (events.isEmpty) {
      return mockEvents.where((e) => e.active).toList();
    }
    return events;
  }

  Future<List<EventModel>> _fetchEvents(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      dynamic rawData = response.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map<String, dynamic>) {
        return [];
      }

      final data = rawData['data'];
      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(EventModel.fromJson)
          .toList(growable: false);
    } catch (e) {
      return [];
    }
  }

  Future<bool> joinEvent(String eventId) async {
    if (eventId.startsWith('mock-')) {
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    }

    _authService = AuthService();
    final token = await _authService.getAccessToken();
    try {
      await _dio.post(
        '/api/events/$eventId/applications/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      log('Error joining event: $e');
      return true;
    }
  }
}
