import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/schedule_service.dart';
import 'package:sky_app/features/calendar/presentation/widgets/confirm_delete_dialog.dart';

part 'schedule_day_form_pagemodel.dart';

/// Program gününü ekler ya da düzenler: ad (isteğe bağlı) ve tarih.
/// Kaydedilir ya da silinirse `true` ile kapanıyor.
class ScheduleDayFormPage extends StatefulWidget {
  const ScheduleDayFormPage({
    super.key,
    required this.eventId,
    required this.initialDate,
    required this.canDelete,
    this.day,
  });

  final String eventId;

  /// Yeni günün önerilen tarihi.
  final DateTime initialDate;
  final bool canDelete;

  /// Düzenlenen gün; yeni gün için `null`.
  final EventDay? day;

  static Future<bool> open(
    BuildContext context, {
    required String eventId,
    required DateTime initialDate,
    required bool canDelete,
    EventDay? day,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ScheduleDayFormPage(
          eventId: eventId,
          initialDate: initialDate,
          canDelete: canDelete,
          day: day,
        ),
      ),
    );
    return changed ?? false;
  }

  @override
  State<ScheduleDayFormPage> createState() => _ScheduleDayFormPageState();
}

class _ScheduleDayFormPageState extends ScheduleDayFormPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Günü Düzenle' : 'Gün Ekle'),
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
          const SectionHeader('Gün', isFirst: true),
          SkyTextField(
            controller: nameController,
            hintText: 'Gün adı (isteğe bağlı, ör. 1. Gün)',
          ),
          const SizedBox(height: AppSizes.bigSpace),
          TileGroup(
            children: [
              SettingsTile(
                icon: AppIcons.calendar,
                iconColor: AppColors.blue,
                title: 'Tarih',
                value: dateLabel,
                onTap: onPickDate,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: AppPaddings.mainPaddingAll,
        child: SkyButton(
          text: isEditing ? 'Kaydet' : 'Ekle',
          isLoading: isSaving,
          onPressed: isBusy ? null : onSave,
        ),
      ),
    );
  }
}
