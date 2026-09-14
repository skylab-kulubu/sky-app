import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Ekip düzenleme formundaki metin alanı: kenarlıksız, tile zemininde.
///
/// Ayarlar sayfasındaki satır gruplarıyla aynı yüzeyde duruyor ki form,
/// uygulamanın geri kalanından ayrı bir tasarım gibi görünmesin.
class TeamTextField extends StatelessWidget {
  const TeamTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  /// Alanın sağındaki öğe (ör. etiket ekleme butonu).
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: context.accentColor,
      style: context.textTheme.bodyLarge?.copyWith(color: context.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.textTertiary,
        ),
        filled: true,
        fillColor: context.tileColor,
        contentPadding: AppPaddings.infoTile,
        suffixIcon: suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
