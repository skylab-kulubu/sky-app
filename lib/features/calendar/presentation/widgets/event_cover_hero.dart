import 'package:flutter/material.dart';

/// Etkinlik kapağını detaya uçabilmesi için [Hero] ile sarar; kapağı gösteren
/// üç yer de bunu kullanıyor.
class EventCoverHero extends StatelessWidget {
  const EventCoverHero({super.key, required this.eventId, required this.child});

  final String eventId;
  final Widget child;

  static String tagFor(String eventId) => 'event-cover-$eventId';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagFor(eventId),
      // Düz uçuş yolu: varsayılan `MaterialRectArcTween` küçük kareden tam genişliğe
      // giderken görseli yana savuruyordu. Eğri Hero'da sabit (`fastOutSlowIn`).
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: child,
    );
  }
}
