import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/core/widgets/sky_tag_editor.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';

/// Tek bir çalışmayı ekleyen ya da düzenleyen sheet. Kaydedince çalışmanın
/// yeni hâlini döner; vazgeçilirse `null`.
class TeamWorkSheet extends StatefulWidget {
  const TeamWorkSheet({super.key, this.work});

  /// Düzenlenen çalışma; yeni eklemede `null`.
  final TeamWork? work;

  static Future<TeamWork?> show(BuildContext context, {TeamWork? work}) {
    return showModalBottomSheet<TeamWork>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => TeamWorkSheet(work: work),
    );
  }

  @override
  State<TeamWorkSheet> createState() => _TeamWorkSheetState();
}

class _TeamWorkSheetState extends State<TeamWorkSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.work?.title,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.work?.description,
  );
  late final TextEditingController _image = TextEditingController(
    text: widget.work?.image,
  );
  late List<String> _tags = widget.work?.tags ?? const [];
  final TextEditingController _tagInput = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _image.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty;

  void _save() {
    Navigator.pop(
      context,
      TeamWork(
        title: _title.text.trim(),
        description: _description.text.trim(),
        image: _image.text.trim(),
        tags: SkyTagEditor.withPending(_tags, _tagInput.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Klavye açılınca alanlar onun üstünde kalsın.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: AppPaddings.mainPaddingAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.work == null ? 'Çalışma Ekle' : 'Çalışmayı Düzenle',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.largeSpace),
              SkyTextField(
                controller: _title,
                hintText: 'Başlık',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSizes.bigSpace),
              SkyTextField(
                controller: _description,
                hintText: 'Açıklama',
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: AppSizes.bigSpace),
              SkyTextField(
                controller: _image,
                hintText: 'Görsel bağlantısı (isteğe bağlı)',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSizes.bigSpace),
              SkyTagEditor(
                tags: _tags,
                controller: _tagInput,
                hintText: 'Etiket ekle',
                onChanged: (tags) => setState(() => _tags = tags),
              ),
              const SizedBox(height: AppSizes.largeSpace),
              SkyButton(text: 'Tamam', onPressed: _canSave ? _save : null),
            ],
          ),
        ),
      ),
    );
  }
}
