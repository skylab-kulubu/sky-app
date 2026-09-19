part of 'schedule_day_form_page.dart';

abstract class ScheduleDayFormPagemodel extends State<ScheduleDayFormPage> {
  final ScheduleService _service = ScheduleService();
  final TextEditingController nameController = TextEditingController();

  late DateTime date = _dateOnly(widget.day?.startDate ?? widget.initialDate);

  bool isSaving = false;
  bool isDeleting = false;

  bool get isEditing => widget.day != null;
  bool get isBusy => isSaving || isDeleting;

  static const List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', //
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  String get dateLabel => '${date.day} ${_months[date.month - 1]} ${date.year}';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.day?.name ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<void> onPickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    setState(() => date = _dateOnly(picked));
  }

  /// Gün, seçilen tarihin başından sonuna kadar kaydediliyor.
  Future<void> onSave() async {
    setState(() => isSaving = true);
    final day = EventDay(
      id: widget.day?.id ?? '',
      eventId: widget.eventId,
      name: nameController.text.trim(),
      startDate: date,
      endDate: date.add(const Duration(hours: 23, minutes: 59)),
    );

    try {
      if (isEditing) {
        await _service.updateDay(day);
      } else {
        await _service.createDay(day);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      final error = ApiException.from(e);
      log('Gün kaydedilemedi: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      _showMessage(
        error.statusCode == 403
            ? 'Bu etkinliğin programını düzenleme yetkin yok.'
            : error.userMessage,
      );
    }
  }

  Future<void> onDeletePressed() async {
    final dayId = widget.day?.id;
    if (dayId == null) return;

    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Gün silinsin mi?',
      message:
          'Bu gündeki bütün oturumlar ve alınmış yoklamalar da silinir. Bu '
          'işlem geri alınamaz.',
    );
    if (!confirmed || !mounted) return;

    setState(() => isDeleting = true);
    try {
      await _service.deleteDay(dayId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      final error = ApiException.from(e);
      log('Gün silinemedi: $error');
      if (!mounted) return;
      setState(() => isDeleting = false);
      _showMessage(
        error.statusCode == 403
            ? 'Bu günü silme yetkin yok.'
            : error.userMessage,
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
