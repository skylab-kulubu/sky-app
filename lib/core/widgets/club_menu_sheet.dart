import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/links_service.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/icon_box.dart';

/// Home appbar'ındaki menü butonundan açılan kulüp menüsü.
///
/// [LinksService.list] içindeki bağlantılar 3 sütunluk grid'de listelenir;
/// hepsi webview'da açılır.
class ClubMenuSheet extends StatelessWidget {
  const ClubMenuSheet({super.key, required this.parentContext});

  /// Sheet kapandıktan sonra yönlendirme için kullanılan, sheet'ten bağımsız
  /// context. Sheet'in kendi context'i pop sonrası geçersiz olur.
  final BuildContext parentContext;

  static const int _columns = 3;
  static const double _maxHeightFactor = 0.75;

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      isScrollControlled: true,
      builder: (_) => ClubMenuSheet(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _handle(),
              Text(
                'Kulüp',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.bigSpace),
              Flexible(child: _grid(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSizes.bigSpace),
        decoration: BoxDecoration(
          color: AppColors.dividerColor,
          borderRadius: AppRadiuses.stadiumBorderRadius,
        ),
      ),
    );
  }

  Widget _grid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: AppSizes.bigSpace,
        crossAxisSpacing: AppSizes.bigSpace,
        childAspectRatio: 0.85,
      ),
      itemCount: LinksService.list.length,
      itemBuilder: (_, index) => _item(context, LinksService.list[index]),
    );
  }

  Widget _item(BuildContext sheetContext, LinkItem link) {
    return Material(
      // Uygulamanın genel deseni: siyah zemin üzerinde tile arka planlı kart.
      color: AppColors.tileBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pop(sheetContext);
          WebviewService.openLink(parentContext, link);
        },
        child: Padding(
          padding: AppPaddings.all6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconBox(
                icon: link.iconPath,
                color: link.color,
                size: AppSizes.iconBoxLarge,
                padding: AppSizes.iconBoxLargePadding,
              ),
              const SizedBox(height: AppSizes.midSpace),
              Text(
                link.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: sheetContext.textTheme.labelMedium?.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
