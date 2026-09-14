import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_bar_actions.dart';
import 'package:sky_app/core/widgets/cover_image.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';
import 'package:sky_app/features/home/presentation/pages/news_edit/news_edit_page.dart';
import 'package:sky_app/features/home/presentation/providers/news_provider.dart';

part 'news_detail_pagemodel.dart';

/// Haberin tam metnini gösteren sayfa.
///
/// Yerleşim etkinlik detayıyla aynı: üstte geri ve paylaş hap'ları, altında
/// kaydırıldıkça büzülen kare kapak. Farkı zemin; burada kapak renkleri
/// kullanılmıyor, sayfa temanın düz koyu ya da açık zemininde duruyor.
///
/// Listedeki tile'dan container transform ile açılır; kök navigator'a
/// push edildiği için navbar'ın altında kalmaz, ekranı tamamen kaplar.
class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key, required this.item});

  final NewsItem item;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends NewsDetailPagemodel {
  static const double _descriptionLineHeight = 1.6;

  /// Başlık iki satıra taştığında satırlar birbirine yapışmasın diye.
  static const double _titleLineHeight = 1.25;

  /// Çubuktaki başlığın belirmeye başladığı kaydırma mesafesi (kapağın
  /// altından itibaren) ve tamamen görünür olana kadar geçen mesafe.
  static const double _headingRevealOffset = 36.0;
  static const double _headingRevealDistance = 40.0;

  double get _scrollOffset =>
      scrollController.hasClients ? scrollController.offset : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          _topHeader(context),
          Expanded(
            child: Stack(children: [_pinnedCover(context), _content(context)]),
          ),
        ],
      ),
    );
  }

  /// Üstteki sabit başlık çubuğu: geri, sayfadaki başlık buraya ulaşınca
  /// beliren ortalanmış başlık ve paylaş.
  Widget _topHeader(BuildContext context) {
    const gap = SizedBox(width: AppSizes.midSpace);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            Padding(
              padding: AppPaddings.appBarLeading,
              child: Center(
                child: AppBarActions(
                  icons: const [AppIcons.arrowBack],
                  onIconTap: (_) => Navigator.of(context).pop(),
                ),
              ),
            ),
            gap,
            Expanded(
              child: AnimatedBuilder(
                animation: scrollController,
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                builder: (context, child) {
                  // Sayfadaki başlık çubuğun altına girdikten sonra beliriyor.
                  final threshold = _coverSize(context) + _headingRevealOffset;
                  final opacity =
                      ((_scrollOffset - threshold) / _headingRevealDistance)
                          .clamp(0.0, 1.0);

                  return Opacity(opacity: opacity, child: child);
                },
              ),
            ),
            gap,
            // Geri butonuyla aynı hap; başlığın iki yanı simetrik kalıyor.
            Padding(
              padding: AppPaddings.appBarActions,
              child: Center(
                child: AppBarActions(
                  // Yetkisi olana paylaşın solunda düzenleme.
                  icons: [if (canEdit) AppIcons.edit, AppIcons.share],
                  onIconTap: (icon) => icon == AppIcons.edit
                      ? onEditPressed()
                      : onSharePressed(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kapak yalnızca haberin görseli varsa; yoksa yeri de ayrılmıyor, başlık
  /// en üstten başlıyor.
  double _coverSize(BuildContext context) => item.heroImage.isEmpty
      ? 0
      : MediaQuery.sizeOf(context).width -
            (AppPaddings.mainPaddingHorizontal.left * 2);

  /// Kapak görseli kaydırıldıkça üst iki köşesi ve yeri sabit kalır, yüksekliği
  /// büzülerek küçülür.
  Widget _pinnedCover(BuildContext context) {
    final coverSize = _coverSize(context);
    if (coverSize == 0) return const SizedBox.shrink();

    return Positioned(
      top: AppSizes.bigSpace,
      left: AppPaddings.mainPaddingHorizontal.left,
      right: AppPaddings.mainPaddingHorizontal.right,
      child: AnimatedBuilder(
        animation: scrollController,
        // Görselin kendisi kaydırmadan etkilenmiyor; `child` olarak
        // verilmezse her karede baştan kuruluyor.
        child: ClipRRect(
          borderRadius: AppRadiuses.cardBorderRadius,
          child: CoverImage(imageUrl: item.heroImage),
        ),
        builder: (context, child) {
          final currentHeight = (coverSize - _scrollOffset).clamp(
            0.0,
            coverSize,
          );

          if (currentHeight <= 0) return const SizedBox.shrink();

          return SizedBox(
            height: currentHeight,
            width: coverSize,
            child: child,
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: AppPaddings.mainPaddingHorizontal.copyWith(
        top: item.heroImage.isEmpty
            ? AppSizes.bigSpace
            // Kapağın altındaki boşluk üstündekiyle aynı (ekip detayı gibi).
            : AppSizes.bigSpace + _coverSize(context) + AppSizes.bigSpace,
        // Altta buton yok; yalnızca sistem çubuğunun payı kadar boşluk.
        bottom: AppSizes.sectionSpace + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _title(context),
        const SizedBox(height: AppSizes.bigSpace),
        _description(context),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      item.title,
      style: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        height: _titleLineHeight,
      ),
    );
  }

  Widget _description(BuildContext context) {
    return Text(
      item.bodyText,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.textSecondary,
        height: _descriptionLineHeight,
      ),
    );
  }
}
