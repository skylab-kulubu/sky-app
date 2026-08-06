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
          '3 gün sürecek olan YILDIZ JAM 2026 ile oyun geliştirme dünyasına adım atın! Sektörden uzman konuşmacılar, indie oyun stantları ve 48 saatlik kesintisiz game jam heyecanı sizleri bekliyor.\n\nEtkinlik boyunca oyun tasarımı, 3D modelleme, ses tasarımı ve oyun motorları (Unity, Unreal Engine, Godot) üzerine teknik atölyeler düzenlenecektir. Takımınızı kurun ya da etkinlik alanında yeni ekip arkadaşlarıyla tanışarak fikrinizi hayata geçirin.\n\nDereceye giren takımlara ödül, kuluçka merkezi desteği ve yatırımcı sunumu imkanı sağlanacaktır. Tüm katılımcılara yemek servisi, dinlenme alanları ve sürpriz hediyeler ücretsiz olarak sunulacaktır.',
      location: 'Tarihi Hamam',
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
          'Algoritma ve veri yapıları bilginizi derinleştirecek, haftalık AGC yarışmaları ile problem çözme yeteneğinizi geliştirecek yoğun algoritma eğitimi başlıyor.\n\nEğitim içeriğinde Graf Teorisi, Dinamik Programlama, Veri Yapıları (Segment Tree, Fenwick Tree) ve İleri Düzey Matematiksel Algoritmalar yer almaktadır. Her seviyeden öğrenciye açık olan kampımızda teori anlatımlarının ardından canlı kodlama ve soru çözümleri gerçekleştirilecektir.\n\nICPC ve Teknofest gibi prestijli yarışmalara hazırlanmak, mülakat tekniklerini geliştirmek ve teknik düşünme becerilerini üst seviyeye taşımak isteyen tüm kulüp üyelerimizi bekliyoruz.',
      location: 'EEF-D-B12',
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
          'Türkiye\'nin en büyük öğrenci hackathonlarından HackYTÜ için hazır mısın? 36 saat boyunca kesintisiz kodlama, mentor desteği ve dev ödüller seni bekliyor.\n\nBu yıl belirlenen ana temalar çerçevesinde yapay zeka, sürdürülebilirlik, finans teknolojileri ve açık kaynak çözümler geliştireceğiz. Etkinlik boyunca sektörün önde gelen şirketlerinden tecrübeli yazılımcılar ve ürün yöneticileri sizlere birebir mentörlük sağlayacak.\n\nDonanım, sunucu altyapısı, gece ikramları ve kesintisiz internet imkanlarıyla desteklenen etkinlik sonunda jüri sunumları ve ödül töreni gerçekleştirilecektir.',
      location: 'Yemekhane',
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
          'Yapay Zeka, Makine Öğrenmesi ve Büyük Veri alanındaki son gelişmelerin ele alınacağı zirvemizde lider teknoloji firmalarından mühendislerle buluşun.\n\nBüyük Dil Modelleri (LLM), Bilgisayarlı Görüş (Computer Vision), Veri Mühendisliği altyapıları ve Otonom Sistemler üzerine paneller ve canlı demolar gerçekleşecektir. Sektördeki kariyer fırsatları, staj imkanları ve akademik araştırmalar hakkında merak ettiğiniz tüm soruları uzmanlara doğrudan sorma fırsatı yakalayacaksınız.\n\nZirve sonunda düzenlenecek networking oturumunda firma temsilcileri ve diğer katılımcılarla bağlantı kurabilirsiniz.',
      location: 'EEF Konferans',
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
          'Sıfırdan ileri seviyeye Flutter ile cross-platform mobil uygulama geliştirmeyi uygulamalı olarak öğreniyoruz. Kendi bilgisayarınızla katılabilirsiniz.\n\nAtölye süresince Dart dilinin temel prensipleri, Widget mimarisi, Provider & Riverpod ile durum yönetimi (State Management), REST API entegrasyonu ve yerel depolama teknikleri uygulamalı olarak işlenecektir.\n\nEtkinlik sonunda hep birlikte mağazaya yüklenebilecek kalitede örnek bir mobil uygulama geliştirip yayınlama sürecini adım adım tecrübe edeceğiz.',
      location: 'EEF-D-012',
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
