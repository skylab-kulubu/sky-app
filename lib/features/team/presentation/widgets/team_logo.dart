import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/team/data/models/team.dart';

/// Ekip logosu; kutusuna oranı bozulmadan sığar.
///
/// Logolar koyu zemine göre hazırlanmış: ALGOLAB ve GAMELAB'ın renkli
/// sürümlerinde beyaz yazı var, açık temada kayboluyor. O ekiplerde açık
/// temada tek renkli sürüm metin rengine boyanıyor. Logosu olmayan
/// (sonradan CMS'e eklenmiş) bir ekipte ikon çiziliyor.
class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final isLight = context.theme.brightness == Brightness.light;
    final lightThemeLogo = team.lightThemeLogo;

    if (isLight && lightThemeLogo != null) {
      return Image.asset(
        lightThemeLogo,
        fit: BoxFit.contain,
        color: context.textPrimary,
        errorBuilder: (context, _, _) => _fallback(context),
      );
    }

    final logo = team.logo;
    if (logo == null) return _fallback(context);

    return Image.asset(
      logo,
      fit: BoxFit.contain,
      errorBuilder: (context, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    return Center(
      child: AppIcon(
        AppIcons.users2,
        size: AppSizes.iconLarge,
        color: context.textTertiary,
      ),
    );
  }
}
