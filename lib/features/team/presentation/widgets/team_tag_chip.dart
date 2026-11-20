import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Konu, teknoloji ve çalışma etiketlerinin hapı.
class TeamTagChip extends StatelessWidget {
  const TeamTagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.teamChip,
      decoration: BoxDecoration(
        color: context.elevatedColor,
        borderRadius: AppRadiuses.stadiumBorderRadius,
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.textSecondary,
        ),
      ),
    );
  }
}
