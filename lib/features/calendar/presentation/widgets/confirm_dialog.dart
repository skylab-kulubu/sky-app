import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Onay dialogu: başlık, ne olacağını söyleyen metin, "Vazgeç" ve onay
/// butonu (varsayılanı kırmızı "Sil"). Onaylanırsa `true`.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Sil',
    this.confirmColor = AppColors.red,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Sil',
    Color confirmColor = AppColors.red,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.tileColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.cardBorderRadius,
      ),
      title: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Vazgeç',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: context.textTheme.bodyMedium?.copyWith(
              color: confirmColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
