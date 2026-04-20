import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/home/presentation/widgets/custom_carousel_slider.dart';
import 'package:sky_app/features/home/presentation/widgets/latest_news_section.dart';
import 'package:sky_app/features/home/presentation/widgets/shortcuts_section.dart';
import 'package:sky_app/features/home/presentation/widgets/edit_shortcuts.dart';

part 'home_page_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends HomePageModel {
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
                const SizedBox(height: HomePageModel._sectionSpacing),
                ShortcutsTitle(),
                const SizedBox(height: HomePageModel._titleSpacing),
                ShortcutsSection(
                  shortcuts: _visibleShortcuts,
                  onEditTap: _openEditSheet,
                ),
                const SizedBox(height: HomePageModel._sectionSpacing),
                LatestNewsTitle(),
                const SizedBox(height: HomePageModel._titleSpacing),
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
