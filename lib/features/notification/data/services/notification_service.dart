import 'package:sky_app/features/notification/data/models/notification_model.dart';

int numberOfNotifications = notifications.length;

List<NotificationModel> notifications = [
  NotificationModel(
    title: "Flutter & Firebase Atölyesi Başlıyor",
    description:
        "Canlı yayın linki e-posta adresinize gönderildi. Atölye 10 dakika içinde başlayacak, yerinizi alın!",
    content:
        "Değerli katılımcımız, Flutter ve Firebase kullanarak uçtan uca bir mobil uygulama geliştireceğimiz atölye çalışmamız başlamak üzere. Eğitmenimiz, state management (durum yönetimi) ve NoSQL veritabanı modelleme konularına pratik örneklerle değinecek. Lütfen yayın sırasında mikrofonunuzun kapalı olduğundan emin olun ve sorularınızı chat ekranından iletin. Ayrıca ders sonunda kaynak kodlar GitHub üzerinden paylaşılacaktır.",
    // isRead parametresini vermedik, otomatik olarak false kabul edilecek.
    dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  NotificationModel(
    title: "Tanışma Toplantısı",
    description:
        "Kulübümüzün güz dönemi tanışma etkinliği konferans salonunda başlıyor. Yoklama alınacaktır.",
    content:
        "Yeni döneme harika bir başlangıç yapıyoruz! Kulübümüzün vizyonunu, bu dönem gerçekleştireceğimiz etkinlikleri ve teknik ekiplerimize nasıl katılabileceğinizi anlatacağımız tanışma toplantısı başladı. Hem yeni arkadaşlarla tanışmak hem de projelerimizde aktif görev almak için bu fırsatı kaçırmayın. Toplantı sonunda sürpriz çekilişlerimiz ve ikramlarımız da olacak. Lütfen girişte QR kodunuzu okutmayı unutmayın.",
    dateTime: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  NotificationModel(
    title: "AWS Bulut Kredileri Yüklendi",
    description:
        "Projeniz için talep ettiğiniz 100\$ değerindeki AWS kredisi hesabınıza tanımlanmıştır.",
    content:
        "Bulut bilişim mimarisi dersi kapsamındaki projeniz için talep ettiğiniz AWS Educate kredileri onaylandı. 100\$ değerindeki bu krediyi EC2, S3 ve RDS gibi temel servisleri gerçek dünya senaryolarında deneyimlemek için kullanabilirsiniz. Kredilerin son kullanım tarihi dönem sonudur. Lütfen gereksiz yere çalışan sunucularınızı (instance) kapatmayı unutmayın, aksi takdirde krediniz beklenenden çok daha hızlı tükenebilir.",
    isRead: true, // Varsayılan değeri ezip true yapıyoruz.
    dateTime: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  NotificationModel(
    title: "Siber Güvenlik Semineri",
    description:
        "Siber güvenlik alanındaki son trendlerin konuşulacağı seminer için kaydınız başarıyla onaylandı.",
    content:
        "Seminer kaydınız başarıyla alınmıştır. Etkinliğimizde sızma testleri (penetration testing), sosyal mühendislik saldırıları ve güvenli yazılım geliştirme yaşam döngüsü (SDLC) üzerine konuşacağız. Sektörden uzman konuklarımızın katılacağı bu etkinlikte, gerçek dünya senaryoları üzerinden canlı ağ analizi demoları da yapılacaktır. Etkinlik sonunda tüm katılımcılara dijital katılım belgesi verilecektir.",
    isRead: true,
    dateTime: DateTime.now().subtract(const Duration(hours: 14)),
  ),
  NotificationModel(
    title: "Algoritma Takımı Seçmeleri",
    description:
        "Mülakat sonuçları açıklandı! Sonuçları görmek için portalımıza giriş yapabilirsiniz.",
    content:
        "Algoritma takımı mülakatları ve teknik test aşamaları tamamlandı. Katılımınız ve emeğiniz için teşekkür ederiz. Değerlendirme sürecinde veri yapıları (Data Structures), zaman karmaşıklığı (Time Complexity) hesaplamaları ve problem çözme yaklaşımlarınız incelendi. Detaylı teknik geri bildiriminizi ve nihai mülakat sonucunuzu öğrenmek için lütfen portal.kulup.com adresine giderek öğrenci numaranızla sisteme giriş yapın.",
    dateTime: DateTime.now().subtract(const Duration(days: 1)),
  ),
  NotificationModel(
    title: "Kodlama ve Pizza Gecesi",
    description:
        "Bu cuma laboratuvarda toplanıyoruz. Kendi bilgisayarınızı getirmeyi unutmayın, pizzalar bizden!",
    content:
        "Geleneksel kodlama gecemize davetlisiniz! Bireysel veya takım olarak kendi projelerinizi geliştirebileceğiniz, takıldığınız yerlerde üst sınıflardan destek alabileceğiniz rahat ve eğlenceli bir çalışma ortamı sunuyoruz. Akşam 20:00'de başlayıp gece yarısına kadar sürecek etkinliğimizde pizzalar kulübümüzün sponsorluğunda olacak. Lütfen kendi bilgisayarınızı, şarj aletinizi ve ihtiyacınız varsa uzatma kablonuzu getirmeyi unutmayın!",
    isRead: true,
    dateTime: DateTime.now().subtract(const Duration(days: 2)),
  ),
  NotificationModel(
    title: "Otonom Araçlar Ar-Ge Toplantısı",
    description:
        "Lidar ve Radar sensör füzyonu üzerine yapacağımız teknik toplantı yarına ertelenmiştir.",
    content:
        "Takım üyelerinin dikkatine: Otonom sistemler ekibi olarak bu hafta gerçekleştireceğimiz teknik toplantı, laboratuvardaki bazı test ekipmanlarının periyodik bakım sürecinde olması nedeniyle bir gün sonraya (Perşembe 14:00) ertelenmiştir. Toplantıda ROS2 üzerinden sensör verilerinin entegrasyonu, Kalman filtreleri ve engel tanıma algoritmaları üzerine tartışacağız. Lütfen gelmeden önce GitHub repository'mizdeki son pull request'leri inceleyin.",
    isRead: true,
    dateTime: DateTime.now().subtract(const Duration(days: 4)),
  ),
  NotificationModel(
    title: "Hackathon Kayıtları Açıldı",
    description:
        "Yılın en büyük hackathon etkinliği için takımını kur ve başvurunu tamamla. Son gün pazar!",
    content:
        "Sınırları zorlamaya hazır mısın? Kesintisiz 48 saat sürecek olan ulusal hackathon etkinliğimizin kayıtları resmi olarak açıldı. Sürdürülebilirlik, FinTek ve Eğitim Teknolojileri temalarında yarışacak takımlar, süre sonunda jüri karşısında prototiplerini sunacaklar. Birinci olan takımı 50.000 TL değerinde teknoloji hediye çeki ve sponsor firmalarda staj imkanları bekliyor. Hemen 3-4 kişilik takımını kur ve web sitemiz üzerinden başvuru formunu doldur. Etkinlik boyunca uykusuz kalacaklar için sınırsız kahve ve mentorlük desteği sağlanacaktır.",
    isRead: true,
    dateTime: DateTime.now().subtract(const Duration(days: 8)),
  ),
  NotificationModel(
    title: "Koala Projesi Değerlendirmesi",
    description:
        "Mavi yaka istihdam projeniz jüri tarafından incelendi. Geri bildirim raporunu sistemden indirebilirsiniz.",
    content:
        "Koala Projesi ekibine tebrikler. Mavi yakalı çalışanları doğru işverenlerle eşleştirmeyi hedefleyen platformunuz, ön değerlendirme jürisi tarafından kullanıcı deneyimi (UX), yenilikçilik ve pazar potansiyeli açısından oldukça başarılı bulundu. Hazırlanan değerlendirme raporunda, sistemin ölçeklenebilirliği ve veri güvenliği ile ilgili birkaç kritik teknik tavsiye yer almaktadır. Raporun tamamını PDF formatında sistemden indirip inceleyebilir, aklınıza takılan sorular ve bir sonraki aşama için mentorünüzle iletişime geçebilirsiniz.",
    isRead: true,
    dateTime: DateTime.now().subtract(const Duration(days: 15)),
  ),
  NotificationModel(
    title: "Ideathon Başvurusu Onaylandı",
    description:
        "Uzman ağı platformu fikriniz ön elemeyi geçti. Final sunumu için hazırlıklara başlayabilirsiniz.",
    content:
        "Harika bir haberimiz var! Alanında uzman kişileri girişimcilerle buluşturan inovatif platform fikriniz, 500'den fazla proje başvurusu arasından sıyrılarak ön elemeyi geçmeyi başardı. Şimdi sırada bu kağıt üzerindeki fikrinizi, iş modeli kanvasıyla destekleyip bir yatırımcı sunumuna (Pitch Deck) dönüştürmek var. Final gününde ana sahnede jüriye 3 dakikalık asansör sunumu (Elevator Pitch) yapmanız beklenecektir. Etkili sunum teknikleri ve iş planı oluşturma eğitimleri önümüzdeki hafta başlayacaktır, programı takipte kalın.",
    isRead: true,
    dateTime: DateTime.now().subtract(const Duration(days: 35)),
  ),
];
