import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Liste bölümlerinin üstündeki küçük başlık ("Tercihler", "Kaynaklar" ...).
///
/// Kendi üst boşluğunu taşır; iki bölüm arasına ayrıca boşluk konmaz.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.isFirst = false});

  final String title;

  /// Sayfanın ilk öğesi mi. Üst boşluk bölümleri birbirinden ayırmak için;
  /// listenin en başında sayfa kenar boşluğunun üstüne binip başlığı
  /// appbar'dan fazla uzaklaştırıyordu.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isFirst
          ? AppPaddings.sectionHeader.copyWith(top: 0)
          : AppPaddings.sectionHeader,
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textSecondary,
        ),
      ),
    );
  }
}
