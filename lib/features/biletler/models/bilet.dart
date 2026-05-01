enum BiletStatus { active, past }

class Bilet {
  final String id;
  final String etkinlikAdi;
  final String yer;
  final String tarih;
  final String saat;
  final String biletKodu;
  final String qrData;
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