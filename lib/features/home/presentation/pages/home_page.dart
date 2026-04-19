import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/home/presentation/widgets/custom_carousel_slider.dart';
import 'package:sky_app/features/home/presentation/widgets/latest_news_section.dart';
import 'package:sky_app/features/home/presentation/widgets/shotrcuts_section.dart';
import 'package:sky_app/features/home/presentation/widgets/slider_index_display.dart';
import 'package:sky_app/features/home/presentation/pages/home_page_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> carouselImgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?auto=format&fit=crop&w=400&q=60',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?auto=format&fit=crop&w=400&q=60',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=60',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?auto=format&fit=crop&w=400&q=60',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?auto=format&fit=crop&w=400&q=60',
  ];

  final CarouselSliderController sliderController = CarouselSliderController();

  int current = 0;

  final List<ShortcutItem> shortcuts = [
    ShortcutItem(icon: Icons.home, title: 'Anasayfa'),
    ShortcutItem(icon: Icons.search, title: 'Arama'),
    ShortcutItem(icon: Icons.notifications, title: 'Bildirimler'),
    ShortcutItem(icon: Icons.settings, title: 'Ayarlar'),
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
                CustomCarouselSlider(
                  imgList: carouselImgList,
                  sliderController: sliderController,
                  onPageChanged: (int index) {
                    setState(() {
                      current = index;
                    });
                  },
                ),
                SizedBox(height: 16.0), // TODO constant yap
                SliderIndexDisplay(
                  imgList: carouselImgList,
                  current: current,
                  sliderController: sliderController,
                ),
                SizedBox(height: 32), // TODO constant yap
                ShortcutsTitle(),
                SizedBox(height: 12), // TODO constant yap
                ShortcutsSection(),
                SizedBox(height: 32), // TODO constant yap
                LatestNewsTitle(),
                SizedBox(height: 12), // TODO constant yap
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

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white, // TODO constant yap
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Kısayollar', style: style),
    );
  }
}

class LatestNewsTitle extends StatelessWidget {
  const LatestNewsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white, // TODO constant yap
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Son Haberler', style: style),
    );
  }
}
