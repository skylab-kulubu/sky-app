import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:sky_app/core/widgets/sky_text_field.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/season.dart';
import 'package:sky_app/features/calendar/data/services/event_create_service.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_capacity_dialog.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_cover_picker.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_option_sheet.dart';

part 'event_create_pagemodel.dart';

/// Yetkili kullanıcının (lider, GECEKODU üyesi, YK/DK/ADMIN) etkinlik
/// oluşturduğu ve düzenlediği sayfa. Sonucu [EventFormResult] olarak döner;
/// vazgeçilirse `null`.
///
/// Düzenleme modunda kapak ve kontenjan yok: backend ikisini yalnızca
/// oluştururken alıyor. Silme yetkisi olana AppBar'da çöp kutusu var.
///
/// Ekip düzenleme sayfasıyla aynı form dili: bölüm başlıkları, sade metin
/// alanları, tarih ve seçenekler için ayarlar satırları.
class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key, this.event});

  /// Düzenlenen etkinlik; oluşturmada `null`.
  final EventModel? event;

  static Future<EventFormResult?> open(BuildContext context) => _push(context);

  static Future<EventFormResult?> edit(
    BuildContext context,
    EventModel event,
  ) => _push(context, event: event);

  static Future<EventFormResult?> _push(
    BuildContext context, {
    EventModel? event,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<EventFormResult>(
        builder: (_) => EventCreatePage(event: event),
      ),
    );
  }

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends EventCreatePagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Etkinliği Düzenle' : 'Etkinlik Oluştur'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (canDelete)
            IconButton(
              onPressed: isBusy ? null : onDeletePressed,
              icon: const AppIcon(AppIcons.delete, color: AppColors.red),
            ),
        ],
      ),
      body: ListView(
        padding: AppPaddings.mainPaddingAll,
        children: [
          const SectionHeader('Kapak', isFirst: true),
          EventCoverPicker(
            image: cover,
            imageUrl: currentCoverUrl,
            onTap: onPickCover,
          ),
          const SectionHeader('Bilgiler'),
          SkyTextField(
            controller: nameController,
            hintText: 'Etkinlik adı',
            onChanged: (_) => onFormChanged(),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: locationController,
            hintText: 'Konum',
            onChanged: (_) => onFormChanged(),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: descriptionController,
            hintText: 'Açıklama (isteğe bağlı)',
            minLines: 3,
            maxLines: 8,
          ),
          const SectionHeader('Tarih'),
          _dates(),
          const SectionHeader('Seçenekler'),
          _options(context),
          const SectionHeader('Bağlantılar'),
          SkyTextField(
            controller: formUrlController,
            hintText: 'Başvuru formu (isteğe bağlı)',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: linkedinController,
            hintText: 'LinkedIn gönderisi (isteğe bağlı)',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: AppPaddings.mainPaddingAll,
        child: SkyButton(
          text: isEditing ? 'Kaydet' : 'Oluştur',
          isLoading: isSaving,
          onPressed: canSubmit ? onSubmit : null,
        ),
      ),
    );
  }

  /// Ayarlar satırları: değer olarak tarih ve saat; dokununca önce tarih,
  /// sonra saat seçiliyor.
  Widget _dates() {
    return TileGroup(
      children: [
        SettingsTile(
          icon: AppIcons.calendar,
          iconColor: AppColors.blue,
          title: 'Başlangıç',
          value: dateTimeLabel(startDate),
          onTap: () => onPickDateTime(isStart: true),
        ),
        SettingsTile(
          icon: AppIcons.clock,
          iconColor: AppColors.blue,
          title: 'Bitiş',
          value: dateTimeLabel(endDate),
          titleColor: endDate.isAfter(startDate) ? null : AppColors.red,
          onTap: () => onPickDateTime(isStart: false),
        ),
      ],
    );
  }

  Widget _options(BuildContext context) {
    return TileGroup(
      children: [
        SettingsTile(
          icon: AppIcons.users2,
          iconColor: AppColors.blue,
          title: 'Sahip Ekip',
          value: ownerTeam ?? 'Seç',
          // Tek seçenek varsa (tek ekibin lideri) değiştirilecek bir şey yok.
          trailingIcon: ownerOptions.length > 1 ? AppIcons.chevronRight : null,
          onTap: onChooseOwner,
        ),
        if (canChooseSeason)
          SettingsTile(
            icon: AppIcons.calendar,
            iconColor: AppColors.purple,
            title: 'Sezon',
            value: seasonLabel,
            onTap: onChooseSeason,
          ),
        SettingsTile(
          icon: AppIcons.capacity,
          iconColor: AppColors.orange,
          title: 'Kontenjan',
          value: capacity > 0 ? '$capacity kişi' : 'Sınırsız',
          onTap: onEditCapacity,
        ),
        _activeRow(context),
      ],
    );
  }

  Widget _activeRow(BuildContext context) {
    return Padding(
      padding: AppPaddings.settingsTile,
      child: Row(
        children: [
          IconCircle(icon: AppIcons.ticket, color: AppColors.green),
          const SizedBox(width: AppSizes.bigSpace),
          Expanded(
            child: Text(
              'Başvurular açık',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch.adaptive(
            value: isActive,
            activeTrackColor: context.accentColor,
            onChanged: onActiveChanged,
          ),
        ],
      ),
    );
  }
}

/// Oluşturma/düzenleme sayfasının sonucu.
class EventFormResult {
  const EventFormResult.saved(EventModel this.event) : deleted = false;
  const EventFormResult.deleted() : event = null, deleted = true;

  /// Oluşturulan ya da güncellenen etkinlik; silindiyse `null`.
  final EventModel? event;
  final bool deleted;
}
