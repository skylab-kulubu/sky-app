import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/section_header.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/core/widgets/user_avatar.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';
import 'package:sky_app/features/settings/presentation/widgets/account_info_tile.dart';

/// Hesap sayfası: üstte profil kimliği (avatar, ad, kullanıcı adı, ekipler),
/// altında hesabın kayıtlı bilgileri.
///
/// Bilgiler üyelik kaydından geliyor ve uygulama içinden düzenlenmiyor; bu
/// yüzden satırlar salt okunur, yalnızca dışarı açılanlar dokunulabilir.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Ayarları'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(AppIcons.arrowBack),
        ),
      ),
      // Çıkışta kullanıcı temizleniyor ve sayfa aynı karede yeniden çiziliyor;
      // `/auth`'a yönlendirme ancak bir sonraki karede oluyor. O kare boyunca
      // çizilecek veri yok.
      body: user == null ? const SizedBox.shrink() : _body(context, user),
    );
  }

  Widget _body(BuildContext context, User user) {
    return ListView(
      padding: AppPaddings.mainPaddingAll,
      children: [
        _header(context, user),
        ..._section(context, 'Temel Bilgiler', _basicRows(user)),
        ..._section(context, 'Eğitim', _educationRows(user)),
        ..._section(context, 'Bağlantılar', _linkRows(context, user)),
        _note(context),
      ],
    );
  }

  /// Başlık + kart ikilisi. Satırı olmayan bölüm hiç çizilmez: alanların bir
  /// kısmı profil API'sinden geliyor ve boş gelebiliyor.
  List<Widget> _section(BuildContext context, String title, List<Widget> rows) {
    if (rows.isEmpty) return const [];

    return [
      SectionHeader(title),
      TileGroup(dividerIndent: AppSizes.dividerIndent, children: rows),
    ];
  }

  Widget _header(BuildContext context, User user) {
    return Padding(
      padding: AppPaddings.accountHeader,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            name: user.name,
            imageUrl: user.profilePictureUrl,
            size: AppSizes.accountAvatar,
          ),
          const SizedBox(height: AppSizes.bigSpace),
          Text(
            user.name,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          if (user.usernameDisplay.isNotEmpty)
            Text(
              user.usernameDisplay,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.textSecondary,
              ),
            ),
          if (user.teams.isNotEmpty) ...[
            const SizedBox(height: AppSizes.bigSpace),
            Wrap(
              spacing: AppSizes.midSpace,
              runSpacing: AppSizes.midSpace,
              children: [
                for (final team in user.teams) _teamChip(context, team),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _teamChip(BuildContext context, String team) {
    return Container(
      padding: AppPaddings.teamChip,
      decoration: BoxDecoration(
        color: context.elevatedColor,
        borderRadius: AppRadiuses.stadiumBorderRadius,
      ),
      child: Text(
        team,
        style: context.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.textSecondary,
        ),
      ),
    );
  }

  List<Widget> _basicRows(User user) {
    return [
      if (user.email.isNotEmpty)
        AccountInfoTile(
          label: 'E-posta',
          value: user.email,
          verified: user.emailVerified,
        ),
      if (user.schoolEmail.isNotEmpty)
        AccountInfoTile(label: 'Okul E-postası', value: user.schoolEmail),
      if (user.usernameDisplay.isNotEmpty)
        AccountInfoTile(label: 'Kullanıcı Adı', value: user.usernameDisplay),
      if (user.skyNumber.isNotEmpty)
        AccountInfoTile(label: 'SKY Numarası', value: user.skyNumber),
    ];
  }

  List<Widget> _educationRows(User user) {
    return [
      if (user.university.isNotEmpty)
        AccountInfoTile(label: 'Üniversite', value: user.university),
      if (user.faculty.isNotEmpty)
        AccountInfoTile(label: 'Fakülte', value: user.faculty),
      if (user.department.isNotEmpty)
        AccountInfoTile(label: 'Bölüm', value: user.department),
    ];
  }

  List<Widget> _linkRows(BuildContext context, User user) {
    return [
      if (user.linkedin.isNotEmpty)
        AccountInfoTile(
          label: 'LinkedIn',
          value: _handleOf(user.linkedin),
          trailingIcon: AppIcons.externalLink,
          onTap: () => _onLinkedinTap(context, user.linkedin),
        ),
    ];
  }

  /// Bağlantının yalnızca kullanıcı kısmı. Tam URL satırın sağ yarısına
  /// sığmıyor ve okunacak bilgi zaten sondaki isim.
  String _handleOf(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return url;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty);
    return segments.isEmpty ? uri.host : segments.last;
  }

  void _onLinkedinTap(BuildContext context, String url) {
    WebviewService.openLink(
      context,
      LinkItem(
        name: 'LinkedIn',
        description: '',
        iconPath: AppAssets.link,
        color: AppColors.blue,
        // Kayıt şemasız gelebiliyor; `Uri.parse` o hâlde bunu göreli yol
        // sayar ve webview boş açılır.
        url: url.startsWith('http') ? url : 'https://$url',
      ),
    );
  }

  Widget _note(BuildContext context) {
    return Padding(
      padding: AppPaddings.accountNote,
      child: Text(
        'Hesap bilgilerin SKY LAB üyelik kaydından geliyor ve uygulama '
        'içinden değiştirilemiyor. Bir bilgi eksik ya da yanlışsa Ayarlar → '
        'Destek ile İletişime Geç üzerinden bize yaz.',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.textTertiary,
        ),
      ),
    );
  }
}
