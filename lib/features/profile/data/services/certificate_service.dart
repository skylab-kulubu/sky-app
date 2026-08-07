import 'package:sky_app/features/profile/data/models/certificate.dart';

/// Sertifika verilerini sağlayan servis.
///
/// Backend API'si bağlandığında HTTP istekleri buraya eklenecektir.
class CertificateService {
  /// Kullanıcının sertifikalarını backend'den çeker.
  Future<List<Certificate>> getCertificates() async {
    return [];
  }
}
