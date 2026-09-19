import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Silme onayı: başlık, ne silineceğini söyleyen metin, "Vazgeç" / "Sil".
/// Onaylanırsa `true`.
class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(title: title, message: message),
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
            'Sil',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
