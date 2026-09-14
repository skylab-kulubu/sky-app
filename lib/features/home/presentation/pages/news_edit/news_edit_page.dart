import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/sky_tag_editor.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/home/data/models/news_item.dart';
import 'package:sky_app/features/home/data/services/news_service.dart';
import 'package:sky_app/features/home/presentation/providers/news_provider.dart';

part 'news_edit_pagemodel.dart';

/// Haber oluşturma ve düzenleme. `cms:access` rolü olana açılıyor; kayıt
/// CMS'e gidiyor, liste ve açık detay sayfası provider üzerinden güncelleniyor.
///
/// Görsel yükleme yok, yalnızca bağlantı: Super Skylab'a yüklenen medya bir
/// kayda bağlanmazsa gece temizleme işi 24 saat sonra siliyor ve CMS'teki
/// haber bu bağlamayı yapamıyor. Silme de yok (CMS'te endpoint yok).
class NewsEditPage extends StatefulWidget {
  const NewsEditPage({super.key, this.item});

  /// Düzenlenen haber; oluşturmada `null`.
  final NewsItem? item;

  static Future<void> open(BuildContext context, {NewsItem? item}) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => NewsEditPage(item: item)));
  }

  @override
  State<NewsEditPage> createState() => _NewsEditPageState();
}

class _NewsEditPageState extends NewsEditPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Haberi Düzenle' : 'Haber Oluştur'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: AppPaddings.mainPaddingAll,
        children: [
          const SectionHeader('Bilgiler', isFirst: true),
          SkyTextField(
            controller: titleController,
            hintText: 'Başlık',
            onChanged: (_) => onFormChanged(),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: summaryController,
            hintText: 'Özet (listede görünür, isteğe bağlı)',
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: bodyController,
            hintText: 'Haber metni',
            minLines: 6,
            maxLines: 20,
            onChanged: (_) => onFormChanged(),
          ),
          const SectionHeader('Görsel'),
          SkyTextField(
            controller: imageController,
            hintText: 'Görsel bağlantısı (isteğe bağlı)',
            keyboardType: TextInputType.url,
          ),
          const SectionHeader('Etiketler'),
          SkyTagEditor(
            tags: tags,
            controller: tagInputController,
            hintText: 'Etiket ekle (ör. Etkinlik)',
            onChanged: onTagsChanged,
          ),
          const SectionHeader('Seçenekler'),
          _featuredRow(context),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: AppPaddings.mainPaddingAll,
        child: SkyButton(
          text: isEditing ? 'Kaydet' : 'Yayınla',
          isLoading: isSaving,
          onPressed: canSubmit ? onSubmit : null,
        ),
      ),
    );
  }

  Widget _featuredRow(BuildContext context) {
    return TileGroup(
      children: [
        Padding(
          padding: AppPaddings.settingsTile,
          child: Row(
            children: [
              IconCircle(icon: AppIcons.medal, color: AppColors.orange),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(
                child: Text(
                  'Öne çıkar',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Switch.adaptive(
                value: featured,
                activeTrackColor: context.accentColor,
                onChanged: onFeaturedChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
