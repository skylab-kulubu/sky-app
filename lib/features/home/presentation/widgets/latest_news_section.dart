import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/home/presentation/pages/home_page_model.dart';

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key, required this.latestNews});

  final List<NewsItem> latestNews;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: latestNews.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: 8.0), // TODO constant yap
      itemBuilder: (context, index) {
        final news = latestNews[index];
        return Container(
          padding: AppPaddings.mainPaddingAll,
          decoration: BoxDecoration(
            color: Colors.grey[850], // TODO constant yap
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NewsThumbnail(news: news),
              SizedBox(width: 12.0), // TODO constant yap
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

  @override
  Widget build(BuildContext context) {
    final title = news.title;
    final description = news.description;

    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final descriptionStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.grey[400], // TODO constant yap
    );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          SizedBox(height: 4.0), // TODO constant yap
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0), // TODO constant yap
        color: Colors.grey[850], // TODO constant yap
      ),
      child: Image.network(
        news.imageUrl, // TODO REAL ICON
        fit: BoxFit.cover,
      ),
    );
  }
}
