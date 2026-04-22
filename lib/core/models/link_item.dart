import 'package:flutter/widgets.dart';

class LinkItem {
  final String name;
  final String description;
  final String iconPath;
  final Color color;
  final String url;

  const LinkItem({
    required this.name,
    required this.description,
    required this.iconPath,
    required this.color,
    required this.url,
  });
}
