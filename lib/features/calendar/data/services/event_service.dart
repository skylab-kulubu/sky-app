import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  static final List<EventModel> events = [
    EventModel(
      id: 'TODO_KEY_1',
      imageUrl:
          'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?auto=format&fit=crop&w=400&q=60',
      title: 'Hackathon 2026',
      date: '5 Nisan 2026',
      time: '09:00',
      isJoinable: true,
    ),
    EventModel(
      id: 'TODO_KEY_2',
      imageUrl:
          'https://images.unsplash.com/photo-1522205408450-add114ad53fe?auto=format&fit=crop&w=400&q=60',
      title: 'Flutter Workshop',
      date: '11 Nisan 2026',
      time: '14:00',
      isJoinable: false,
    ),
    EventModel(
      id: 'TODO_KEY_3',
      imageUrl:
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=60',
      title:
          'Çok Uzun Bir Başlık İçeren Etkinlik Denemesi: Bu başlığın UI üzerinde nasıl durduğunu ve taşma yapıp yapmadığını net olarak görmek için özellikle upuzun yazıldı.',
      date: '18 Nisan 2026',
      time: '10:00',
      isJoinable: false,
    ),
    EventModel(
      id: 'TODO_KEY_4',
      imageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=400&q=60',
      title: 'Uzun Tarih ve Saat Testi',
      date:
          '25 Nisan 2026 - 30 Mayıs 2026 Arasında Geçerli ve Daha Uzun Tarih Metni',
      time:
          'Başlangıç: 13:00 Bitiş: 23:59 (Türkiye Saati ile, Lütfen Erken Geliniz)',
      isJoinable: true,
    ),
    EventModel(
      id: 'TODO_KEY_5',
      imageUrl:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=400&q=60',
      title: '',
      date: '26 Nisan 2026',
      time: '12:00',
      isJoinable: false,
    ),
    EventModel(
      id: 'TODO_KEY_6',
      imageUrl:
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=400&q=60',
      title: 'Tarihi ve Saati Belirsiz Etkinlik',
      date: '',
      time: '',
      isJoinable: true,
    ),
    EventModel(
      id: 'TODO_KEY_7',
      imageUrl: 'https://invalid-image-url.com/broken.jpg',
      title: '',
      date: '',
      time: '',
      isJoinable: false,
    ),
    EventModel(
      id: 'TODO_KEY_8',
      imageUrl:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=400&q=60',
      title: 'Scroll Testi 1',
      date: '1 Mayıs 2026',
      time: '14:00',
      isJoinable: true,
    ),
    EventModel(
      id: 'TODO_KEY_9',
      imageUrl:
          'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&w=400&q=60',
      title: 'Scroll Testi 2',
      date: '2 Mayıs 2026',
      time: '15:00',
      isJoinable: false,
    ),
    EventModel(
      id: 'TODO_KEY_10',
      imageUrl:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=400&q=60',
      title: 'Scroll Testi 3',
      date: '3 Mayıs 2026',
      time: '16:00',
      isJoinable: true,
    ),
    EventModel(
      id: 'TODO_KEY_11',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=400&q=60',
      title: 'Scroll Testi 4',
      date: '4 Mayıs 2026',
      time: '17:00',
      isJoinable: false,
    ),
  ];
}
