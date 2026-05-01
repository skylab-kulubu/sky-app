// ── lib/features/biletler/models/bilet.dart ─────────────────────────────────

enum BiletStatus { active, past }

class Bilet {
  final String id;
  final String etkinlikAdi;
  final String yer;
  final String tarih;       // "16.02.2026"
  final String saat;        // "22:00"
  final String biletKodu;   // "9916150/20532707"
  final String qrData;      // QR'da encode edilecek string
  final String? gorselUrl;
  final String adSoyad;
  final BiletStatus status;

  const Bilet({
    required this.id,
    required this.etkinlikAdi,
    required this.yer,
    required this.tarih,
    required this.saat,
    required this.biletKodu,
    required this.qrData,
    required this.adSoyad,
    this.gorselUrl,
    required this.status,
  });

  /// JSON'dan model üret — backend hazır
  factory Bilet.fromJson(Map<String, dynamic> json) => Bilet(
    id: json['id'] as String,
    etkinlikAdi: json['etkinlik_adi'] as String,
    yer: json['yer'] as String,
    tarih: json['tarih'] as String,
    saat: json['saat'] as String,
    biletKodu: json['bilet_kodu'] as String,
    qrData: json['qr_data'] as String,
    adSoyad: json['ad_soyad'] as String,
    gorselUrl: json['gorsel_url'] as String?,
    status: (json['status'] as String) == 'active'
        ? BiletStatus.active
        : BiletStatus.past,
  );
}

// ── lib/features/biletler/services/bilet_service.dart ───────────────────────

class BiletService {
  /// Şu an mock — yarın: return http.get('/api/biletler')
  static Future<List<Bilet>> getBiletler() async {
    await Future.delayed(const Duration(milliseconds: 600)); // simüle loading
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
      gorselUrl: null,
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
      gorselUrl: null,
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
      gorselUrl: null,
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
      gorselUrl: null,
      status: BiletStatus.past,
    ),
  ];
}