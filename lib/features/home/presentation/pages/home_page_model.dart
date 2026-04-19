import 'package:flutter/material.dart';

class ShortcutItem {
  final IconData icon;
  final String title;

  ShortcutItem({required this.icon, required this.title});
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
