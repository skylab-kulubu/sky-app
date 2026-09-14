import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/app_bar_actions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/cover_image.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/core/widgets/user_avatar.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/data/models/team_member.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/team/data/services/team_service.dart';
import 'package:sky_app/features/team/presentation/pages/team_edit/team_edit_page.dart';
import 'package:sky_app/features/team/presentation/providers/team_provider.dart';
import 'package:sky_app/features/team/presentation/widgets/team_logo.dart';
import 'package:sky_app/features/team/presentation/widgets/team_logo_hero.dart';
import 'package:sky_app/features/team/presentation/widgets/team_tag_chip.dart';

part 'team_detail_pagemodel.dart';

/// Ekibin ayrıntıları: logo, hakkında, konular, teknolojiler, çalışmalar ve
/// herkese açıksa üyeler. Altta, ekip üye alıyorsa başvuru formunu açan
/// "Ekibe Katıl".
///
/// Yerleşim ve geçiş etkinlik detayıyla aynı: kartın logosu [Hero] ile
/// sayfanın kapağına uçuyor, kapak kaydırdıkça küçülüyor, ad üst çubukta
/// beliriyor. Farkı zemin; burada logodan renk türetilmiyor, sayfa temanın
/// düz zemininde duruyor.
///
/// Boş bölümler hiç çizilmiyor: CMS'te çoğu ekip yalnızca kısa açıklamayı
/// doldurmuş durumda.
class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({super.key, required this.team});

  final Team team;

  static const Duration _openDuration = Duration(milliseconds: 450);
  static const Duration _closeDuration = Duration(milliseconds: 350);

  /// Sayfayı carousel'deki karttan açar. Kök navigator: yoksa sayfa navbar'ın
  /// altında kalıyor.
  static Future<void> open(BuildContext context, Team team) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: _openDuration,
        reverseTransitionDuration: _closeDuration,
        pageBuilder: (_, _, _) => TeamDetailPage(team: team),
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
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends TeamDetailPagemodel {
  static const double _bodyLineHeight = 1.6;
  static const double _workLineHeight = 1.45;
  static const double _memberAvatarSize = 40;

  /// Çubuktaki başlığın belirmeye başladığı kaydırma mesafesi (kapağın
  /// altından itibaren) ve tamamen görünür olana kadar geçen mesafe.
  static const double _headingRevealOffset = 36.0;
  static const double _headingRevealDistance = 40.0;

  /// Kapaktaki logonun kapak kenarına göre iç boşluğu.
  static const double _logoInsetFactor = 0.2;

  double get _scrollOffset =>
      scrollController.hasClients ? scrollController.offset : 0.0;

  @override
  Widget build(BuildContext context) {
    // İçerik butonun arkasına uzanmıyor, üstünde bitiyor (düzenleme
    // sayfasıyla aynı). Arkasına uzandığında son satırlar karartmanın
    // altında kalıyor ve liste sonunda büyük bir boşluk gerekiyordu.
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          _topHeader(context),
          Expanded(
            child: Stack(children: [_pinnedCover(context), _content(context)]),
          ),
        ],
      ),
      bottomNavigationBar: _joinBar(),
    );
  }

  /// Üstte sabit çubuk: geri butonu ve sayfadaki ad buraya ulaşınca beliren
  /// ortalanmış başlık. Sağda paylaş yok; başlık ortada kalsın diye geri
  /// butonu kadar boşluk bırakılıyor.
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
                ),
              ),
            ),
            gap,
            Expanded(
              child: AnimatedBuilder(
                animation: scrollController,
                child: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                builder: (context, child) {
                  final threshold = _coverSize(context) + _headingRevealOffset;
                  final opacity =
                      ((_scrollOffset - threshold) / _headingRevealDistance)
                          .clamp(0.0, 1.0);
                  return Opacity(opacity: opacity, child: child);
                },
              ),
            ),
            gap,
            // Liderlere düzenleme; diğerlerinde aynı genişlikte boşluk,
            // başlık ortada kalsın.
            Padding(
              padding: AppPaddings.appBarActions,
              child: canEdit
                  ? Center(
                      child: AppBarActions(
                        icons: const [AppIcons.edit],
                        onIconTap: (_) => onEditPressed(),
                      ),
                    )
                  : SizedBox(width: AppBarActions.widthFor(1)),
            ),
          ],
        ),
      ),
    );
  }

  double _coverSize(BuildContext context) =>
      MediaQuery.sizeOf(context).width -
      (AppPaddings.mainPaddingHorizontal.left * 2);

  /// Kare kapak; kaydırıldıkça yeri sabit kalıp yüksekliği büzülüyor.
  Widget _pinnedCover(BuildContext context) {
    final coverSize = _coverSize(context);

    return Positioned(
      top: AppSizes.bigSpace,
      left: AppPaddings.mainPaddingHorizontal.left,
      right: AppPaddings.mainPaddingHorizontal.right,
      child: AnimatedBuilder(
        animation: scrollController,
        child: TeamLogoHero(
          slug: team.slug,
          child: ClipRRect(
            borderRadius: AppRadiuses.cardBorderRadius,
            // Karttaki logo alanıyla aynı zemin; Hero uçuşunda renk
            // değişmesin.
            child: ColoredBox(
              color: context.elevatedColor,
              // Logo, kapak büzülürken küçülmesin: çizim alanı kapağın o anki
              // yüksekliğine değil genişliğine göre kare tutuluyor, taşan
              // kısım ortadan kırpılıyor. Genişlik kaydırmada sabit, Hero
              // uçuşunda ise kutuyla birlikte büyüyor.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final side = constraints.maxWidth;
                  return OverflowBox(
                    minHeight: side,
                    maxHeight: side,
                    child: Padding(
                      padding: EdgeInsets.all(side * _logoInsetFactor),
                      child: TeamLogo(team: team),
                    ),
                  );
                },
              ),
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
        // Kapağın altındaki boşluk üstündekiyle aynı; etkinlik detayındaki
        // gibi büyük bırakıldığında ad kapaktan kopuk, çok aşağıda duruyordu.
        top: AppSizes.bigSpace + _coverSize(context) + AppSizes.bigSpace,
        bottom: AppPaddings.mainPaddingAll.bottom,
      ),
      children: [
        Text(
          team.name,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Bölüm başlıklarının kendi üst boşluğu ve altında ayraç var; araya
        // ayrıca boşluk konmuyor.
        if (team.aboutText.isNotEmpty) ...[
          _sectionHeader(context, 'Hakkında'),
          _body(context, team.aboutText),
        ],
        if (team.topics.isNotEmpty) ...[
          _sectionHeader(context, 'Konular'),
          _tags(team.topics),
        ],
        if (team.stack.isNotEmpty) ...[
          _sectionHeader(context, 'Teknolojiler'),
          _tags(team.stack),
        ],
        if (team.works.isNotEmpty) ...[
          _sectionHeader(context, 'Çalışmalar'),
          for (final work in team.works) ...[
            _work(context, work),
            if (work != team.works.last)
              const SizedBox(height: AppSizes.bigSpace),
          ],
        ],
        ..._members(context),
      ],
    );
  }

  /// Bölüm başlığı: etkinlik detayındakiyle aynı biçim (boşluk, kademe,
  /// ağırlık, altında ayraç). Renkleri temadan; o sayfanın zemini temadan
  /// bağımsız koyu, bu sayfanınki değil.
  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.bigSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppPaddings.sectionHeader,
            child: Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textTertiary,
              ),
            ),
          ),
          Divider(color: context.dividerColor, height: 1),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.textSecondary,
        height: _bodyLineHeight,
      ),
    );
  }

  Widget _tags(List<String> tags) {
    return Wrap(
      spacing: AppSizes.midSpace,
      runSpacing: AppSizes.midSpace,
      children: [for (final tag in tags) TeamTagChip(label: tag)],
    );
  }

  /// Çalışma kartı: varsa görsel, altında başlık, açıklama ve etiketler.
  Widget _work(BuildContext context, TeamWork work) {
    return Container(
      padding: AppPaddings.eventCard,
      decoration: BoxDecoration(
        color: context.tileColor,
        borderRadius: AppRadiuses.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (work.image.isNotEmpty)
            AspectRatio(
              aspectRatio: AppSizes.eventCoverAspect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadiuses.innerTile),
                child: CoverImage(imageUrl: work.image),
              ),
            ),
          Padding(
            // İçerik boşluğunun üst payı görselle metin arası için; görsel
            // yoksa üstte fazladan boşluk bırakıyordu, alt payla eşitleniyor.
            padding: work.image.isNotEmpty
                ? AppPaddings.eventCardContent
                : AppPaddings.eventCardContent.copyWith(
                    top: AppPaddings.eventCardContent.bottom,
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (work.description.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.midSpace),
                  Text(
                    work.description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                      height: _workLineHeight,
                    ),
                  ),
                ],
                if (work.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.bigSpace),
                  _tags(work.tags),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Üyeler bölümü. Yüklenirken ya da ekip herkese açık değilse (boş liste)
  /// bölüm hiç görünmüyor; yükleniyor göstergesi koymak, çoğu ekipte hiç
  /// gelmeyecek bir bölümü vaat etmek olurdu.
  List<Widget> _members(BuildContext context) {
    if (members.isEmpty) return const [];

    return [
      _sectionHeader(context, 'Üyeler · ${members.length}'),
      TileGroup(
        children: [for (final member in members) _member(context, member)],
      ),
    ];
  }

  Widget _member(BuildContext context, TeamMember member) {
    final hasLinkedin = member.linkedinUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasLinkedin ? () => onMemberTap(member) : null,
        child: Padding(
          padding: AppPaddings.settingsTile,
          child: Row(
            children: [
              UserAvatar(
                name: member.name,
                imageUrl: member.profilePictureUrl,
                size: _memberAvatarSize,
              ),
              const SizedBox(width: AppSizes.bigSpace),
              Expanded(child: _memberTexts(context, member)),
              if (hasLinkedin)
                AppIcon(
                  AppIcons.linkedin,
                  size: AppSizes.iconSmall,
                  color: context.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberTexts(BuildContext context, TeamMember member) {
    final subtitle = [
      if (member.isLeader) 'Lider',
      if (member.department.isNotEmpty) member.department,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          member.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: member.isLeader
                  ? context.accentColor
                  : context.textSecondary,
            ),
          ),
      ],
    );
  }

  /// Katılım butonu altta sabit. Ekip üye alıyorsa başvuru formunu açıyor;
  /// almıyorsa pasif ve "Başvurular Kapalı" yazıyor.
  Widget _joinBar() {
    final recruiting = team.isRecruiting;

    return SafeArea(
      minimum: AppPaddings.mainPaddingAll,
      child: SkyButton(
        text: recruiting ? 'Ekibe Katıl' : 'Başvurular Kapalı',
        onPressed: recruiting ? onJoinPressed : null,
      ),
    );
  }
}
