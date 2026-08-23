import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sky_app/features/profile/data/models/nfc_card.dart';

/// NFC donanım iletişiminden sorumlu servis sınıfı.
///
/// Yalnızca ISO 14443-A standardındaki öğrenci kartlarını hedefler.
class NfcService {
  Future<NFCAvailability> checkAvailability() async {
    return FlutterNfcKit.nfcAvailability;
  }

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

    return NfcCard(rawUid: tag.id.toUpperCase(), scannedAt: DateTime.now());
  }

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
