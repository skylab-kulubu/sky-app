import 'package:dio/dio.dart';
import 'package:sky_app/core/services/api_exception.dart';

/// Oturum yenileme denemesinin sonucu.
///
/// `bool` yetmiyordu: "yetkilendirme reddedildi" ile "sunucuya ulaşılamadı"
/// ayrımı, oturumun silinip silinmeyeceğine ve kullanıcının giriş ekranına
/// atılıp atılmayacağına karar veriyor.
enum RefreshOutcome {
  success,

  /// Yetkilendirme kesin olarak reddedildi; oturum artık geçersiz.
  unauthorized,

  /// Sunucuya ulaşılamadı. Oturum hakkında bir şey söylemiyor, korunmalı.
  networkFailure,
}

/// Access token'ı okuyabilen ve oturumu yenileyebilen kaynak.
///
/// [ApiClient] `core` altında ve oturumun nasıl tutulduğunu bilmiyor;
/// yalnızca bu iki işi isteyebiliyor. Somut karşılığı `features/auth`
/// içindeki `AuthService`, bağlama `main.dart`'ta yapılıyor.
abstract class TokenProvider {
  Future<String?> readAccessToken();

  Future<RefreshOutcome> refreshSession();
}

/// Uygulamanın tek yapılandırılmış [Dio] örneği.
///
/// Kimlik doğrulama sunucusuna (Keycloak) giden istekler buradan geçmez;
/// onlar `AuthService`'in kendi Dio'sunu kullanır. Sebebi döngü: yenileme
/// isteğinin kendisi 401 alsaydı interceptor tekrar yenilemeye girerdi.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String baseUrl = 'https://api.yildizskylab.com';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// 401 sonrası tekrarlanan isteği işaretler. İşaretli istek bir daha
  /// yenilemeye girmiyor; yoksa 401 → yenile → 401 döngüsü süresiz sürer.
  static const String _retriedKey = 'apiClientRetried';

  TokenProvider? _tokenProvider;

  /// Süren yenileme işi. Paralel 401'ler bunu paylaşıyor: her istek ayrı bir
  /// yenileme başlatsaydı Keycloak ilk kullanılan refresh token'ı geçersiz
  /// kılar ve kalan istekler oturumu düşürürdü.
  Future<RefreshOutcome>? _refreshInFlight;

  late final Dio dio = _buildDio();

  /// Uygulama açılışında `main.dart` çağırıyor.
  void attachTokenProvider(TokenProvider provider) => _tokenProvider = provider;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Sıra önemli: 401'i önce _AuthInterceptor görüp isteği kurtarmayı
    // deniyor; kurtaramazsa hata _ErrorInterceptor'a düşüp sınıflanıyor.
    dio.interceptors.addAll([_AuthInterceptor(this), _ErrorInterceptor()]);
    return dio;
  }

  Future<RefreshOutcome> _refreshOnce() {
    final provider = _tokenProvider;
    if (provider == null) return Future.value(RefreshOutcome.unauthorized);

    return _refreshInFlight ??= provider.refreshSession().whenComplete(() {
      _refreshInFlight = null;
    });
  }
}

/// İsteğe access token ekler; 401'de oturumu yenileyip isteği bir kez tekrarlar.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);

  final ApiClient _client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _attachToken(options);
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final bool canRetry =
        err.response?.statusCode == 401 &&
        options.extra[ApiClient._retriedKey] != true;

    if (!canRetry) return handler.next(err);

    final outcome = await _client._refreshOnce();
    if (outcome != RefreshOutcome.success) return handler.next(err);

    options.extra[ApiClient._retriedKey] = true;
    await _attachToken(options);

    try {
      handler.resolve(await _client.dio.fetch<dynamic>(options));
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  Future<void> _attachToken(RequestOptions options) async {
    final token = await _client._tokenProvider?.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }
}

/// [DioException]'ı sınıflandırıp `error` alanına [ApiException] koyar.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: ApiException.fromDio(err)));
  }
}
