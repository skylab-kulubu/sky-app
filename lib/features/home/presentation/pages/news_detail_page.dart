import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_bar_actions.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';
import 'package:sky_app/features/home/presentation/widgets/cover_image.dart';

/// Haberin tam metnini gösteren sayfa.
///
/// Listedeki tile'dan container transform ile açılır; kök navigator'a
/// push edildiği için navbar'ın altında kalmaz, ekranı tamamen kaplar.
class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key, required this.item});

  final NewsItem item;

  /// Görselin appbar'ın altından görünen kısmının yüksekliği; durum çubuğu
  /// payı ayrıca ekleniyor.
  static const double _coverHeight = 240.0;
  static const double _descriptionLineHeight = 1.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Görsel appbar'ın ve durum çubuğunun altına kadar uzansın diye.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth:
            AppBarActions.widthFor(1) + AppPaddings.appBarLeading.left,
        leading: Padding(
          padding: AppPaddings.appBarLeading,
          // leading slotu sıkı yükseklik kısıtı veriyor ve bu, hap'ın kendi
          // yüksekliğini ezip dikeyde uzatıyor; Center kısıtı emiyor.
          child: Center(
            child: AppBarActions(
              // Aynı widget kullanılıyor: geri butonu actions hap'larıyla
              // birebir aynı zemin, kenarlık ve ölçüde duruyor.
              icons: const [AppIcons.arrowBack],
              onIconTap: (_) => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: _coverHeight + MediaQuery.paddingOf(context).top,
            width: double.infinity,
            child: CoverImage(imageUrl: item.imageUrl),
          ),
          Padding(
            padding: AppPaddings.mainPaddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.bigSpace),
                Text(
                  item.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.textSecondary,
                    height: _descriptionLineHeight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
