import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/links_service.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/tile_group.dart';

/// Home appbar'ındaki menüden açılan kulüp menüsü: [LinksService.groups]
/// başlıklar altında, bağlantılar tarayıcı sheet'inde.
class ClubMenuSheet extends StatelessWidget {
  const ClubMenuSheet({
    super.key,
    required this.parentContext,
    required this.scrollController,
  });

  /// Sheet kapandıktan sonra yönlendirme için kullanılan, sheet'ten bağımsız
  /// context. Sheet'in kendi context'i pop sonrası geçersiz olur.
  final BuildContext parentContext;

  /// [DraggableScrollableSheet]'in controller'ı; liste bununla kayıyor.
  final ScrollController scrollController;

  /// Liste uzun; sheet ekranın büyük kısmını kaplayıp içeride kayıyor.
  static const double _maxHeightFactor = 0.92;

  /// Sheet bu yüksekliğe kadar sürüklenince kapanıyor.
  static const double _closeHeightFactor = 0.40;

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      isScrollControlled: true,
      // Liste en üstteyken aşağı çekiş sheet'e geçiyor ve en küçük yükseklikte
      // kapanıyor; yoksa sheet yalnız tutma çubuğundan kapanıyordu.
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: _maxHeightFactor,
        maxChildSize: _maxHeightFactor,
        minChildSize: _closeHeightFactor,
        snap: true,
        builder: (_, scrollController) => ClubMenuSheet(
          parentContext: context,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _handle(context),
              Text(
                'Kulüp',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.bigSpace),
              Expanded(child: _list(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSizes.bigSpace),
        decoration: BoxDecoration(
          color: context.dividerColor,
          borderRadius: AppRadiuses.stadiumBorderRadius,
        ),
      ),
    );
  }

  Widget _list(BuildContext sheetContext) {
    const groups = LinksService.groups;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          // İlk başlık, sheet başlığının hemen altında; kendi üst boşluğu
          // araya ikinci bir boşluk ekliyordu.
          SectionHeader(groups[i].title, isFirst: i == 0),
          TileGroup(
            children: [
              for (final link in groups[i].links) _tile(sheetContext, link),
            ],
          ),
        ],
      ],
    );
  }

  Widget _tile(BuildContext sheetContext, LinkItem link) {
    return SettingsTile(
      icon: link.icon,
      iconColor: link.color,
      title: link.name,
      subtitle: link.description,
      trailingIcon: AppIcons.externalLink,
      onTap: () {
        Navigator.pop(sheetContext);
        WebviewService.openLink(parentContext, link);
      },
    );
  }
}
