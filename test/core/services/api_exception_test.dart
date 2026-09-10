import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_app/core/services/api_exception.dart';

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  Object? error,
}) {
  final options = RequestOptions(path: '/api/events');
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  group('ApiException.fromDio', () {
    test('bağlantı hataları network olarak sınıflanır', () {
      expect(
        ApiException.fromDio(_dioError(DioExceptionType.connectionError)).type,
        ApiErrorType.network,
      );
      expect(
        ApiException.fromDio(_dioError(DioExceptionType.badCertificate)).type,
        ApiErrorType.network,
      );
    });

    test('timeout türleri timeout olarak sınıflanır', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          ApiException.fromDio(_dioError(type)).type,
          ApiErrorType.timeout,
        );
      }
    });

    test('durum kodu badResponse içinde ayrıştırılır', () {
      ApiErrorType typeOf(int statusCode) => ApiException.fromDio(
        _dioError(DioExceptionType.badResponse, statusCode: statusCode),
      ).type;

      expect(typeOf(401), ApiErrorType.auth);
      expect(typeOf(403), ApiErrorType.auth);
      expect(typeOf(404), ApiErrorType.notFound);
      expect(typeOf(500), ApiErrorType.server);
      expect(typeOf(503), ApiErrorType.server);
      expect(typeOf(418), ApiErrorType.unknown);
    });

    // Oturumun silinip silinmeyeceğine bu ayrım karar veriyor.
    test('isConnectivityIssue yalnızca ağ ve timeout için true', () {
      expect(
        const ApiException(ApiErrorType.network).isConnectivityIssue,
        isTrue,
      );
      expect(
        const ApiException(ApiErrorType.timeout).isConnectivityIssue,
        isTrue,
      );
      expect(
        const ApiException(ApiErrorType.auth).isConnectivityIssue,
        isFalse,
      );
      expect(
        const ApiException(ApiErrorType.server).isConnectivityIssue,
        isFalse,
      );
    });
  });

  group('ApiException.from', () {
    test('interceptor ın koyduğu sınıflandırmayı çıkarır', () {
      const inner = ApiException(ApiErrorType.notFound, statusCode: 404);
      final wrapped = _dioError(
        DioExceptionType.badResponse,
        statusCode: 404,
        error: inner,
      );

      expect(identical(ApiException.from(wrapped), inner), isTrue);
    });

    test('sınıflandırma yoksa DioException ı yeniden sınıflar', () {
      final raw = _dioError(DioExceptionType.badResponse, statusCode: 500);

      expect(ApiException.from(raw).type, ApiErrorType.server);
    });

    test('ApiException doğrudan geçer, tanımsız hata unknown olur', () {
      const existing = ApiException(ApiErrorType.timeout);

      expect(identical(ApiException.from(existing), existing), isTrue);
      expect(
        ApiException.from(FormatException('bozuk')).type,
        ApiErrorType.unknown,
      );
    });
  });
}
