import 'package:flutter/material.dart';

/// Etkinlik kapağını, detay sayfasına uçabilmesi için [Hero] ile sarar.
///
/// Etiket ve uçuş yolu burada tanımlı: kapağı gösteren üç yer (Etkinlikler
/// kartı, ana sayfadaki yaklaşan etkinlik satırı ve detay sayfası) aynı
/// widget'ı kullanıyor, yani ayar tek yerden değişiyor.
class EventCoverHero extends StatelessWidget {
  const EventCoverHero({super.key, required this.eventId, required this.child});

  final String eventId;
  final Widget child;

  static String tagFor(String eventId) => 'event-cover-$eventId';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagFor(eventId),
      // Uçuş yolu düz.
      //
      // Hero'nun varsayılanı `MaterialRectArcTween`: dikdörtgen hedefe yay
      // çizerek gidiyor. Küçük bir kareden tam genişlikte bir kareye
      // giderken bu kavis belirginleşiyor ve görsel yana savrulmuş gibi
      // duruyor. Düz interpolasyon aradaki mesafeyi olduğu gibi kat ediyor.
      //
      // Hareketin hızlanma eğrisi Hero'nun kendi içinde sabit
      // (`Curves.fastOutSlowIn`) ve buradan değiştirilemiyor.
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: child,
    );
  }
}
