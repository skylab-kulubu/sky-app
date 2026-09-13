import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_bar_actions.dart';

/// AppBar başlığının yerini alan, sağdan sola açılan arama kutusu.
///
/// Başlık slotunun tamamını kaplıyor: kapalıyken [title] görünüyor, açılınca
/// başlık solarak kayboluyor ve kutu, sağındaki arama butonunun hemen
/// solundan başlayıp başlığın yerine doğru genişliyor. Genişleme bitince
/// klavye açılıyor; önce açılsaydı kutu daha dar ve imleç kayarken
/// görünüyordu.
class AppBarSearchField extends StatelessWidget {
  const AppBarSearchField({
    super.key,
    required this.title,
    required this.isOpen,
    required this.controller,
    required this.focusNode,
    this.hintText = 'Ara',
  });

  final Widget title;
  final bool isOpen;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  /// Genişleme, [AppBarActions]'ın sekme geçişindeki büyüme hızıyla aynı.
  static const Duration _expandDuration = Duration(milliseconds: 350);
  static const Duration _titleFadeDuration = Duration(milliseconds: 200);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;

        return SizedBox(
          width: fullWidth,
          height: AppBarActions.height,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedOpacity(
                opacity: isOpen ? 0 : 1,
                duration: _titleFadeDuration,
                child: title,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: _expandDuration,
                  curve: _curve,
                  width: isOpen ? fullWidth : 0,
                  height: AppBarActions.height,
                  decoration: BoxDecoration(
                    color: context.tileColor,
                    borderRadius: AppRadiuses.cardBorderRadius,
                    // Yanındaki hap'la aynı kenarlık. Kapalıyken yok: sıfır
                    // genişlikte de çizilip ince bir çizgi bırakırdı.
                    border: isOpen
                        ? Border.all(
                            color: AppBarActions.themeBorderColor(context),
                            width: AppBarActions.borderWidth,
                          )
                        : null,
                  ),
                  onEnd: () {
                    if (isOpen) focusNode.requestFocus();
                  },
                  child: _field(context, fullWidth),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Alan hep tam genişlikte kuruluyor ve kutu onu kırpıyor. Kutuyla birlikte
  /// daralsaydı sıfıra yakın genişlikte metin alanı taşma hatası veriyordu;
  /// sağa yaslı olduğu için de açılırken yerinde durup ortaya çıkıyor.
  Widget _field(BuildContext context, double fullWidth) {
    return ClipRRect(
      borderRadius: AppRadiuses.cardBorderRadius,
      child: OverflowBox(
        minWidth: fullWidth,
        maxWidth: fullWidth,
        alignment: Alignment.centerRight,
        // Kutu yüksekliği sıkı veriyor; metin alanı o yüksekliğe zorlanınca
        // kendi boyunda çiziliyor ve üste yapışıyordu (`textAlignVertical`
        // yalnızca `expands` ile işe yarıyor). Center kısıtı gevşetip alanı
        // doğal boyunda dikeyde ortalıyor.
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            // Kapalıyken kutu görünmüyor; odak ve dokunma da almamalı.
            enabled: isOpen,
            textInputAction: TextInputAction.search,
            cursorColor: context.accentColor,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: context.textTheme.bodyLarge?.copyWith(
                color: context.textTertiary,
              ),
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: AppPaddings.appBarSearchField,
            ),
          ),
        ),
      ),
    );
  }
}
