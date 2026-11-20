import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/profile/data/models/certificate.dart';

class CertificateService {
  /// Yeniden eskiye, iptal edilenler dahil. Hata boş listeye dönüşmüyor,
  /// `ApiException` olarak fırlıyor.
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
