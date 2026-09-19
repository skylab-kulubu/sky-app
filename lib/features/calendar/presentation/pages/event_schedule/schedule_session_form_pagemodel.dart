part of 'schedule_session_form_page.dart';

abstract class ScheduleSessionFormPagemodel
    extends State<ScheduleSessionFormPage> {
  final ScheduleService _service = ScheduleService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController speakerController = TextEditingController();

  static const Duration _defaultDuration = Duration(hours: 1);
  static const String _defaultType = 'PRESENTATION';

  late DateTime start = widget.session?.startTime ?? widget.initialStart;
  late DateTime end = widget.session?.endTime ?? start.add(_defaultDuration);
  late String sessionType = widget.session?.sessionType.isNotEmpty ?? false
      ? widget.session!.sessionType
      : _defaultType;
  late bool cancelled = widget.session?.cancelled ?? false;

  bool isSaving = false;
  bool isDeleting = false;

  bool get isEditing => widget.session != null;
  bool get isBusy => isSaving || isDeleting;

  /// Core başlığı ve konuşmacıyı zorunlu tutuyor.
  bool get canSubmit =>
      !isBusy &&
      titleController.text.trim().isNotEmpty &&
      speakerController.text.trim().isNotEmpty &&
      end.isAfter(start);

  String get typeLabel => EventSession.types[sessionType] ?? sessionType;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.session?.title ?? '';
    speakerController.text = widget.session?.speakerName ?? '';
  }

  @override
  void dispose() {
    titleController.dispose();
    speakerController.dispose();
    super.dispose();
  }

  String clockLabel(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  void onFormChanged() => setState(() {});

  void onCancelledChanged(bool value) => setState(() => cancelled = value);

  /// Saat günün tarihine yazılıyor. Başlangıç değişince bitiş aynı süreyle
  /// kayıyor; bitiş başlangıcın önüne alınırsa satır kırmızı, kayıt pasif.
  Future<void> onPickTime({required bool isStart}) async {
    final current = isStart ? start : end;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final base = widget.day.startDate ?? current;
    final value = DateTime(
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        final duration = end.difference(start);
        start = value;
        end = value.add(duration.isNegative ? _defaultDuration : duration);
      } else {
        end = value;
      }
    });
  }

  Future<void> onChooseType() async {
    final keys = EventSession.types.keys.toList();
    final index = await EventOptionSheet.show(
      context,
      title: 'Oturum türü',
      options: EventSession.types.values.toList(),
      selectedIndex: keys.indexOf(sessionType),
      icon: AppIcons.category,
      iconColor: AppColors.purple,
    );
    if (index == null || !mounted) return;
    setState(() => sessionType = keys[index]);
  }

  Future<void> onSave() async {
    setState(() => isSaving = true);
    final original = widget.session;
    final session = EventSession(
      id: original?.id ?? '',
      dayId: widget.day.id,
      title: titleController.text.trim(),
      speakerName: speakerController.text.trim(),
      sessionType: sessionType,
      cancelled: cancelled,
      speakerLinkedin: original?.speakerLinkedin ?? '',
      description: original?.description ?? '',
      orderIndex: original?.orderIndex ?? 0,
      startTime: start,
      endTime: end,
    );

    try {
      if (isEditing) {
        await _service.updateSession(session);
      } else {
        await _service.createSession(session);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      final error = ApiException.from(e);
      log('Oturum kaydedilemedi: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      _showMessage(switch (error.statusCode) {
        403 => 'Bu etkinliğin programını düzenleme yetkin yok.',
        400 => 'Oturum kaydedilemedi; alanları kontrol et.',
        _ => error.userMessage,
      });
    }
  }

  Future<void> onDeletePressed() async {
    final sessionId = widget.session?.id;
    if (sessionId == null) return;

    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Oturum silinsin mi?',
      message:
          'Bu oturumda alınmış yoklamalar da silinir. Oturum yapılmadıysa '
          'silmek yerine "İptal edildi" olarak işaretleyebilirsin.',
    );
    if (!confirmed || !mounted) return;

    setState(() => isDeleting = true);
    try {
      await _service.deleteSession(sessionId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      final error = ApiException.from(e);
      log('Oturum silinemedi: $error');
      if (!mounted) return;
      setState(() => isDeleting = false);
      _showMessage(
        error.statusCode == 403
            ? 'Bu oturumu silme yetkin yok.'
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
