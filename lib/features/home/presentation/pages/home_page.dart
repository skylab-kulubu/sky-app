import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/home/data/services/announcement_service.dart';
import 'package:sky_app/features/home/presentation/widgets/custom_carousel_slider.dart';
import 'package:sky_app/features/home/presentation/widgets/latest_news_section.dart';

part 'home_page_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends HomePageModel {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hoş Geldin, ${user.givenName}!",
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: HomePageModel._sectionSpacing),
                CustomCarouselSlider(items: carouselItems),
                const SizedBox(height: HomePageModel._sectionSpacing),
                // _sectionHeader(context, 'Kısayollar'),
                // const SizedBox(height: HomePageModel._titleSpacing),
                // ShortcutsSection(
                //   shortcuts: _visibleShortcuts,
                //   onEditTap: _openEditSheet,
                // ),
                // const SizedBox(height: HomePageModel._sectionSpacing),
                _sectionHeader(context, 'Son Haberler'),
                const SizedBox(height: HomePageModel._titleSpacing),
                LatestNewsSection(latestNews: latestNews),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align _sectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: context.textTheme.titleMedium),
    );
  }
}
