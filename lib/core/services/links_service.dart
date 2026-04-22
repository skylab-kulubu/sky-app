import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/models/link_item.dart';

class LinksService {
  static const List<LinkItem> list = [
    LinkItem(
      name: 'SKY LAB',
      description: 'SKY LAB resmi web sitesi',
      iconPath: AppAssets.skylab,
      color: AppColors.primaryColor,
      url: 'https://yildizskylab.com',
    ),
    LinkItem(
      name: 'YıldızPlace',
      description: 'YTÜ kampüs haritası ve mekan rehberi',
      iconPath: AppAssets.ytuPlace,
      color: AppColors.red,
      url: 'https://place.yildizskylab.com',
    ),
    LinkItem(
      name: 'YTUGuessr',
      description: 'YTÜ kampüsünü keşfet, konumu tahmin et',
      iconPath: AppAssets.ytuGuessr,
      color: AppColors.green,
      url: 'https://guessr.yildizskylab.com',
    ),
    LinkItem(
      name: 'SKYCLOUD',
      description: 'Kulüp dosya paylaşım ve depolama sistemi',
      iconPath: AppAssets.skycloud,
      color: AppColors.teal,
      url: 'https://cloud.yildizskylab.com',
    ),
    LinkItem(
      name: 'SKYFORMS',
      description: 'Kulüp anket ve form platformu',
      iconPath: AppAssets.skyforms,
      color: AppColors.purple,
      url: 'https://forms.yildizskylab.com',
    ),
    LinkItem(
      name: 'SKYSEC Articles',
      description: 'Siber güvenlik makaleleri ve yazılar',
      iconPath: AppAssets.skysec,
      color: AppColors.orange,
      url: 'https://skysec.yildizskylab.com',
    ),
    LinkItem(
      name: 'Sky Lab Oda',
      description: 'Kulüp odasının anlık açık/kapalı durumu',
      iconPath: AppAssets.skylabRoom,
      color: AppColors.teal,
      url: 'https://oda.yildizskylab.com',
    ),
    LinkItem(
      name: 'Sky Lab Sunucu',
      description: 'Sunucu ve servis erişilebilirlik durumu',
      iconPath: AppAssets.skylabServer,
      color: AppColors.orange,
      url: 'https://status.yildizskylab.com',
    ),
    LinkItem(
      name: 'SKYPDF',
      description: 'PDF dönüştürme ve düzenleme aracı',
      iconPath: AppAssets.skypdf,
      color: AppColors.pink,
      url: 'https://pdf.yildizskylab.com',
    ),
    LinkItem(
      name: 'Stant',
      description: 'Kulüp stant ve tanıtım etkinlikleri',
      iconPath: AppAssets.skystant,
      color: AppColors.darkPurple,
      url: 'https://stant.yildizskylab.com',
    ),
  ];
}
