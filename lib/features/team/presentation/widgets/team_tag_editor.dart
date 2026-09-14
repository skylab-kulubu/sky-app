import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/team/presentation/widgets/team_text_field.dart';

/// Etiket listesi düzenleyici: yazıp "+"ya ya da klavyedeki onaya basınca
/// etiket eklenir, hapın çarpısıyla silinir. Aynı etiket iki kez eklenmez.
///
/// Metin alanının controller'ı dışarıdan veriliyor: alanda yazılı kalıp
/// henüz eklenmemiş metin, form kaydedilirken [withPending] ile listeye
/// katılıyor. Yalnızca onay tuşuyla eklendiğinde yazılıp doğrudan
/// "Kaydet"e basılan etiketler sessizce kayboluyordu.
class TeamTagEditor extends StatelessWidget {
  const TeamTagEditor({
    super.key,
    required this.tags,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.onInputChanged,
  });

  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  /// Alandaki yazı değiştikçe; formun "Kaydet" durumunu güncellemek için.
  final VoidCallback? onInputChanged;

  /// [tags] ile alanda yazılı kalan metnin birleşimi. Metin boşsa ya da
  /// zaten listedeyse liste aynen döner.
  static List<String> withPending(List<String> tags, String pending) {
    final tag = pending.trim();
    if (tag.isEmpty) return tags;

    final exists = tags.any((item) => item.toLowerCase() == tag.toLowerCase());
    return exists ? tags : [...tags, tag];
  }

  void _add() {
    final updated = withPending(tags, controller.text);
    controller.clear();
    onInputChanged?.call();
    if (!identical(updated, tags)) onChanged(updated);
  }

  void _remove(String tag) {
    onChanged([
      for (final item in tags)
        if (item != tag) item,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TeamTextField(
          controller: controller,
          hintText: hintText,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _add(),
          onChanged: (_) => onInputChanged?.call(),
          suffix: IconButton(
            onPressed: _add,
            icon: AppIcon(
              AppIcons.add,
              size: AppSizes.iconMedium,
              color: context.accentColor,
            ),
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: AppSizes.bigSpace),
          Wrap(
            spacing: AppSizes.midSpace,
            runSpacing: AppSizes.midSpace,
            children: [for (final tag in tags) _chip(context, tag)],
          ),
        ],
      ],
    );
  }

  Widget _chip(BuildContext context, String tag) {
    return Container(
      padding: AppPaddings.teamChip,
      decoration: BoxDecoration(
        color: context.elevatedColor,
        borderRadius: AppRadiuses.stadiumBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(width: AppSizes.midSpace),
          GestureDetector(
            onTap: () => _remove(tag),
            child: AppIcon(
              AppIcons.close,
              size: AppSizes.iconSmall,
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
