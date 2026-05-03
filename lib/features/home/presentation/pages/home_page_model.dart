part of 'home_page.dart';

abstract class HomePageModel extends State<HomePage> {
  static const double _sectionSpacing = 32.0;
  static const double _titleSpacing = 12.0;

  final List<NewsItem> latestNews = [
    NewsItem(
      imageUrl:
          'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?auto=format&fit=crop&w=400&q=60',
      title: 'Son Haber 1',
      description: 'Bu bir örnek haber açıklamasıdır.',
    ),
    NewsItem(
      imageUrl:
          'https://images.unsplash.com/photo-1522205408450-add114ad53fe?auto=format&fit=crop&w=400&q=60',
      title: 'Son Haber 2',
      description:
          'Bu da başka bir örnek haber açıklamasıdır. aaafsaklfjasjlfşaslşfaslşfasjşlafsklnflksafksaljfşlifjsaişfşsajlfşjlasjflasilşfasşfasjşlaa',
    ),
  ];



  // final Set<int> _visibleIndices = {0, 1, 2, 3, 4, 5, 6, 7};

  // List<LinkItem> get _visibleShortcuts => [
  //   for (int i = 0; i < _allShortcuts.length; i++)
  //     if (_visibleIndices.contains(i)) _allShortcuts[i],
  // ];

  // void _openEditSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     useRootNavigator: true,
  //     backgroundColor: Colors.transparent,
  //     constraints: BoxConstraints(
  //       maxHeight: MediaQuery.of(context).size.height * 0.75,
  //     ),
  //     builder: (_) => EditShortcutsSheet(
  //       allShortcuts: _allShortcuts,
  //       visibleIndices: _visibleIndices,
  //       onChanged: (updated) => setState(() => _visibleIndices = updated),
  //     ),
  //   );
  // }
}

class NewsItem {
  final String imageUrl;
  final String title;
  final String description;

  NewsItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
