import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';

/// Liste satırı: dolu renkli ikon dairesi + başlık (+ açıklama) + sağ ikon.
///
/// Ayarlar, iletişim, görünüm seçimi ve kulüp menüsü aynı satırı kullanıyor;
/// hepsi aynı dilde okunsun diye tek yerde.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingIcon = AppIcons.chevronRight,
    this.trailingIconColor,
    this.titleColor,
    this.value,
    this.subtitle,
  });

  /// [AppIcons] içindeki ikon adı.
  final String icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  /// Dışarı açılan satırlarda [AppIcons.externalLink] verilir. `null`
  /// verilirse sağda ikon çizilmez (seçim listesinde seçili olmayan satır).
  final String? trailingIcon;

  /// Verilmezse soluk metin rengi; seçim işareti gibi vurgulu ikonlar için.
  final Color? trailingIconColor;

  /// Verilmezse varsayılan metin rengi kullanılır; çıkış gibi yıkıcı
  /// eylemlerde vurgulamak için.
  final Color? titleColor;

  /// Başlığın altındaki tek satırlık soluk açıklama (kulüp menüsü).
  final String? subtitle;

  /// Ayarın güncel değeri; sağ ikondan önce soluk renkte yazılır.
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppPaddings.settingsTile,
          child: Row(
            children: [
              IconCircle(icon: icon, color: iconColor),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(child: _texts(context)),
              if (value != null) ...[
                Text(
                  value!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSizes.midSpace),
              ],
              if (trailingIcon case final trailingIcon?)
                AppIcon(
                  trailingIcon,
                  size: AppSizes.iconSmall,
                  color: trailingIconColor ?? context.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    final title = Text(
      this.title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: titleColor,
      ),
    );

    final subtitle = this.subtitle;
    if (subtitle == null) return title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
