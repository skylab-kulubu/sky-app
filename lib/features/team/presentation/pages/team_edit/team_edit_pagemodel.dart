part of 'team_edit_page.dart';

abstract class TeamEditPagemodel extends State<TeamEditPage> {
  final TeamService _teamService = TeamService();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController longDescriptionController =
      TextEditingController();

  /// Konu ve teknoloji alanlarında yazılı, henüz etikete dönmemiş metin.
  final TextEditingController topicInputController = TextEditingController();
  final TextEditingController stackInputController = TextEditingController();

  /// CMS'ten çekilen hâl; değişiklik kontrolü ve kayıt buna göre.
  Team? original;
  ApiException? loadError;

  List<String> topics = const [];
  List<String> stack = const [];
  List<TeamWork> works = const [];
  bool isRecruiting = false;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    longDescriptionController.dispose();
    topicInputController.dispose();
    stackInputController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loadError = null;
      original = null;
    });

    try {
      final team = await _teamService.fetchTeam(widget.slug);
      if (!mounted) return;
      setState(() {
        original = team;
        descriptionController.text = team.description;
        // Düz metne çevrilmiş hâli; editör HTML ürettiyse etiketler
        // formda görünmesin. Kaydedince düz metin olarak gidiyor.
        longDescriptionController.text = team.longDescriptionText;
        topics = team.topics;
        stack = team.stack;
        works = team.works;
        isRecruiting = team.isRecruiting;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadError = ApiException.from(e));
    }
  }

  void onRetry() => _load();

  Team? get _edited => original?.copyWith(
    description: descriptionController.text.trim(),
    longDescription: longDescriptionController.text.trim(),
    // Alanda yazılı kalan metin de etiket sayılıyor; kullanıcı onaya
    // basmadan "Kaydet"e basarsa kaybolmasın.
    topics: SkyTagEditor.withPending(topics, topicInputController.text),
    stack: SkyTagEditor.withPending(stack, stackInputController.text),
    works: works,
    isRecruiting: isRecruiting,
  );

  /// Kaydedilmemiş değişiklik var mı. Karşılaştırma CMS'e gidecek veri
  /// üzerinden; alan alan tutmak yerine tek kaynak.
  bool get hasChanges {
    final original = this.original;
    final edited = _edited;
    if (original == null || edited == null) return false;

    final before = original.copyWith(
      longDescription: original.longDescriptionText,
    );
    return before.toCmsData().toString() != edited.toCmsData().toString();
  }

  /// Kısa açıklama CMS'te zorunlu.
  bool get canSave =>
      hasChanges && descriptionController.text.trim().isNotEmpty && !isSaving;

  /// Metin alanları değiştikçe "Kaydet"in durumu yeniden hesaplansın.
  void onFormChanged() => setState(() {});

  void onRecruitingChanged(bool value) => setState(() => isRecruiting = value);

  void onTopicsChanged(List<String> value) => setState(() => topics = value);

  void onStackChanged(List<String> value) => setState(() => stack = value);

  Future<void> onAddWork() async {
    final work = await TeamWorkSheet.show(context);
    if (work == null || !mounted) return;
    setState(() => works = [...works, work]);
  }

  /// Çalışmaya dokununca: düzenle ya da sil.
  Future<void> onWorkTap(int index) async {
    final action = await _askWorkAction(works[index]);
    if (!mounted || action == null) return;

    if (action == _WorkAction.delete) {
      setState(() => works = [...works]..removeAt(index));
      return;
    }

    final updated = await TeamWorkSheet.show(context, work: works[index]);
    if (updated == null || !mounted) return;
    setState(() => works = [...works]..[index] = updated);
  }

  Future<_WorkAction?> _askWorkAction(TeamWork work) {
    return showModalBottomSheet<_WorkAction>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          // Column(min): sheet'in yüksekliği sınırlı olduğunda TileGroup onu
          // tamamen doldurup iki satırın altında boş bir kart bırakıyordu.
          // Görünüm sheet'indekiyle aynı düzen: başlık ve satırlar.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                work.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sheetContext.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.bigSpace),
              TileGroup(
                children: [
                  SettingsTile(
                    icon: AppIcons.edit,
                    iconColor: AppColors.blue,
                    title: 'Düzenle',
                    trailingIcon: null,
                    onTap: () => Navigator.pop(sheetContext, _WorkAction.edit),
                  ),
                  SettingsTile(
                    icon: AppIcons.close,
                    iconColor: AppColors.red,
                    title: 'Sil',
                    titleColor: AppColors.red,
                    trailingIcon: null,
                    onTap: () =>
                        Navigator.pop(sheetContext, _WorkAction.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSavePressed() async {
    final edited = _edited;
    if (edited == null) return;

    setState(() => isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final saved = await _teamService.updateTeam(edited);
      if (!mounted) return;

      context.read<TeamProvider>().replaceTeam(saved);
      messenger.showSnackBar(
        const SnackBar(content: Text('Ekip bilgileri kaydedildi.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      // Yetki hatalarında 401 (token CMS'e uygun değil) ile 403 (rol ya da
      // liderlik yok) ayrımı buradan okunuyor; kullanıcıya ikisi aynı mesaj.
      log('Ekip kaydedilemedi (${edited.slug}): ${ApiException.from(e)}');
      if (!mounted) return;
      setState(() => isSaving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(_saveErrorMessage(ApiException.from(e)))),
      );
    }
  }

  String _saveErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      409 =>
        'Ekip bilgileri sen düzenlerken değiştirilmiş. Sayfayı kapatıp tekrar aç.',
      // Token'ın `skyapp` client'ında `cms:access` yoksa ya da kullanıcı
      // ekibin `LIDERLER` grubunda değilse CMS 401/403 dönüyor.
      401 || 403 => 'Bu ekibi düzenleme yetkin yok.',
      400 => 'Bilgiler kaydedilemedi; alanları kontrol et.',
      _ => error.userMessage,
    };
  }

  /// Kaydedilmemiş değişiklikle geri dönülürken onay.
  Future<void> onDiscardRequested() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.tileColor,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        title: Text(
          'Değişiklikler kaydedilmedi',
          style: dialogContext.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Çıkarsan yaptığın değişiklikler kaybolacak.',
          style: dialogContext.textTheme.bodyMedium?.copyWith(
            color: dialogContext.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Vazgeç',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: dialogContext.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Çık',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // `pop` PopScope'a takılmıyor (yalnızca `maybePop` ve sistem geri
    // hareketi takılıyor); onaydan sonra doğrudan çıkılıyor.
    if (discard == true && mounted) Navigator.of(context).pop();
  }
}

enum _WorkAction { edit, delete }
