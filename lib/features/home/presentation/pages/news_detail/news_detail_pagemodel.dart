part of 'news_detail_page.dart';

abstract class NewsDetailPagemodel extends State<NewsDetailPage> {
  final ScrollController scrollController = ScrollController();

  NewsItem get item => widget.item;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Haberi sistem paylaşım sayfasıyla paylaşır: başlık ve tam metin.
  Future<void> onSharePressed() async {
    await SharePlus.instance.share(
      ShareParams(text: '${item.title}\n\n${item.description}'),
    );
  }
}
