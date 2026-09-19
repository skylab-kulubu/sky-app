import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/profile/data/models/certificate.dart';

/// Kullanıcının sertifikaları (core `GET /v1/certificates/me`).
class CertificateService {
  /// Bütün sertifikalar, yeniden eskiye; iptal edilenler de (geçmiş olarak)
  /// dahil. Boş liste gerçekten sertifika yok demek; ağ ve çözümleme
  /// hataları `ApiException` olarak fırlıyor, boş listeye dönüşmüyor.
  Future<List<Certificate>> getCertificates() async {
    final body = await CoreApi.get('/certificates/me');
    return CoreApi.list(
        body,
        what: 'sertifika listesi',
      ).map(Certificate.fromJson).where((c) => c.serial.isNotEmpty).toList()
      ..sort((a, b) {
        final aDate = a.issuedAt;
        final bDate = b.issuedAt;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });
  }
}
