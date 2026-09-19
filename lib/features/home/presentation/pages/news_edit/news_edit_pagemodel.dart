part of 'news_edit_page.dart';

abstract class NewsEditPagemodel extends State<NewsEditPage> {
  final NewsService _service = NewsService();
  final MediaService _media = MediaService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController tagInputController = TextEditingController();

  List<String> tags = const [];

  /// Galeriden yeni seçilen görsel; kayıtta yükleniyor.
  XFile? image;

  /// Haberin mevcut görseli; kaldırılınca boş.
  String currentImageUrl = '';

  bool get hasImage => image != null || currentImageUrl.isNotEmpty;
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
    currentImageUrl = item.heroImage;
    tags = item.tags;
    featured = item.featured;
  }

  @override
  void dispose() {
    titleController.dispose();
    summaryController.dispose();
    bodyController.dispose();
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

  Future<void> onPickImage() async {
    try {
      final picked = await MediaService.pickImage();
      if (picked == null || !mounted) return;
      setState(() => image = picked);
    } on PlatformException catch (e) {
      // Galeri izni reddedildiğinde buraya düşüyor.
      log('Görsel seçilemedi: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Galeriye erişilemedi. İzinleri kontrol et.'),
        ),
      );
    }
  }

  void onRemoveImage() => setState(() {
    image = null;
    currentImageUrl = '';
  });

  Future<void> onSubmit() async {
    setState(() => isSaving = true);

    final original = widget.item;
    final messenger = ScaffoldMessenger.of(context);

    // Yazar oluştururken kullanıcının adı; düzenlemede ilk yazar korunuyor.
    final author =
        original?.author ?? context.read<UserProvider>().user?.name ?? '';

    // CMS alanı bir URL: yeni görsel önce core'a yükleniyor, adresi yazılıyor.
    final String heroImage;
    final picked = image;
    if (picked == null) {
      heroImage = currentImageUrl;
    } else {
      try {
        heroImage = (await _media.uploadImage(picked)).url;
      } catch (e) {
        final error = ApiException.from(e);
        log('Haber görseli yüklenemedi: $error');
        if (!mounted) return;
        setState(() => isSaving = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              error.isConnectivityIssue
                  ? error.userMessage
                  : 'Görsel yüklenemedi. Başka bir görsel dene.',
            ),
          ),
        );
        return;
      }
      if (!mounted) return;
    }

    final draft = NewsItem(
      slug: original?.slug ?? '',
      version: original?.version ?? 0,
      title: titleController.text.trim(),
      summary: summaryController.text.trim(),
      body: bodyController.text.trim(),
      heroImage: heroImage,
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
