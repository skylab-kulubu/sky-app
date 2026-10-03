/// Core'un bir görsel için ürettiği küçük boyutlar (`sizes`,
/// `coverImageSizes`, `profilePictureSizes`): `card` 400 px, `page`
/// 1200 px. Listede [card], detayda [page], tam ekranda asıl adres
/// kullanılıyor. Adresler yanıttan olduğu gibi alınıyor, kurulmuyor.
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

  /// Detay boyutu yoksa asıl adres.
  String pageOr(String original) => page.isNotEmpty ? page : original;
}
