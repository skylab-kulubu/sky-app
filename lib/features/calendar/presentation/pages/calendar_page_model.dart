part of 'calendar_page.dart';

abstract class CalendarPageModel extends State<CalendarPage> {
  final String apiEndpointTodo = 'TODO: API_ENDPOINT';

  List<EventModel> events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    String endpoint = apiEndpointTodo;
    if (!mounted) return;
    setState(() {
      events = EventService.events;
    });
  }
}
