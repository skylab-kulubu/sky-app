import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';

/// Ayarlar sayfasındaki tek satır: dolu renkli ikon dairesi + başlık + sağ ikon.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingIcon = AppIcons.chevronRight,
    this.titleColor,
    this.value,
  });

  /// [AppIcons] içindeki ikon adı.
  final String icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  /// Dışarı açılan satırlarda [AppIcons.externalLink] verilir.
  final String trailingIcon;

  /// Verilmezse varsayılan metin rengi kullanılır; çıkış gibi yıkıcı
  /// eylemlerde vurgulamak için.
  final Color? titleColor;

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
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: titleColor,
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSizes.midSpace),
              ],
              AppIcon(
                trailingIcon,
                size: AppSizes.iconSmall,
                color: context.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
