import 'package:flutter/widgets.dart';

class LinkItem {
  final String name;
  final String description;

  /// [AppIcons] içindeki ikon adı.
  final String icon;
  final Color color;
  final String url;

  const LinkItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.url,
  });
}

/// Kulüp menüsünde bir başlık altında toplanan bağlantılar.
class LinkGroup {
  final String title;
  final List<LinkItem> links;

  const LinkGroup({required this.title, required this.links});
}
