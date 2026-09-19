part of 'event_schedule_page.dart';

abstract class EventSchedulePagemodel extends State<EventSchedulePage> {
  final ScheduleService _service = ScheduleService();

  List<ScheduleDay> schedule = const [];
  ApiException? error;
  bool isLoading = true;

  /// Bir şey kaydedildi ya da silindi mi; sayfa kapanırken dönülüyor ki
  /// detay sayfası programı yenilesin.
  bool changed = false;

  late final bool canDelete =
      context.read<UserProvider>().user?.canDeleteEvent(
        widget.event.ownerTeam,
      ) ??
      false;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    try {
      final result = await _service.fetchSchedule(widget.event.id);
      if (!mounted) return;
      setState(() {
        schedule = result;
        error = null;
        isLoading = false;
      });
    } catch (e) {
      final apiError = ApiException.from(e);
      log('Program alınamadı: $apiError');
      if (!mounted) return;
      setState(() {
        error = apiError;
        isLoading = false;
      });
    }
  }

  Future<void> _afterForm(bool didChange) async {
    if (!didChange || !mounted) return;
    changed = true;
    await reload();
  }

  /// Yeni günün önerilen tarihi: son günün ertesi, gün yoksa etkinliğin
  /// başladığı gün.
  DateTime get _nextDayDate {
    final last = schedule.lastOrNull?.day.startDate;
    if (last != null) return last.add(const Duration(days: 1));
    return widget.event.startDateTime ?? DateTime.now();
  }

  Future<void> onAddDay() async {
    final didChange = await ScheduleDayFormPage.open(
      context,
      eventId: widget.event.id,
      initialDate: _nextDayDate,
      canDelete: canDelete,
    );
    await _afterForm(didChange);
  }

  Future<void> onEditDay(EventDay day) async {
    final didChange = await ScheduleDayFormPage.open(
      context,
      eventId: widget.event.id,
      initialDate: day.startDate ?? _nextDayDate,
      canDelete: canDelete,
      day: day,
    );
    await _afterForm(didChange);
  }

  /// Yeni oturumun önerilen başlangıcı: günün son oturumunun bitişi; ilk
  /// oturumsa etkinliğin başlangıç saati o güne uygulanıyor.
  DateTime _nextSessionStart(ScheduleDay entry) {
    final lastEnd = entry.sessions.lastOrNull?.endTime;
    if (lastEnd != null) return lastEnd;

    final date = entry.day.startDate ?? DateTime.now();
    final eventStart = widget.event.startDateTime;
    return DateTime(
      date.year,
      date.month,
      date.day,
      eventStart?.hour ?? 10,
      eventStart?.minute ?? 0,
    );
  }

  Future<void> onAddSession(ScheduleDay entry) async {
    final didChange = await ScheduleSessionFormPage.open(
      context,
      day: entry.day,
      initialStart: _nextSessionStart(entry),
      canDelete: canDelete,
    );
    await _afterForm(didChange);
  }

  Future<void> onEditSession(ScheduleDay entry, EventSession session) async {
    final didChange = await ScheduleSessionFormPage.open(
      context,
      day: entry.day,
      initialStart: session.startTime ?? _nextSessionStart(entry),
      canDelete: canDelete,
      session: session,
    );
    await _afterForm(didChange);
  }
}
