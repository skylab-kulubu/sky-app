import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/schedule_service.dart';
import 'package:sky_app/features/calendar/presentation/widgets/confirm_delete_dialog.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_option_sheet.dart';

part 'schedule_session_form_pagemodel.dart';

/// Bir güne oturum ekler ya da oturumu düzenler: başlık, konuşmacı, tür,
/// saatler ve (düzenlemede) iptal. Kaydedilir ya da silinirse `true` ile
/// kapanıyor.
class ScheduleSessionFormPage extends StatefulWidget {
  const ScheduleSessionFormPage({
    super.key,
    required this.day,
    required this.initialStart,
    required this.canDelete,
    this.session,
  });

  final EventDay day;

  /// Yeni oturumun önerilen başlangıcı (günün son oturumunun bitişi).
  final DateTime initialStart;
  final bool canDelete;

  /// Düzenlenen oturum; yeni oturum için `null`.
  final EventSession? session;

  static Future<bool> open(
    BuildContext context, {
    required EventDay day,
    required DateTime initialStart,
    required bool canDelete,
    EventSession? session,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ScheduleSessionFormPage(
          day: day,
          initialStart: initialStart,
          canDelete: canDelete,
          session: session,
        ),
      ),
    );
    return changed ?? false;
  }

  @override
  State<ScheduleSessionFormPage> createState() =>
      _ScheduleSessionFormPageState();
}

class _ScheduleSessionFormPageState extends ScheduleSessionFormPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Oturumu Düzenle' : 'Oturum Ekle'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (isEditing && widget.canDelete)
            IconButton(
              onPressed: isBusy ? null : onDeletePressed,
              icon: const AppIcon(AppIcons.delete, color: AppColors.red),
            ),
        ],
      ),
      body: ListView(
        padding: AppPaddings.mainPaddingAll,
        children: [
          const SectionHeader('Bilgiler', isFirst: true),
          SkyTextField(
            controller: titleController,
            hintText: 'Oturum başlığı',
            onChanged: (_) => onFormChanged(),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: speakerController,
            hintText: 'Konuşmacı',
            onChanged: (_) => onFormChanged(),
          ),
          const SectionHeader('Saat'),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.clock,
                iconColor: AppColors.blue,
                title: 'Başlangıç',
                value: clockLabel(start),
                onTap: () => onPickTime(isStart: true),
              ),
              SettingsTile(
                icon: AppIcons.clock,
                iconColor: AppColors.blue,
                title: 'Bitiş',
                value: clockLabel(end),
                titleColor: end.isAfter(start) ? null : AppColors.red,
                onTap: () => onPickTime(isStart: false),
              ),
            ],
          ),
          const SectionHeader('Seçenekler'),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.category,
                iconColor: AppColors.purple,
                title: 'Tür',
                value: typeLabel,
                onTap: onChooseType,
              ),
              if (isEditing) _cancelledRow(context),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: AppPaddings.mainPaddingAll,
        child: SkyButton(
          text: isEditing ? 'Kaydet' : 'Ekle',
          isLoading: isSaving,
          onPressed: canSubmit ? onSave : null,
        ),
      ),
    );
  }

  /// İptal edilen oturum programda üstü çizili kalıyor, kapıda okutulmuyor.
  Widget _cancelledRow(BuildContext context) {
    return Padding(
      padding: AppPaddings.settingsTile,
      child: Row(
        children: [
          const IconCircle(icon: AppIcons.closeCircle, color: AppColors.red),
          const SizedBox(width: AppSizes.bigSpace),
          Expanded(
            child: Text(
              'İptal edildi',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch.adaptive(
            value: cancelled,
            activeTrackColor: context.accentColor,
            onChanged: onCancelledChanged,
          ),
        ],
      ),
    );
  }
}
