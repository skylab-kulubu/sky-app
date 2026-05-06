import 'package:sky_app/features/home/data/models/announcement_model.dart';

// final _allShortcuts = LinksService.list;
final carouselItems = AnnouncementService.list;

class AnnouncementService {
  static final List<AnnouncementModel> list = [
    AnnouncementModel(
      image: 'assets/images/yildizJam.jpeg',
      title: '🚀 YILDIZ JAM: Oyun Geliştirme Zirvesi ',
      subtitle:
          '''Yıldız Teknik Üniversitesi SKY LAB tarafından düzenlenen YILDIZ JAM, bu yıl da oyun geliştirme tutkunlarını bir araya getiriyor!

📍 YTÜ Davutpaşa Kampüsü
📅 8-9-10 Mayıs

Etkinliğin ilk gününde, oyun geliştirme sektöründen uzman isimlerle bir araya gelerek ilham verici oturumlara katılma fırsatı yakalayacak; fuaye alanında yer alan stantlar, deneyim alanları ve Indie Oyun Alanı ile dolu dolu bir gün geçireceksiniz.

Zirvenin ardından başlayacak olan game jam süresince katılımcılar, etkinlik anında açıklanacak tema doğrultusunda ekipler halinde kendi oyunlarını geliştireceklerdir.

🎯 Ödüller ve yarışmaya dair detaylı bilgiler ilerleyen günlerde açıklanacaktır. ''',
    ),

    AnnouncementModel(
      image: 'assets/images/algolab.jpeg',
      title: 'ALLGOLAB!!',
      subtitle:
          '''Algolab, algoritma ve rekabetçi programlama alanında kendini geliştirmek isteyenler için aktif bir çalışma topluluğudur.

Ekibimizde:
* Algoritma bilgisini derinleştirmeye yönelik düzenli çalışmalar yapılır.
* Problem çözme becerilerini geliştiren içerikler paylaşılır.
* Haftalık düzenlenen AGC yarışmaları ile rekabetçi ortamda pratik kazanılır.

Birlikte öğrenmeye, takım içinde gelişmeye ve algoritma konusunda kendini sürekli ileri taşımaya odaklanıyoruz.

Merak eden, araştıran ve düzenli şekilde kendini geliştirmek isteyen ekip arkadaşları arıyoruz.''',
    ),
  ];
}
