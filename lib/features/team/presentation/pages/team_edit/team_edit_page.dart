import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/data/services/team_service.dart';
import 'package:sky_app/features/team/presentation/providers/team_provider.dart';
import 'package:sky_app/features/team/presentation/widgets/team_tag_editor.dart';
import 'package:sky_app/features/team/presentation/widgets/team_text_field.dart';
import 'package:sky_app/features/team/presentation/widgets/team_work_sheet.dart';

part 'team_edit_pagemodel.dart';

/// Ekip liderinin, ekibinin CMS kaydını düzenlediği sayfa.
///
/// Açılışta kayıt token'la taze çekiliyor (sürüm numarası için). Alım
/// alanları formda yok ama kayıtta korunuyor (bkz. `Team.toCmsData`).
class TeamEditPage extends StatefulWidget {
  const TeamEditPage({super.key, required this.slug});

  final String slug;

  static Future<void> open(BuildContext context, String slug) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => TeamEditPage(slug: slug)));
  }

  @override
  State<TeamEditPage> createState() => _TeamEditPageState();
}

class _TeamEditPageState extends TeamEditPagemodel {
  @override
  Widget build(BuildContext context) {
    // Kayıt sürerken çıkılamıyor: çıkılırsa kayıt yine tamamlanıyor ama
    // sonucu listeye yansıtacak sayfa kalmıyor. Kaydedilmemiş değişiklikte
    // çıkış onaya bağlı.
    return PopScope(
      canPop: !hasChanges && !isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isSaving) onDiscardRequested();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(original?.name ?? 'Ekibi Düzenle'),
          leading: IconButton(
            icon: const AppIcon(AppIcons.arrowBack),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: _body(context),
        bottomNavigationBar: original == null ? null : _saveBar(),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final loadError = this.loadError;
    if (loadError != null) return _error(context, loadError);
    if (original == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        const SectionHeader('Kısa Açıklama', isFirst: true),
        TeamTextField(
          controller: descriptionController,
          hintText: 'Ekibi bir iki cümleyle anlat',
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => onFormChanged(),
        ),
        const SectionHeader('Uzun Açıklama'),
        TeamTextField(
          controller: longDescriptionController,
          hintText: 'İsteğe bağlı; doluysa detay sayfasında bu gösterilir',
          minLines: 4,
          maxLines: 12,
          onChanged: (_) => onFormChanged(),
        ),
        const SectionHeader('Alım'),
        _recruiting(context),
        const SectionHeader('Konular'),
        TeamTagEditor(
          tags: topics,
          controller: topicInputController,
          hintText: 'Konu ekle (ör. Yapay Zeka)',
          onChanged: onTopicsChanged,
          onInputChanged: onFormChanged,
        ),
        const SectionHeader('Teknolojiler'),
        TeamTagEditor(
          tags: stack,
          controller: stackInputController,
          hintText: 'Teknoloji ekle (ör. Flutter)',
          onChanged: onStackChanged,
          onInputChanged: onFormChanged,
        ),
        const SectionHeader('Çalışmalar'),
        _works(),
      ],
    );
  }

  /// Alım anahtarı. Açıkken ekip detayındaki "Ekibe Katıl" kısa linki
  /// açıyor; kısa linkin SKYLAPP'te tanımlı olması gerektiği için adres
  /// altında gösteriliyor.
  Widget _recruiting(BuildContext context) {
    final team = original!;

    return TileGroup(
      children: [
        Padding(
          padding: AppPaddings.settingsTile,
          child: Row(
            children: [
              IconCircle(icon: AppIcons.users2, color: AppColors.green),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Başvurular açık',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      isRecruiting
                          ? 'Başvuru formu: ${team.applyUrl.replaceFirst('https://', '')}'
                          : 'Detay sayfasında "Başvurular Kapalı" yazar',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.midSpace),
              Switch.adaptive(
                value: isRecruiting,
                activeTrackColor: context.accentColor,
                onChanged: onRecruitingChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _works() {
    return TileGroup(
      children: [
        for (var i = 0; i < works.length; i++)
          SettingsTile(
            icon: AppIcons.project,
            iconColor: AppColors.purple,
            title: works[i].title,
            subtitle: works[i].description.isEmpty
                ? null
                : works[i].description,
            onTap: () => onWorkTap(i),
          ),
        SettingsTile(
          icon: AppIcons.edit,
          iconColor: AppColors.green,
          title: 'Çalışma Ekle',
          trailingIcon: null,
          onTap: onAddWork,
        ),
      ],
    );
  }

  Widget _saveBar() {
    return SafeArea(
      minimum: AppPaddings.mainPaddingAll,
      child: SkyButton(
        text: 'Kaydet',
        isLoading: isSaving,
        onPressed: canSave ? onSavePressed : null,
      ),
    );
  }

  Widget _error(BuildContext context, ApiException error) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              'Ekip Yüklenemedi',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            const SizedBox(height: AppSizes.largeSpace),
            SkyButton(text: 'Tekrar Dene', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
