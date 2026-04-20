part of 'home_page.dart';

class CarouselItem {
  final String imageUrl;
  final String title;
  final String subtitle;

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}

class ShortcutItem {
  final String label;
  final String name;
  final String description;
  final String iconPath;
  final Color backgroundColor;

  const ShortcutItem({
    required this.label,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.backgroundColor,
  });
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

abstract class HomePageModel extends State<HomePage> {
  static const double _sectionSpacing = 32.0;
  static const double _titleSpacing = 12.0;

  final List<CarouselItem> carouselItems = [
    CarouselItem(
      imageUrl:
          'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?auto=format&fit=crop&w=400&q=60',
      title: 'Hackathon 2026 Başvuruları Başladı!',
      subtitle: '24 saatlik yazılım maratonuna katıl, ödüller kazan!',
    ),
    CarouselItem(
      imageUrl:
          'https://images.unsplash.com/photo-1522205408450-add114ad53fe?auto=format&fit=crop&w=400&q=60',
      title: 'Flutter Workshop Serisi',
      subtitle: 'Her Cuma mobil uygulama geliştirme atölyeleri',
    ),
    CarouselItem(
      imageUrl:
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=60',
      title: 'AI Konferansı Yaklaşıyor',
      subtitle: 'Yapay zeka alanında son gelişmeler ve uygulamalar',
    ),
  ];

  final List<ShortcutItem> _allShortcuts = [
    ShortcutItem(
      label: 'SKY LAB',
      name: 'Yıldız Sky Lab',
      description: 'SKY LAB resmi web sitesi',
      iconPath: 'assets/images/skylab.svg',
      backgroundColor: Color(0xFF000000),
    ),
    ShortcutItem(
      label: 'YıldızPlace',
      name: 'YıldızPlace',
      description: 'YTÜ kampüs haritası ve mekan rehberi',
      iconPath: 'assets/icons/ytuplace.svg',
      backgroundColor: Color(0xFF3D1515),
    ),
    ShortcutItem(
      label: 'YTUGuessr',
      name: 'YTUGuessr',
      description: 'YTÜ kampüsünü keşfet, konumu tahmin et',
      iconPath: 'assets/icons/ytuguessr.svg',
      backgroundColor: Color(0xFF3D1515),
    ),
    ShortcutItem(
      label: 'SKYCLOUD',
      name: 'SKYCLOUD',
      description: 'Kulüp dosya paylaşım ve depolama sistemi',
      iconPath: 'assets/icons/sky_cloud.svg',
      backgroundColor: Color(0xFF0A2A3D),
    ),
    ShortcutItem(
      label: 'SKYFORMS',
      name: 'SKYFORMS',
      description: 'Kulüp anket ve form platformu',
      iconPath: 'assets/icons/skyforms.svg',
      backgroundColor: Color(0xFF2E1A4A),
    ),
    ShortcutItem(
      label: 'SKYSEC',
      name: 'SKYSEC Articles',
      description: 'Siber güvenlik makaleleri ve yazılar',
      iconPath: 'assets/icons/skysec.svg',
      backgroundColor: Color(0xFF2A1F0D),
    ),
    ShortcutItem(
      label: 'Oda Durumu',
      name: 'Sky Lab Oda Durumu',
      description: 'Kulüp odasının anlık açık/kapalı durumu',
      iconPath: 'assets/icons/skylab_room.svg',
      backgroundColor: Color(0xFF0D2E26),
    ),
    ShortcutItem(
      label: 'Sunucu Durumu',
      name: 'Sky Lab Sunucu Durumu',
      description: 'Sunucu ve servis erişilebilirlik durumu',
      iconPath: 'assets/icons/skylab_server.svg',
      backgroundColor: Color(0xFF3D2000),
    ),
  ];

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

  Set<int> _visibleIndices = {0, 1, 2, 3, 4, 5, 6, 7};

  List<ShortcutItem> get _visibleShortcuts => [
    for (int i = 0; i < _allShortcuts.length; i++)
      if (_visibleIndices.contains(i)) _allShortcuts[i],
  ];

  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditShortcutsSheet(
        allShortcuts: _allShortcuts,
        visibleIndices: _visibleIndices,
        onChanged: (updated) => setState(() => _visibleIndices = updated),
      ),
    );
  }
}
