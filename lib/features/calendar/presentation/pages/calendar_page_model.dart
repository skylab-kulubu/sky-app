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

  void showJoinConfirmationDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Emin misin?',
            style: TextStyle(
              color: AppColors.textWhite,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '${event.title} etkinliğine katılmak istediğinden emin misin?',
            style: const TextStyle(
              color: AppColors.textGray,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(
                  color: AppColors.textGrayDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Katılma işlemi API'ye gönderilecek
                Navigator.pop(context); // Dialog'u kapat
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Katılma isteği alındı!',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textWhite,
              ),
              child: const Text('Evet, Katıl', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }
}
