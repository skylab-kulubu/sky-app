import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Liste satırlarını tek bir kart içinde toplar ve aralarına ayraç koyar.
///
/// Ayarlar, hesap ve sertifika sayfalarının ortak kabuğu.
///
/// Ayraçlar dışarıdan verilmez: satırlar koşullu çizildiğinde (boş gelen bir
/// alan gizlendiğinde) grubun başında ya da sonunda boşta ayraç kalmasın diye
/// burada üretilir.
class TileGroup extends StatelessWidget {
  const TileGroup({
    super.key,
    required this.children,
    this.dividerIndent = AppSizes.dividerIndentIcon,
  });

  final List<Widget> children;

  /// Ayracın sol boşluğu; metinle hizalanması için satırın kendi düzenine
  /// bağlıdır. İkon dairesi olmayan satırlarda [AppSizes.dividerIndent]
  /// verilir.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      child: Container(
        color: context.tileColor,
        child: Column(
          // stretch olmadan satırlar kendi içerik genişliğinde kalıp yatayda
          // ortalanıyor; kartın tamamını kaplamaları gerekiyor.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) _divider(context),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    color: context.dividerColor,
    indent: dividerIndent,
    endIndent: AppSizes.dividerIndent,
  );
}
