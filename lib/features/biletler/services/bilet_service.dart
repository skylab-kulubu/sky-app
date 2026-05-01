import 'package:sky_app/features/biletler/models/bilet.dart';

class BiletService {
  /// Şu an mock — yarın: return http.get('/api/biletler')
  static Future<List<Bilet>> getBiletler() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockBiletler;
  }

  static final _mockBiletler = [
    const Bilet(
      id: '1',
      etkinlikAdi: 'HACKATHON 2026',
      yer: 'Tarihi Hamam',
      tarih: '16.02.2026',
      saat: '22:00',
      biletKodu: '9916150/20532707',
      qrData: 'EVT-HACK2026-9916150',
      adSoyad: 'Kağan Kıvanç',
      status: BiletStatus.active,
    ),
    const Bilet(
      id: '2',
      etkinlikAdi: 'Flutter Summit',
      yer: 'Zorlu PSM',
      tarih: '20.03.2026',
      saat: '14:00',
      biletKodu: '1234567/89012345',
      qrData: 'EVT-FLUTTER-1234567',
      adSoyad: 'Kağan Kıvanç',
      status: BiletStatus.active,
    ),
    const Bilet(
      id: '3',
      etkinlikAdi: 'AI Konferansı',
      yer: 'İTÜ Kongre Merkezi',
      tarih: '12.03.2026',
      saat: '13:00',
      biletKodu: '9876543/21098765',
      qrData: 'EVT-AI2026-9876543',
      adSoyad: 'Kağan Kıvanç',
      status: BiletStatus.past,
    ),
    const Bilet(
      id: '4',
      etkinlikAdi: 'UX Design Meetup',
      yer: 'Kolektif House',
      tarih: '01.02.2026',
      saat: '19:00',
      biletKodu: '1122334/45566778',
      qrData: 'EVT-UX2026-1122334',
      adSoyad: 'Kağan Kıvanç',
      status: BiletStatus.past,
    ),
  ];
}