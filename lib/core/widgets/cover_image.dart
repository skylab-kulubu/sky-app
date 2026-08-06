import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Liste ve detay görselleri için ortak yükleyici.
///
/// Kaynak hem uygulama içi asset hem uzak URL olabildiği için yolun biçimine
/// göre doğru yükleyici seçilir; boş ya da hatalı kaynakta nötr bir simge.
class CoverImage extends StatelessWidget {
  const CoverImage({super.key, required this.imageUrl});

  final String imageUrl;

  static const String _assetPrefix = 'assets/';

  bool get _isAsset => imageUrl.startsWith(_assetPrefix);

  bool get _isEmpty => imageUrl.trim().isEmpty;

  /// Görseli çizmek yerine okuması gereken yerler için (renk paleti çıkarımı
  /// gibi) aynı asset/uzak ayrımını kullanan sağlayıcı. Kaynak boşsa `null`.
  static ImageProvider? providerFor(String imageUrl) {
    if (imageUrl.trim().isEmpty) return null;
    if (imageUrl.startsWith(_assetPrefix)) return AssetImage(imageUrl);
    return CachedNetworkImageProvider(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return _fallback(context);

    // Etkinlik afişleri çoğu zaman 2000 piksel ve üzeri geliyor; hiçbir yerde
    // ekran genişliğinden büyük çizilmiyorlar. Çözünürlük sınırlanmazsa hem
    // bellek hem de her karede ölçekleme maliyeti boşuna büyüyor — bu, kart
    // ile detay arasındaki geçişte fark ediliyor.
    final decodeWidth = _decodeWidth(context);

    if (_isAsset) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: decodeWidth,
        errorBuilder: (context, _, _) => _fallback(context),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheWidth: decodeWidth,
      placeholder: (context, _) => ColoredBox(color: context.tileColor),
      errorBuilder: (context, _, _) => _fallback(context),
    );
  }

  /// Görselin çözüleceği piksel genişliği: ekran genişliğinin cihaz piksel
  /// oranıyla çarpımı. Bundan büyüğü ekranda karşılık bulmuyor.
  int _decodeWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return (size * ratio).round();
  }

  /// Görsel yüklenemezse kırık ikon yerine nötr bir simge gösterilir.
  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: context.tileColor,
      child: Center(
        child: AppIcon(
          AppIcons.announcement,
          size: AppSizes.iconMedium,
          color: context.textTertiary,
        ),
      ),
    );
  }
}
