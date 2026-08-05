import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';
import 'package:sky_app/features/home/presentation/pages/news_detail_page.dart';
import 'package:sky_app/features/home/presentation/widgets/cover_image.dart';

/// Haber listesindeki tek satır: solda kare görsel, sağda başlık ve iki
/// satır açıklama. Kart zemini yok, sayfa zemini üzerinde düz durur.
///
/// Dokununca Material "container transform" ile detay sayfasına dönüşür.
class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.item});

  final NewsItem item;

  static const double _thumbnailSpacing = AppSizes.bigSpace;
  static const double _titleSpacing = AppSizes.smallSpace;
  static const double _descriptionLineHeight = 1.35;
  static const Duration _transitionDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      // Ana sayfa shell'in içinde; kök navigator olmadan detay sayfası
      // navbar'ın altında açılırdı.
      useRootNavigator: true,
      transitionDuration: _transitionDuration,
      transitionType: ContainerTransitionType.fadeThrough,
      // Varsayılanlar beyaz zemin ve yükseltidir; tile sayfa zemini üzerinde
      // düz durduğu için ikisi de sıfırlanıyor.
      closedColor: context.backgroundColor,
      openColor: context.backgroundColor,
      middleColor: context.backgroundColor,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.tile),
      ),
      openBuilder: (_, _) => NewsDetailPage(item: item),
      closedBuilder: (context, _) => _tile(context),
    );
  }

  Widget _tile(BuildContext context) {
    return Padding(
      padding: AppPaddings.newsTile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _thumbnail(),
          const SizedBox(width: _thumbnailSpacing),
          Expanded(child: _texts(context)),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.thumbnail),
      child: SizedBox(
        width: AppSizes.thumbnail,
        height: AppSizes.thumbnail,
        child: CoverImage(imageUrl: item.imageUrl),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          // Tek satır: iki satıra taşan bir başlık o tile'ı diğerlerinden
          // uzun yapıp listenin ritmini bozuyordu.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: _titleSpacing),
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
            height: _descriptionLineHeight,
          ),
        ),
      ],
    );
  }
}
