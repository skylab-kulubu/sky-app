import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/home/presentation/widgets/custom_carousel_slider.dart';
import 'package:sky_app/features/home/presentation/widgets/latest_news_section.dart';
import 'package:sky_app/features/home/presentation/widgets/shortcuts_section.dart';
import 'package:sky_app/features/home/presentation/widgets/edit_shortcuts.dart';
import 'package:sky_app/features/home/presentation/pages/home_page_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  static const _allShortcuts = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomCarouselSlider(items: carouselItems),
                const SizedBox(height: _sectionSpacing),
                ShortcutsTitle(),
                const SizedBox(height: _titleSpacing),
                ShortcutsSection(
                  shortcuts: _visibleShortcuts,
                  onEditTap: _openEditSheet,
                ),
                const SizedBox(height: _sectionSpacing),
                LatestNewsTitle(),
                const SizedBox(height: _titleSpacing),
                LatestNewsSection(latestNews: latestNews),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortcutsTitle extends StatelessWidget {
  const ShortcutsTitle({super.key});

  static const Color _titleColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: _titleColor,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Kısayollar', style: style),
    );
  }
}

class LatestNewsTitle extends StatelessWidget {
  const LatestNewsTitle({super.key});

  static const Color _titleColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: _titleColor,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Son Haberler', style: style),
    );
  }
}
