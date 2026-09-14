import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Formlardaki metin alanı: kenarlıksız, tile zemininde (ekip düzenleme,
/// etkinlik oluşturma).
///
/// Ayarlar sayfasındaki satır gruplarıyla aynı yüzeyde duruyor ki formlar,
/// uygulamanın geri kalanından ayrı bir tasarım gibi görünmesin.
class SkyTextField extends StatelessWidget {
  const SkyTextField({
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
    this.textStyle,
    this.fillColor,
    this.autofocus = false,
    this.inputFormatters,
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

  /// Yazı stili; verilmezse gövde metni. Başlık gibi büyük alanlar için.
  final TextStyle? textStyle;

  /// Zemin; verilmezse tile rengi. Zaten tile renginde duran yüzeylerde
  /// (dialog) alan kaybolmasın diye bir tık yükseltilmiş renk verilir.
  final Color? fillColor;

  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: context.accentColor,
      style: (textStyle ?? context.textTheme.bodyLarge)?.copyWith(
        color: context.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: (textStyle ?? context.textTheme.bodyLarge)?.copyWith(
          color: context.textTertiary,
        ),
        filled: true,
        fillColor: fillColor ?? context.tileColor,
        contentPadding: AppPaddings.infoTile,
        suffixIcon: suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
