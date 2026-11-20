import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/links_service.dart';
import 'package:sky_app/core/widgets/app_bar_actions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/handoff_service.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/handoff_sheet.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/bottom_scrim.dart';
import 'package:sky_app/core/widgets/color_glow.dart';
import 'package:sky_app/core/widgets/cover_image.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';
import 'package:sky_app/features/calendar/data/services/event_status_service.dart';
import 'package:sky_app/features/calendar/data/services/schedule_service.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/profile/presentation/providers/activity_provider.dart';
import 'package:sky_app/features/calendar/data/services/event_palette_service.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_create/event_create_page.dart';
import 'package:sky_app/features/calendar/presentation/pages/event_schedule/event_schedule_page.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/calendar/presentation/widgets/confirm_dialog.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_cancel_dialog.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_copy_dialog.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_cover_hero.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_manage_sheet.dart';

part 'event_detail_pagemodel.dart';

/// Etkinlik detayı; listedeki karttan açılıyor, kapak [Hero] ile uçuyor.
///
/// **Sayfa temadan bağımsız koyu.** Zemini kapağın baskın rengi; açık zeminde
/// bu renk soluyordu. Renkler `context`'ten değil [AppColors]'ın `onCover*`
/// sabitlerinden.
class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final EventModel event;

  /// Görselin uçuşu izlenebilsin diye varsayılan 300 ms'den uzun.
  static const Duration _openDuration = Duration(milliseconds: 450);
  static const Duration _closeDuration = Duration(milliseconds: 350);

  /// Sayfayı bir listeden açar. Geçiş burada; açan tarafın tek işi kapağını
  /// [EventCoverHero] ile sarmak.
  static Future<void> open(BuildContext context, EventModel event) {
    return Navigator.of(
      context,
      // Listeler shell'in içinde; kök navigator olmadan detay navbar'ın altında
      // açılırdı.
      rootNavigator: true,
    ).push(
      PageRouteBuilder<void>(
        transitionDuration: _openDuration,
        reverseTransitionDuration: _closeDuration,
        pageBuilder: (_, _, _) => EventDetailPage(event: event),
        // Sayfa yumuşakça biniyor; kapak onun üstünde Hero olarak uçuyor.
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends EventDetailPagemodel {
  /// Programdaki saat sütununun genişliği; başlıklar hizalı dursun.
  static const double _sessionTimeWidth = 64;

  static const double _descriptionLineHeight = 1.6;

  static const double _titleLineHeight = 1.25;

  static const Duration _tintFade = Duration(milliseconds: 450);

  /// Leke konumları sabit; renkler kapaktan geldiği için her etkinlikte farklı.
  static const List<GlowSpot> _glowSpots = [
    (center: Alignment(-0.7, -1.0), radius: 1.15, opacity: 0.70),
    (center: Alignment(1.0, -0.45), radius: 0.95, opacity: 0.55),
    (center: Alignment(-0.6, 0.45), radius: 1.25, opacity: 0.42),
    (center: Alignment(0.9, 1.0), radius: 1.0, opacity: 0.35),
  ];

  /// Alt karartmanın zemine karışma oranı; sayfanın alt bölgesindeki renk
  /// yoğunluğuna yakın kalsın diye.
  static const double _scrimTint = 0.18;

  static const double _headingRevealOffset = 36.0;
  static const double _headingRevealDistance = 40.0;

  double get _scrollOffset =>
      scrollController.hasClients ? scrollController.offset : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coverBackdropBase,
      extendBody: true,
      body: Stack(
        children: [
          _backdrop(),
          Column(
            children: [
              _topHeader(context),
              Expanded(
                child: Stack(
                  children: [_pinnedCover(context), _content(context)],
                ),
              ),
            ],
          ),
          // Karartma zeminin alt rengine gidiyor; tema rengi butonun ardında bant gibi
          // dururdu.
          BottomScrim(color: _tinted(_scrimTint)),
        ],
      ),
      bottomNavigationBar: _joinBar(context),
    );
  }

  Widget _backdrop() {
    final tints = backdropTints;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.coverBackdropBase,
        child: AnimatedOpacity(
          // Palet görsel çözüldükten sonra geliyor; renk aniden belirmesin.
          opacity: tints.isEmpty ? 0 : 1,
          duration: _tintFade,
          // Lekeler tam ekran gradyan ve yerleştikten sonra değişmiyor; sınır olmadan
          // açılış animasyonunun her karesinde yeniden hesaplanıyorlardı.
          child: RepaintBoundary(
            child: ColorGlow(colors: tints, spots: _glowSpots),
          ),
        ),
      ),
    );
  }

  /// Kapak rengini verilen oranda koyu tabanla karıştırır; renk yoksa düz taban.
  Color _tinted(double strength) {
    if (backdropTints.isEmpty) return AppColors.coverBackdropBase;

    return Color.alphaBlend(
      backdropTints.first.withValues(alpha: strength),
      AppColors.coverBackdropBase,
    );
  }

  Widget _topHeader(BuildContext context) {
    const gap = SizedBox(width: AppSizes.midSpace);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            Padding(
              padding: AppPaddings.appBarLeading,
              child: Center(
                child: AppBarActions(
                  icons: const [AppIcons.arrowBack],
                  onIconTap: (_) => Navigator.of(context).pop(),
                  backgroundColor: AppColors.onCoverSurface,
                  iconColor: AppColors.onCover,
                ),
              ),
            ),
            gap,
            Expanded(
              child: AnimatedBuilder(
                animation: scrollController,
                child: Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: AppColors.onCover,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                builder: (context, child) {
                  // Sayfadaki başlık çubuğun altına girdikten sonra beliriyor.
                  final threshold = _coverSize(context) + _headingRevealOffset;
                  final opacity =
                      ((_scrollOffset - threshold) / _headingRevealDistance)
                          .clamp(0.0, 1.0);

                  return Opacity(opacity: opacity, child: child);
                },
              ),
            ),
            gap,
            // Geri butonuyla aynı hap; başlığın iki yanı simetrik kalıyor.
            Padding(
              padding: AppPaddings.appBarActions,
              child: Center(
                child: AppBarActions(
                  // Yetkisi olana paylaşın solunda yönetim menüsü.
                  icons: [if (canEdit) AppIcons.settings, AppIcons.share],
                  onIconTap: (icon) => icon == AppIcons.settings
                      ? onManagePressed()
                      : onSharePressed(),
                  backgroundColor: AppColors.onCoverSurface,
                  iconColor: AppColors.onCover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kapak kare: afişler çoğu zaman kare ya da dikey, yatay kutuda kırpılıyor.
  double _coverSize(BuildContext context) =>
      MediaQuery.sizeOf(context).width -
      (AppPaddings.mainPaddingHorizontal.left * 2);

  /// Kaydırıldıkça kapağın yeri sabit kalıyor, yüksekliği büzülüyor.
  Widget _pinnedCover(BuildContext context) {
    final coverSize = _coverSize(context);

    return Positioned(
      top: AppSizes.bigSpace,
      left: AppPaddings.mainPaddingHorizontal.left,
      right: AppPaddings.mainPaddingHorizontal.right,
      child: AnimatedBuilder(
        animation: scrollController,
        // Görselin kendisi kaydırmadan etkilenmiyor; `child` olarak
        // verilmezse her karede baştan kuruluyor.
        child: EventCoverHero(
          eventId: event.id,
          child: ClipRRect(
            borderRadius: AppRadiuses.cardBorderRadius,
            child: CoverImage(
              imageUrl: coverSource.coverPageUrl,
              placeholderUrl: coverSource.coverCardUrl,
            ),
          ),
        ),
        builder: (context, child) {
          final currentHeight = (coverSize - _scrollOffset).clamp(
            0.0,
            coverSize,
          );

          if (currentHeight <= 0) return const SizedBox.shrink();

          return SizedBox(
            height: currentHeight,
            width: coverSize,
            child: child,
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: AppPaddings.mainPaddingHorizontal.copyWith(
        // Kapağın altındaki boşluk üstündekiyle aynı (haber ve ekip detayı gibi).
        top: AppSizes.bigSpace + _coverSize(context) + AppSizes.bigSpace,
        bottom: AppSizes.navBarClearance,
      ),
      children: [
        _title(context),
        if (event.ownerTeam.isNotEmpty) ...[
          const SizedBox(height: AppSizes.midSpace),
          _typeRow(context),
        ],
        // Gruplar arası boşluk bölüm başlıklarının üst boşluğuyla aynı (24).
        const SizedBox(height: AppSizes.largeSpace),
        _dateBlock(context),
        const SizedBox(height: AppSizes.bigSpace),
        _statusRow(context),
        // Bölüm başlıklarının kendi üst boşluğu var; araya ayrıca boşluk konmuyor.
        if (event.location.isNotEmpty) ...[
          _sectionHeader(context, 'Konum'),
          const SizedBox(height: AppSizes.bigSpace),
          _infoBlock(context, icon: AppIcons.location, title: event.location),
        ],
        if (event.formUrl.isNotEmpty) ...[
          _sectionHeader(context, 'Başvuru Formu'),
          const SizedBox(height: AppSizes.bigSpace),
          GestureDetector(
            onTap: onFormTap,
            behavior: HitTestBehavior.opaque,
            child: _infoBlock(
              context,
              icon: AppIcons.form,
              title: 'Formu Aç',
              subtitle: formSubtitle,
            ),
          ),
        ],
        _sectionHeader(context, 'Etkinlik Hakkında'),
        const SizedBox(height: AppSizes.bigSpace),
        _description(context),
        // Program herkese; boşken yalnızca düzenleyebilene "Program ekle".
        if (hasSchedule || canEdit) ...[
          _sectionHeader(
            context,
            'Program',
            onEdit: hasSchedule && canEdit ? onEditSchedule : null,
          ),
          const SizedBox(height: AppSizes.bigSpace),
          if (hasSchedule)
            _schedule(context)
          else
            GestureDetector(
              onTap: onEditSchedule,
              behavior: HitTestBehavior.opaque,
              child: _infoBlock(
                context,
                icon: AppIcons.calendarAdd,
                title: 'Program ekle',
                subtitle: 'Günleri ve oturumları gir; yoklama oturuma göre.',
              ),
            ),
        ],
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      event.name,
      style: context.textTheme.headlineSmall?.copyWith(
        color: AppColors.onCover,
        fontWeight: FontWeight.bold,
        height: _titleLineHeight,
      ),
    );
  }

  Widget _typeRow(BuildContext context) {
    return Row(
      children: [
        AppIcon(
          AppIcons.project,
          size: AppSizes.iconSmall,
          color: AppColors.onCoverFaint,
        ),
        const SizedBox(width: AppSizes.midSpace),
        Flexible(
          child: Text(
            event.ownerLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.onCoverMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateBlock(BuildContext context) {
    return _infoBlock(
      context,
      icon: AppIcons.calendar,
      title: event.formattedDayLabel,
      subtitle: event.formattedTimeRange,
    );
  }

  /// Başvuru durumu; kullanıcı aşağı inmeden görsün diye. İptalde sebep de
  /// altında.
  Widget _statusRow(BuildContext context) {
    final (icon, color, text) = switch (event.phase) {
      EventPhase.open => (
        AppIcons.checkCircle,
        AppColors.green,
        'Başvurular açık',
      ),
      EventPhase.closed => (
        AppIcons.clock,
        AppColors.orange,
        'Başvurular kapalı',
      ),
      EventPhase.ended => (
        AppIcons.clock,
        AppColors.onCoverMuted,
        'Etkinlik sona erdi',
      ),
      EventPhase.draft => (
        AppIcons.edit,
        AppColors.orange,
        'Taslak, henüz yayınlanmadı',
      ),
      EventPhase.cancelled => (
        AppIcons.closeCircle,
        AppColors.red,
        'Etkinlik iptal edildi',
      ),
    };
    final reason = event.isCancelled ? event.cancelReason.trim() : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon, size: AppSizes.iconMedium, color: color),
        const SizedBox(width: AppSizes.bigSpace),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (reason.isNotEmpty)
                Text(
                  reason,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onCoverMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// İkon + iki katlı metin: üstte asıl bilgi, altında ikincil satır.
  Widget _infoBlock(
    BuildContext context, {
    required String icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marka lilası: koyu zeminde her iki temada da aynı okunuyor.
        AppIcon(icon, size: AppSizes.iconMedium, color: AppColors.primaryColor),
        const SizedBox(width: AppSizes.bigSpace),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isNotEmpty ? title : 'Belirtilmemiş',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onCover,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSizes.smallSpace),
                Text(
                  subtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onCoverMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Bölüm başlığı: ayarlar sayfasıyla aynı biçim ve altında ayraç; renk farklı,
  /// zemin temadan bağımsız koyu.
  Widget _sectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppPaddings.sectionHeader,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onCoverFaint,
                  ),
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: AppIcon(
                    AppIcons.edit,
                    size: AppSizes.iconSmall,
                    color: AppColors.onCoverFaint,
                  ),
                ),
            ],
          ),
        ),
        Divider(color: AppColors.onCoverDivider, height: 1),
      ],
    );
  }

  /// Birden fazla gün varsa her günün başlığı yazılıyor.
  Widget _schedule(BuildContext context) {
    final days = schedule.where((e) => e.sessions.isNotEmpty).toList();
    final showDayTitles = days.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, entry) in days.indexed) ...[
          if (showDayTitles) ...[
            if (index > 0) const SizedBox(height: AppSizes.largeSpace),
            Text(
              [
                entry.day.name,
                entry.day.dateLabel,
              ].where((p) => p.isNotEmpty).join('  •  '),
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.onCover,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.bigSpace),
          ],
          for (final (i, session) in entry.sessions.indexed) ...[
            if (i > 0) const SizedBox(height: AppSizes.bigSpace),
            _sessionRow(context, session),
          ],
        ],
      ],
    );
  }

  /// Solda saat, sağda başlık ve konuşmacı; iptal edilen oturum üstü çizili.
  Widget _sessionRow(BuildContext context, EventSession session) {
    final cancelled = session.cancelled;
    final start = session.startTime;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _sessionTimeWidth,
          child: Text(
            start == null
                ? '–'
                : '${start.hour.toString().padLeft(2, '0')}:'
                      '${start.minute.toString().padLeft(2, '0')}',
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: cancelled ? AppColors.onCoverFaint : AppColors.onCover,
                  fontWeight: FontWeight.w500,
                  decoration: cancelled ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.onCoverFaint,
                ),
              ),
              const SizedBox(height: AppSizes.smallSpace),
              Text(
                cancelled
                    ? 'İptal edildi'
                    : [
                        session.speakerName,
                        session.typeLabel,
                      ].where((p) => p.isNotEmpty).join('  •  '),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onCoverMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _description(BuildContext context) {
    return Text(
      event.description.isNotEmpty
          ? event.description
          : 'Bu etkinlik için henüz açıklama girilmemiş.',
      style: context.textTheme.bodyLarge?.copyWith(
        color: AppColors.onCoverMuted,
        height: _descriptionLineHeight,
      ),
    );
  }

  /// Katılım butonu altta sabit, uzun açıklamada sona kaydırmak gerekmesin.
  /// Renkler açıkça veriliyor: sayfa temadan bağımsız koyu.
  Widget _joinBar(BuildContext context) {
    final action = joinButtonAction;
    final enabled = action != null;

    return SafeArea(
      minimum: AppPaddings.mainPaddingAll,
      child: SkyButton(
        text: joinButtonLabel,
        isLoading: isJoining || isUpdatingStatus,
        // Pasif zemin opak: yarı saydamken renkli zemin sızıp buton delik gibi
        // görünüyordu.
        backgroundColor: enabled
            ? AppColors.primaryColor
            : Color.alphaBlend(AppColors.onCoverSurface, _tinted(_scrimTint)),
        textColor: enabled
            ? AppColors.skyPassForeground
            : AppColors.onCoverFaint,
        onPressed: action,
      ),
    );
  }
}
