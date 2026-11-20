/// Core'un görsel için ürettiği küçük boyutlar: `card` 400 px (liste),
/// `page` 1200 px (detay). Adresler yanıttan olduğu gibi alınıyor.
class ImageSizes {
  const ImageSizes({this.card = '', this.page = ''});

  static const ImageSizes none = ImageSizes();

  final String card;
  final String page;

  /// `{card: {url, width, height}, page: {...}}`; alan yoksa ya da biçim
  /// farklıysa boş.
  factory ImageSizes.fromJson(Object? json) {
    if (json is! Map) return none;
    return ImageSizes(card: _url(json['card']), page: _url(json['page']));
  }

  static String _url(Object? size) {
    if (size is! Map) return '';
    final url = size['url'];
    return url is String && url.startsWith('http') ? url : '';
  }

  /// Küçük boyut yoksa asıl adrese düşülüyor (eski kayıtlar, SVG).
  String cardOr(String original) => card.isNotEmpty ? card : original;

  String pageOr(String original) => page.isNotEmpty ? page : original;
}
