import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/cover_image.dart';

/// Etkinlik formundaki kapak alanı. Etkinlik kartındaki kapakla aynı oran
/// ve köşeler; listede nasıl görüneceği burada da görülüyor. Görsel yokken
/// dokunmaya davet eden boş alan, seçilince önizleme; dokununca değişiyor.
/// Düzenlemede yeni görsel seçilene kadar mevcut kapak ([imageUrl]) görünüyor.
class EventCoverPicker extends StatelessWidget {
  const EventCoverPicker({
    super.key,
    required this.image,
    required this.onTap,
    this.imageUrl = '',
  });

  final XFile? image;
  final VoidCallback onTap;

  /// Etkinliğin mevcut kapağı; boşsa yok.
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final image = this.image;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: AppSizes.eventCoverAspect,
        child: ClipRRect(
          borderRadius: AppRadiuses.cardBorderRadius,
          child: ColoredBox(
            color: context.tileColor,
            child: image != null
                ? _preview(image)
                : imageUrl.isNotEmpty
                ? CoverImage(imageUrl: imageUrl)
                : _placeholder(context),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(
          AppIcons.galleryAdd,
          size: AppSizes.iconLarge,
          color: context.textTertiary,
        ),
        const SizedBox(height: AppSizes.midSpace),
        Text(
          'Kapak görseli seç',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Web'de dosya yolu yok, seçilen görsel bir blob adresi.
  Widget _preview(XFile image) {
    return kIsWeb
        ? Image.network(image.path, fit: BoxFit.cover)
        : Image.file(File(image.path), fit: BoxFit.cover);
  }
}
