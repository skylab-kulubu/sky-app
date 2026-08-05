import 'package:sky_app/features/home/data/models/news_item.dart';

class NewsService {
  static const List<NewsItem> list = [
    NewsItem(
      imageUrl: 'assets/images/yildizJam.jpeg',
      title: 'YILDIZ JAM: Oyun Geliştirme Zirvesi',
      description:
          '''Yıldız Teknik Üniversitesi SKY LAB tarafından düzenlenen YILDIZ JAM, bu yıl da oyun geliştirme tutkunlarını bir araya getiriyor!

📍 YTÜ Davutpaşa Kampüsü
📅 8-9-10 Mayıs

Etkinliğin ilk gününde, oyun geliştirme sektöründen uzman isimlerle bir araya gelerek ilham verici oturumlara katılma fırsatı yakalayacak; fuaye alanında yer alan stantlar, deneyim alanları ve Indie Oyun Alanı ile dolu dolu bir gün geçireceksiniz.

Zirvenin ardından başlayacak olan game jam süresince katılımcılar, etkinlik anında açıklanacak tema doğrultusunda ekipler halinde kendi oyunlarını geliştireceklerdir.

🎯 Ödüller ve yarışmaya dair detaylı bilgiler ilerleyen günlerde açıklanacaktır.''',
    ),
    NewsItem(
      imageUrl: 'assets/images/algolab.jpeg',
      title: 'ALGOLAB Ekip Alımları Açıldı',
      description:
          '''Algolab, algoritma ve rekabetçi programlama alanında kendini geliştirmek isteyenler için aktif bir çalışma topluluğudur.

Ekibimizde:
* Algoritma bilgisini derinleştirmeye yönelik düzenli çalışmalar yapılır.
* Problem çözme becerilerini geliştiren içerikler paylaşılır.
* Haftalık düzenlenen AGC yarışmaları ile rekabetçi ortamda pratik kazanılır.

Birlikte öğrenmeye, takım içinde gelişmeye ve algoritma konusunda kendini sürekli ileri taşımaya odaklanıyoruz.

Merak eden, araştıran ve düzenli şekilde kendini geliştirmek isteyen ekip arkadaşları arıyoruz.''',
    ),
    NewsItem(
      imageUrl:
          'https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?auto=format&fit=crop&w=600&q=80',
      title: 'SKY LAB AI & Data Science Bootcamp Başlıyor!',
      description:
          '''Yapay zeka ve veri bilimi dünyasına adım atmaya hazır mısınız? 

SKY LAB Veri Bilimi Ekibi öncülüğünde düzenlenen 6 haftalık yoğun Bootcamp programımız başlıyor. Python, Makine Öğrenmesi, Derin Öğrenme ve Doğal Dil İşleme (NLP) konularını uygulamalı projelerle öğreneceğiz.

📍 Yıldız Teknik Üniversitesi - Tarihi Hamam Salonu
📅 Başlangıç: 15 Ekim
⏱️ Kontenjan sınırlıdır!

Eğitim sonunda başarılı olan katılımcılara SKY LAB onaylı Başarı Sertifikası verilecektir.''',
    ),
    NewsItem(
      imageUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=600&q=80',
      title: 'HackYTÜ 2026: 36 Saatlik Kesintisiz Hackathon',
      description:
          '''Türkiye'nin en büyük öğrenci hackathonlarından biri olan HackYTÜ için geri sayım başladı!

36 saat boyunca kesintisiz kodlama, mentor desteği, sınırsız kahve ve dev ödüller seni bekliyor. Yazılım, tasarım ve iş geliştirme alanındaki yeteneklerini sergilemek için takımını kur ve başvurunu yap.

🏆 Toplam Ödül Havuzu: 150.000 TL
📍 Davutpaşa Kampüsü Yemekhane Binası
📅 22-23 Kasım''',
    ),
    NewsItem(
      imageUrl:
          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80',
      title: 'Siber Güvenlik Çalıştayı ve CTF Yarışması',
      description:
          '''SKY LAB Siber Güvenlik Ekibi tarafından organize edilen Siber Güvenlik Çalıştayı ile siber savunma ve sızma testi tekniklerini öğrenin!

Çalıştayın ardından gerçekleşecek Jeopardy tarzı Capture The Flag (CTF) yarışmasında bayrakları toplamak için kıyasıya bir mücadele vereceğiz.

* Web Güvenliği & Kriptoloji
* Tersine Mühendislik & Adli Bilişim (Forensics)
* Ağ Güvenliği ve Zafiyet Analizi

📅 5 Aralık Cumartesi | 10:00 - 18:00
📍 Elektrik-Elektronik Fakültesi Konferans Salonu''',
    ),
    NewsItem(
      imageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=600&q=80',
      title: 'Mobil Uygulama Geliştirme (Flutter) Atölyesi',
      description:
          '''Flutter ile tek kod tabanı üzerinden hem iOS hem Android için modern mobil uygulamalar geliştirmeyi öğreniyoruz.

SKY LAB Mobil Ekibi tarafından verilecek bu ücretsiz eğitimde State Management (Provider/Bloc), REST API entegrasyonu ve UI/UX prensiplerini gerçek bir proje üzerinde deneyimleyeceğiz.

💻 Kendi bilgisayarınızla katılmanız gerekmektedir.
📅 18 Aralık Çarşamba | 17:30
📍 Bilgisayar Mühendisliği Amfisi''',
    ),
  ];
}
