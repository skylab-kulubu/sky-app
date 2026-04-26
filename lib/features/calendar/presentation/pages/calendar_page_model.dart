part of 'calendar_page.dart';

abstract class CalendarPageModel extends State<CalendarPage> {
  List<EventModel> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final fetchedEvents = await EventService.fetchEvents();
    if (!mounted) return;
    setState(() {
      events = fetchedEvents;
    });
  }
}
