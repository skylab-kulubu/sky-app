import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_bar_actions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/bottom_scrim.dart';
import 'package:sky_app/core/widgets/color_glow.dart';
import 'package:sky_app/core/widgets/cover_image.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_palette_service.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';
import 'package:sky_app/features/calendar/presentation/widgets/event_cover_hero.dart';

part 'event_detail_pagemodel.dart';

/// Etkinliğin tüm ayrıntılarını gösteren sayfa.
///
/// Listedeki karttan açılır: kapak görseli [Hero] ile kartın yerinden
/// buraya uçar, sayfanın geri kalanı üstüne biner. Kök navigator'a push
/// edildiği için navbar'ın altında kalmaz.
///
/// **Sayfa temadan bağımsız koyu.** Zemini kapak görselinin baskın rengi
/// belirliyor; o renk açık bir zemine karıştırıldığında soluyor ve etkinliğin
/// kimliği kayboluyordu. Bu yüzden buradaki renkler `context` erişimcilerinden
/// değil, [AppColors]'ın `onCover*` sabitlerinden okunuyor.
class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final EventModel event;

  /// Görselin uçuşu izlenebilsin diye varsayılan 300 ms'den uzun.
  static const Duration _openDuration = Duration(milliseconds: 450);
  static const Duration _closeDuration = Duration(milliseconds: 350);

  /// Sayfayı bir listeden açar.
  ///
  /// Geçiş burada tanımlı: hem Etkinlikler sekmesindeki kart hem ana
  /// sayfadaki yaklaşan etkinlik satırı aynı hareketi kullanıyor. Açan
  /// tarafın tek sorumluluğu, kapağını [EventCoverHero] ile sarmak.
  static Future<void> open(BuildContext context, EventModel event) {
    return Navigator.of(
      context,
      // Listeler shell'in içinde; kök navigator olmadan detay sayfası
      // navbar'ın altında açılır.
      rootNavigator: true,
    ).push(
      PageRouteBuilder<void>(
        transitionDuration: _openDuration,
        reverseTransitionDuration: _closeDuration,
        pageBuilder: (_, _, _) => EventDetailPage(event: event),
        // Sayfanın kendisi yumuşakça biniyor; kapak görseli onun üstünde
        // Hero olarak kendi yolunu uçuyor.
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
  static const double _descriptionLineHeight = 1.6;

  /// Başlık iki satıra taştığında satırlar birbirine yapışmasın diye.
  static const double _titleLineHeight = 1.25;

  static const Duration _tintFade = Duration(milliseconds: 450);

  /// Zemindeki renk lekelerinin yerleşimi. Konumlar sabit, renkler kapaktan
  /// geldiği için her etkinlikte farklı bir dağılım çıkıyor.
  static const List<GlowSpot> _glowSpots = [
    (center: Alignment(-0.7, -1.0), radius: 1.15, opacity: 0.70),
    (center: Alignment(1.0, -0.45), radius: 0.95, opacity: 0.55),
    (center: Alignment(-0.6, 0.45), radius: 1.25, opacity: 0.42),
    (center: Alignment(0.9, 1.0), radius: 1.0, opacity: 0.35),
  ];

  /// Alt karartmanın zemine karışma oranı; sayfanın alt bölgesindeki renk
  /// yoğunluğuna yakın kalsın diye.
  static const double _scrimTint = 0.18;

  /// Çubuktaki başlığın belirmeye başladığı kaydırma mesafesi (kapağın
  /// altından itibaren) ve tamamen görünür olana kadar geçen mesafe.
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
          // Karartma zeminin alt rengine gidiyor; tema rengine gitseydi
          // butonun ardında ayrı bir bant gibi dururdu.
          BottomScrim(color: _tinted(_scrimTint)),
        ],
      ),
      bottomNavigationBar: _joinBar(context),
    );
  }

  /// Sayfanın zemini: koyu taban ve üstüne dağılmış kapak renkleri.
  Widget _backdrop() {
    final tints = backdropTints;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.coverBackdropBase,
        child: AnimatedOpacity(
          // Palet görsel çözüldükten sonra geliyor; renk aniden belirmesin.
          opacity: tints.isEmpty ? 0 : 1,
          duration: _tintFade,
          // Lekeler tam ekran gradyan; renkler yerleştikten sonra hiç
          // değişmiyorlar. Sınır olmadan sayfanın her yeniden çiziminde
          // (açılış animasyonu boyunca her kare) baştan hesaplanıyorlar.
          child: RepaintBoundary(
            child: ColorGlow(colors: tints, spots: _glowSpots),
          ),
        ),
      ),
    );
  }

  /// Kapak rengini verilen oranda koyu tabanla karıştırır. Renk henüz
  /// çözülmediyse düz taban döner.
  Color _tinted(double strength) {
    if (backdropTints.isEmpty) return AppColors.coverBackdropBase;

    return Color.alphaBlend(
      backdropTints.first.withValues(alpha: strength),
      AppColors.coverBackdropBase,
    );
  }

  /// Üstteki sabit, şeffaf başlık çubuğu. Geri butonu ve yalnızca sayfadaki başlık
  /// buraya ulaştığında beliren ortalanmış başlık içerir.
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
                  icons: const [AppIcons.share],
                  onIconTap: (_) => onSharePressed(),
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

  /// Kapak kare: etkinlik afişleri genelde kare ya da dikey hazırlanıyor,
  /// yatay bir kutuda çoğu kırpılıyor.
  double _coverSize(BuildContext context) =>
      MediaQuery.sizeOf(context).width -
      (AppPaddings.mainPaddingHorizontal.left * 2);

  /// Kapak görseli kaydırıldıkça üst iki köşesi ve yeri sabit kalır, yüksekliği
  /// büzülerek küçülür.
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
            child: CoverImage(imageUrl: event.coverImageUrl),
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
        top: AppSizes.bigSpace + _coverSize(context) + AppSizes.sectionSpace,
        bottom: AppSizes.navBarClearance,
      ),
      children: [
        _title(context),
        if (event.typeName.isNotEmpty) ...[
          const SizedBox(height: AppSizes.midSpace),
          _typeRow(context),
        ],
        const SizedBox(height: AppSizes.sectionSpace),
        _dateBlock(context),
        const SizedBox(height: AppSizes.bigSpace),
        _statusRow(context),
        // Bölüm başlıklarının kendi üst boşluğu var (AppPaddings.sectionHeader),
        // araya ayrıca boşluk konmuyor; altındaki ayraçtan sonrası ayrı.
        if (event.location.isNotEmpty) ...[
          _sectionHeader(context, 'Konum'),
          const SizedBox(height: AppSizes.bigSpace),
          _infoBlock(context, icon: AppIcons.location, title: event.location),
        ],
        _sectionHeader(context, 'Etkinlik Hakkında'),
        const SizedBox(height: AppSizes.bigSpace),
        _description(context),
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

  /// Etkinlik türü, başlığın hemen altında ince bir satır olarak.
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
            event.typeName,
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

  /// Tarih ve saat: üstte gün, altında saat aralığı.
  Widget _dateBlock(BuildContext context) {
    return _infoBlock(
      context,
      icon: AppIcons.calendar,
      title: event.formattedDayLabel,
      subtitle: event.formattedTimeRange,
    );
  }

  /// Başvurunun açık olup olmadığı; katılım butonunun sayfa içindeki
  /// karşılığı, kullanıcının aşağı inmeden görmesi için.
  Widget _statusRow(BuildContext context) {
    final open = event.active;

    return Row(
      children: [
        AppIcon(
          open ? AppIcons.checkCircle : AppIcons.clock,
          size: AppSizes.iconMedium,
          color: open ? AppColors.green : AppColors.orange,
        ),
        const SizedBox(width: AppSizes.bigSpace),
        Text(
          open ? 'Başvurular açık' : 'Başvurular henüz açılmadı',
          style: context.textTheme.bodyLarge?.copyWith(
            color: open ? AppColors.green : AppColors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// İkon + iki katlı metin: üstte asıl bilgi, altında onu tamamlayan
  /// ikincil satır.
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

  /// Bölüm başlığı: ayarlar sayfasındaki biçimin aynısı (boşluk, kademe,
  /// ağırlık), altında bir de ayraç. Rengi farklı, çünkü bu sayfanın zemini
  /// temadan bağımsız koyu.
  Widget _sectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppPaddings.sectionHeader,
          child: Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onCoverFaint,
            ),
          ),
        ),
        Divider(color: AppColors.onCoverDivider, height: 1),
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

  /// Katılım butonu sayfanın altında sabit duruyor; açıklama uzun olduğunda
  /// kullanıcının sonuna kadar kaydırması gerekmesin diye.
  ///
  /// Renkleri açıkça veriliyor: butonun varsayılanları temaya bağlı, sayfa
  /// ise temadan bağımsız koyu.
  Widget _joinBar(BuildContext context) {
    final enabled = event.active;

    return SafeArea(
      minimum: AppPaddings.mainPaddingAll,
      child: SkyButton(
        text: joinButtonLabel,
        isLoading: isJoining,
        // Pasif zemin opak: yarı saydam bırakılınca altındaki renkli zemin
        // sızıyor ve buton silik değil, delik gibi görünüyor.
        backgroundColor: enabled
            ? AppColors.primaryColor
            : Color.alphaBlend(AppColors.onCoverSurface, _tinted(_scrimTint)),
        textColor: enabled
            ? AppColors.skyPassForeground
            : AppColors.onCoverFaint,
        // Başvuruya kapalı etkinlikte buton pasif kalıyor.
        onPressed: enabled ? onJoinPressed : null,
      ),
    );
  }
}
