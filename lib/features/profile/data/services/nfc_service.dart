import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sky_app/features/profile/data/models/nfc_card.dart';

/// NFC donanım iletişiminden sorumlu servis sınıfı.
///
/// Yalnızca ISO 14443-A standardındaki öğrenci kartlarını hedefler.
/// Tek kullanıcısı profil feature'ı olduğu için `core/services` yerine
/// burada yaşar.
class NfcService {
  /// Cihazın NFC durumunu kontrol eder.
  Future<NFCAvailability> checkAvailability() async {
    return FlutterNfcKit.nfcAvailability;
  }

  /// Yalnızca ISO 14443-A (Type A) kartları tarar.
  ///
  /// Diğer standartlar (14443B, 15693, 18092) filtrelenerek okuma
  /// hızlandırılır.
  Future<NfcCard> pollCard({
    Duration timeout = const Duration(seconds: 15),
    String iosAlertMessage =
        'Lütfen öğrenci kartınızı telefonun arkasına yaklaştırın...',
    String iosMultipleTagMessage = 'Birden fazla kart algılandı!',
  }) async {
    final NFCTag tag = await FlutterNfcKit.poll(
      timeout: timeout,
      iosAlertMessage: iosAlertMessage,
      iosMultipleTagMessage: iosMultipleTagMessage,
      readIso14443A: true,
      readIso14443B: false,
      readIso15693: false,
      readIso18092: false,
    );

    return NfcCard(
      rawUid: tag.id.toUpperCase(),
      cardType: tag.type.toString().split('.').last,
      cardStandard: tag.standard.toString().split('.').last,
      sak: tag.sak?.toUpperCase(),
      atqa: tag.atqa?.toUpperCase(),
      scannedAt: DateTime.now(),
    );
  }

  /// NFC oturumunu başarıyla veya hata mesajıyla sonlandırır.
  Future<void> finishSession({
    String? iosAlertMessage,
    String? iosErrorMessage,
  }) async {
    await FlutterNfcKit.finish(
      iosAlertMessage: iosAlertMessage,
      iosErrorMessage: iosErrorMessage,
    );
  }
}
