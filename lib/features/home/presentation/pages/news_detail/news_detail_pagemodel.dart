part of 'news_detail_page.dart';

abstract class NewsDetailPagemodel extends State<NewsDetailPage> {
  final ScrollController scrollController = ScrollController();

  /// Provider'daki güncel hâl; düzenleme kaydedilince sayfa kendiliğinden
  /// yenileniyor. Yalnızca `build` içinde okunmalı (`watch`).
  NewsItem get item =>
      context.watch<NewsProvider>().itemBySlug(widget.item.slug) ?? widget.item;

  /// Olay işleyicilerinde okunacak güncel hâl (`watch` build dışında
  /// kullanılamıyor).
  NewsItem get _latest =>
      context.read<NewsProvider>().itemBySlug(widget.item.slug) ?? widget.item;

  /// Düzenleme yalnızca `cms:access` rolü olana.
  bool get canEdit =>
      context.watch<UserProvider>().user?.canManageNews ?? false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onEditPressed() => NewsEditPage.open(context, item: _latest);

  /// Haberi paylaşır: başlık ve uygulamada haberi açan bağlantı.
  Future<void> onSharePressed() async {
    final item = _latest;
    await SharePlus.instance.share(
      ShareParams(text: '${item.title}\n${LinksService.newsLink(item.slug)}'),
    );
  }
}
