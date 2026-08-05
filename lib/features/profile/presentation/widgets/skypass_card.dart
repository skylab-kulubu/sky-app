import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Kulüp üyelik kartı. Banka kartı oranında (85.6 × 53.98 mm) çizilir.
class SkyPassCard extends StatelessWidget {
  const SkyPassCard({
    super.key,
    required this.name,
    required this.skyNumber,
    required this.subtitle,
  });

  final String name;
  final String skyNumber;

  /// Bölüm ya da ekip bilgisi; boşsa satır çizilmez.
  final String subtitle;

  static const double _cardAspectRatio = 1.586;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _cardAspectRatio,
      child: Container(
        padding: AppPaddings.skyPassCard,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.skyPassGradientStart,
              AppColors.skyPassGradientEnd,
            ],
          ),
          borderRadius: AppRadiuses.skyPassCardBorderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_header(context), const Spacer(), _footer(context)],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'SkyPass',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.skyPassForeground,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SvgPicture.asset(
          AppAssets.skylab,
          width: AppSizes.iconLarge,
          height: AppSizes.iconLarge,
          // Logo beyaz monokrom; kartın koyu metin rengine boyanıyor.
          colorFilter: const ColorFilter.mode(
            AppColors.skyPassForeground,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            AppIcon(
              AppIcons.nfc,
              size: AppSizes.iconMedium,
              color: AppColors.skyPassForegroundMuted,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.bigSpace),
        Text(
          name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.skyPassForeground,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSizes.smallSpace),
        Row(
          children: [
            if (skyNumber.isNotEmpty) ...[
              Text(skyNumber, style: _mutedStyle),
              if (subtitle.isNotEmpty) Text('  •  ', style: _mutedStyle),
            ],
            if (subtitle.isNotEmpty)
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _mutedStyle,
                ),
              ),
          ],
        ),
      ],
    );
  }

  TextStyle get _mutedStyle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.skyPassForegroundMuted,
    letterSpacing: 0.5,
  );
}
