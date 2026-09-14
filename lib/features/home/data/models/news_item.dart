/// SkyCMS'teki bir haber (`News` koleksiyonu).
///
/// Slug CMS'te başlıktan otomatik üretiliyor ve değişmiyor; haber
/// bağlantıları (deep link, #44) bununla kurulacak.
class NewsItem {
  const NewsItem({
    required this.slug,
    required this.title,
    required this.summary,
    required this.body,
    required this.heroImage,
    required this.tags,
    required this.author,
    required this.featured,
    this.version = 0,
  });

  final String slug;
  final String title;
  final String summary;

  /// Zengin metin alanı; CMS düz metin olarak saklıyor. Gösterirken
  /// [bodyText] kullanılmalı.
  final String body;

  /// Kapak görselinin adresi; boş olabilir.
  final String heroImage;
  final List<String> tags;
  final String author;
  final bool featured;

  /// Kaydederken gönderiliyor; arada biri değiştirdiyse CMS 409 dönüyor.
  final int version;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return NewsItem(
      slug: json['slug'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      title: (data['title'] as String? ?? '').trim(),
      summary: (data['summary'] as String? ?? '').trim(),
      body: data['body'] as String? ?? '',
      heroImage: (data['heroImage'] as String? ?? '').trim(),
      tags: (data['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(growable: false),
      author: (data['author'] as String? ?? '').trim(),
      featured: data['featured'] == true,
    );
  }

  /// CMS'e gönderilecek `data`. Yalnızca şemadaki alanlar; CMS bilinmeyen
  /// alanı reddediyor.
  Map<String, dynamic> toCmsData() => {
    'title': title,
    'summary': summary,
    'body': body,
    'heroImage': heroImage,
    'tags': tags,
    'author': author,
    'featured': featured,
  };

  /// Metnin etiketlerden ayıklanmış hâli. Editörün HTML üretme ihtimaline
  /// karşı paragraf sonları korunup etiketler siliniyor.
  String get bodyText {
    if (body.trim().isEmpty) return '';
    return body
        .replaceAll(RegExp(r'<br\s*/?>|</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Listede başlığın altındaki kısa metin: özet varsa o, yoksa metnin başı.
  String get preview => summary.isNotEmpty ? summary : bodyText;
}
