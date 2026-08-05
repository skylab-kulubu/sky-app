import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// SkyPass kartının altındaki hızlı eylem: yuvarlak ikon + altında etiket.
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  /// [AppIcons] içindeki ikon adı.
  final String icon;
  final String label;

  /// Sayfaları henüz yok; verilmezse dokunma görsel olarak çalışır ama
  /// bir şey yapmaz.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: context.tileColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () {},
            child: SizedBox(
              width: AppSizes.quickActionCircle,
              height: AppSizes.quickActionCircle,
              child: Center(
                child: AppIcon(
                  icon,
                  size: AppSizes.iconMedium,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.midSpace),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
