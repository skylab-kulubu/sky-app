import 'package:flutter/material.dart';

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
