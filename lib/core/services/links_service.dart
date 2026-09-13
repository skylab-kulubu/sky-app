import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/models/link_item.dart';

class LinksService {
  /// Kulübün ana web sitesi. Hem [groups] içinde hem de ayarlar sayfasından
  /// doğrudan kullanıldığı için ayrıca isimlendirildi.
  static const LinkItem website = LinkItem(
    name: 'SKY LAB',
    description: 'Resmi web sitesi',
    icon: AppIcons.browser,
    color: AppColors.primaryStrong,
    url: 'https://yildizskylab.com',
  );

  /// Kulüp menüsündeki bağlantılar, menüde görünecekleri sırayla.
  static const List<LinkGroup> groups = [
    LinkGroup(
      title: 'Genel',
      links: [
        website,
        LinkItem(
          name: 'Ekipler',
          description: 'Kulüp ekiplerini keşfet',
          icon: AppIcons.users2,
          color: AppColors.blue,
          url: 'https://arge.yildizskylab.com/',
        ),
        LinkItem(
          name: 'SKYSEC Articles',
          description: 'Siber güvenlik makaleleri ve yazılar',
          icon: AppIcons.securityArticles,
          color: AppColors.orange,
          url: 'https://skysec.yildizskylab.com',
        ),
        LinkItem(
          name: 'Stant',
          description: 'Kulüp stant ve tanıtım etkinlikleri',
          icon: AppIcons.stand,
          color: AppColors.darkPurple,
          url: 'https://stant.yildizskylab.com',
        ),
      ],
    ),
    LinkGroup(
      title: 'Araçlar',
      links: [
        LinkItem(
          name: 'SKYFORMS',
          description: 'Kulüp anket ve form platformu',
          icon: AppIcons.form,
          color: AppColors.purple,
          url: 'https://forms.yildizskylab.com',
        ),
        LinkItem(
          name: 'SKYCLOUD',
          description: 'Kulüp dosya paylaşım ve depolama sistemi',
          icon: AppIcons.cloud,
          color: AppColors.secondaryBlue,
          url: 'https://cloud.yildizskylab.com',
        ),
        LinkItem(
          name: 'SKYLAPP',
          description: 'Kulüp link kısaltma servisi',
          icon: AppIcons.shortLink,
          color: AppColors.pink,
          url: 'https://skylapp.yildizskylab.com/',
        ),
      ],
    ),
    LinkGroup(
      title: 'Oyunlar',
      links: [
        LinkItem(
          name: 'YıldızPlace',
          description: 'YTÜ kampüs haritası ve mekan rehberi',
          icon: AppIcons.campusMap,
          color: AppColors.red,
          url: 'https://place.yildizskylab.com',
        ),
        LinkItem(
          name: 'YTUGuessr',
          description: 'YTÜ kampüsünü keşfet, konumu tahmin et',
          icon: AppIcons.game,
          color: AppColors.green,
          url: 'https://guessr.yildizskylab.com',
        ),
      ],
    ),
    LinkGroup(
      title: 'Durum',
      links: [
        LinkItem(
          name: 'Sky Lab Oda',
          description: 'Kulüp odasının anlık açık/kapalı durumu',
          icon: AppIcons.room,
          color: AppColors.teal,
          url: 'https://oda.yildizskylab.com',
        ),
        LinkItem(
          name: 'Sky Lab Sunucu',
          description: 'Sunucu ve servis erişilebilirlik durumu',
          icon: AppIcons.server,
          color: AppColors.darkOrange,
          url: 'https://status.yildizskylab.com',
        ),
      ],
    ),
  ];
}
