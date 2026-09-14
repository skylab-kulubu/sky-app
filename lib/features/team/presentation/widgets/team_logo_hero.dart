import 'package:flutter/material.dart';

/// Ekip logosunu, karttan detay sayfasına uçabilmesi için [Hero] ile sarar.
///
/// `EventCoverHero` ile aynı düzen: etiket ve uçuş yolu tek yerde, kart ve
/// detay sayfası aynı widget'ı kullanıyor.
class TeamLogoHero extends StatelessWidget {
  const TeamLogoHero({super.key, required this.slug, required this.child});

  final String slug;
  final Widget child;

  static String tagFor(String slug) => 'team-logo-$slug';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagFor(slug),
      // Düz uçuş yolu; varsayılan yay çizen tween logoyu yana savuruyor.
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: child,
    );
  }
}
