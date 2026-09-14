part of 'news_edit_page.dart';

abstract class NewsEditPagemodel extends State<NewsEditPage> {
  final NewsService _service = NewsService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController tagInputController = TextEditingController();

  List<String> tags = const [];
  bool featured = false;
  bool isSaving = false;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item == null) return;

    titleController.text = item.title;
    summaryController.text = item.summary;
    // Düz metne çevrilmiş hâli; kaydedince düz metin olarak gidiyor.
    bodyController.text = item.bodyText;
    imageController.text = item.heroImage;
    tags = item.tags;
    featured = item.featured;
  }

  @override
  void dispose() {
    titleController.dispose();
    summaryController.dispose();
    bodyController.dispose();
    imageController.dispose();
    tagInputController.dispose();
    super.dispose();
  }

  /// Başlık ve metin CMS'te zorunlu.
  bool get canSubmit =>
      !isSaving &&
      titleController.text.trim().isNotEmpty &&
      bodyController.text.trim().isNotEmpty;

  void onFormChanged() => setState(() {});

  void onTagsChanged(List<String> value) => setState(() => tags = value);

  void onFeaturedChanged(bool value) => setState(() => featured = value);

  Future<void> onSubmit() async {
    setState(() => isSaving = true);

    final original = widget.item;
    final messenger = ScaffoldMessenger.of(context);

    // Yazar oluştururken kullanıcının adı; düzenlemede ilk yazar korunuyor.
    final author =
        original?.author ?? context.read<UserProvider>().user?.name ?? '';

    final draft = NewsItem(
      slug: original?.slug ?? '',
      version: original?.version ?? 0,
      title: titleController.text.trim(),
      summary: summaryController.text.trim(),
      body: bodyController.text.trim(),
      heroImage: imageController.text.trim(),
      tags: SkyTagEditor.withPending(tags, tagInputController.text),
      author: author,
      featured: featured,
    );

    try {
      final saved = original == null
          ? await _service.createNews(draft)
          : await _service.updateNews(draft);
      if (!mounted) return;

      context.read<NewsProvider>().upsert(saved);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            original == null ? 'Haber yayınlandı.' : 'Haber kaydedildi.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      final error = ApiException.from(e);
      log('Haber kaydedilemedi: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (error.statusCode) {
            401 || 403 => 'Haber yazma yetkin yok.',
            409 =>
              'Haber sen düzenlerken değiştirilmiş. Sayfayı kapatıp tekrar aç.',
            400 => 'Haber kaydedilemedi; alanları kontrol et.',
            _ => error.userMessage,
          }),
        ),
      );
    }
  }
}
