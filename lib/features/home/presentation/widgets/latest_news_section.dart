import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key, required this.latestNews});

  final List<NewsItem> latestNews;

  static const double _separatorHeight = 8.0;
  static const double _cardBorderRadius = 24.0;
  static const Color _cardColor = Color.fromARGB(255, 27, 26, 26);
  static const double _thumbnailSpacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: latestNews.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: _separatorHeight),
      itemBuilder: (context, index) {
        final news = latestNews[index];
        return Container(
          padding: AppPaddings.mainPaddingAll,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(_cardBorderRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NewsThumbnail(news: news),
              const SizedBox(width: _thumbnailSpacing),
              NewsTitleAndDescription(news: news),
            ],
          ),
        );
      },
    );
  }
}

class NewsTitleAndDescription extends StatelessWidget {
  const NewsTitleAndDescription({super.key, required this.news});

  final NewsItem news;

  static const double _titleDescriptionSpacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final title = news.title;
    final description = news.description;

    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final descriptionStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: context.textSecondary);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: _titleDescriptionSpacing),
          Text(
            description,
            style: descriptionStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class NewsThumbnail extends StatelessWidget {
  const NewsThumbnail({super.key, required this.news});

  final NewsItem news;

  static const double _size = 80.0;
  static const double _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        color: context.elevatedColor,
      ),
      child: Image.network(news.imageUrl, fit: BoxFit.cover),
    );
  }
}
