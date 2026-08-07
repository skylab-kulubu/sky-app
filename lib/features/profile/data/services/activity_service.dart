import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/features/profile/data/models/activity.dart';

/// Kullanıcının son aktiviteleri. [NewsService] gibi **mock**: API'de
/// katılım/aktivite geçmişi henüz yok.
///
/// Tarihler sabit değil, "şu andan şu kadar önce" diye kuruluyor; sabit
/// tarihler verilseydi liste birkaç ay sonra "2 yıl önce" demeye başlardı.
class ActivityService {
  static final List<Activity> list = [
    Activity(
      title: 'Flutter Bootcamp 2025',
      description: 'Eğitimi tamamladın, sertifikan hesabına tanımlandı.',
      icon: AppIcons.certificate,
      color: AppColors.blue,
      dateTime: _daysAgo(3),
    ),
    Activity(
      title: 'YILDIZ JAM',
      description: 'Etkinliğe kaydoldun. Takımını kurmayı unutma.',
      icon: AppIcons.calendar,
      color: AppColors.orange,
      dateTime: _daysAgo(9),
    ),
    Activity(
      title: 'AGC #12',
      description: 'Haftalık algoritma yarışmasını tamamladın.',
      icon: AppIcons.medal,
      color: AppColors.purple,
      dateTime: _daysAgo(21),
    ),
    Activity(
      title: 'MOBILAB',
      description: 'Ekibe katıldın.',
      icon: AppIcons.users2,
      color: AppColors.green,
      dateTime: _daysAgo(46),
    ),
  ];

  static DateTime _daysAgo(int days) =>
      DateTime.now().subtract(Duration(days: days));
}
