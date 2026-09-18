import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

/// Ağa çıkmayan [EventProvider]. Sayfaların hangi duruma ne çizdiğini
/// sınamak için var; yüklemenin kendisi provider testinde sınanıyor.
///
/// Getter'lar override edilirken üst sınıfın alanları olduğu gibi kalıyor:
/// [ensureLoaded] de override edildiği için gerçek yükleme hiç başlamıyor.
class FakeEventProvider extends EventProvider {
  FakeEventProvider({
    List<EventModel> events = const [],
    ApiException? error,
    bool initialized = true,
    bool loading = false,
  }) : _currentEvents = events,
       _currentError = error,
       _startInitialized = initialized,
       _startLoading = loading;

  List<EventModel> _currentEvents;
  ApiException? _currentError;
  final bool _startInitialized;
  final bool _startLoading;

  /// Yenileme bittiğinde listenin alacağı değer; null ise liste korunur.
  List<EventModel>? nextEvents;

  /// Yenileme bittiğinde hatanın alacağı değer.
  ApiException? nextError;

  /// [refresh] kaç kez çağrıldı.
  int refreshCount = 0;

  @override
  List<EventModel> get events => _currentEvents;

  /// Arama sonucu; null ise aramanın olmadığı varsayılıyor.
  List<EventModel>? searchResults;

  @override
  List<EventModel> get searchedEvents => searchResults ?? _currentEvents;

  @override
  List<EventModel> get upcomingEvents => _currentEvents;

  @override
  ApiException? get error => _currentError;

  @override
  bool get isInitialized => _startInitialized;

  @override
  bool get isLoading => _startLoading;

  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<void> refresh() async {
    refreshCount++;
    // Gerçek istek gibi bir kare sonra bitiyor; yenileme göstergesinin
    // beklediği future anında tamamlanmasın.
    await Future<void>.delayed(Duration.zero);
    if (nextEvents != null) _currentEvents = nextEvents!;
    _currentError = nextError;
    notifyListeners();
  }
}

/// Testlerde kullanılan etkinlik. Kapak boş bırakılıyor: [CoverImage] boş
/// kaynakta ağa çıkmadan nötr simgeye düşüyor.
EventModel fakeEvent({String id = 'e1', String name = 'Etkinlik'}) {
  return EventModel(
    id: id,
    name: name,
    coverImageUrl: '',
    description: 'Açıklama',
    location: 'D-B12',
    startDate: '2030-01-01T10:00:00Z',
    endDate: '2030-01-01T12:00:00Z',
    formUrl: '',
    active: true,
    ownerTeam: 'Atölye',
  );
}
