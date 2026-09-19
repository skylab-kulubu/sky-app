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

/// Formlardaki görsel alanı (etkinlik kapağı, haber görseli); iki formda da
/// aynı boyutta kare. Görsel yokken dokunmaya davet eden boş alan, seçilince
/// önizleme; dokununca değişiyor. Düzenlemede yeni görsel seçilene kadar
/// mevcut görsel ([imageUrl]) görünüyor.
class CoverPicker extends StatelessWidget {
  const CoverPicker({
    super.key,
    required this.image,
    required this.onTap,
    this.imageUrl = '',
    this.aspectRatio = 1,
    this.label = 'Kapak görseli seç',
  });

  final XFile? image;
  final VoidCallback onTap;

  /// Mevcut görsel; boşsa yok.
  final String imageUrl;

  final double aspectRatio;

  /// Boş alandaki davet yazısı.
  final String label;

  @override
  Widget build(BuildContext context) {
    final image = this.image;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
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
          label,
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
