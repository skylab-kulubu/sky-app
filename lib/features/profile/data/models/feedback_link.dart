/// Biletin geri bildirim formu (`GET /v1/tickets/me` → `feedback[]`, core
/// `docs/event-feedback.md`). Yalnızca girişi okutulmuş ve geri bildirim
/// postası gitmiş biletlerde var; adres kişiye özel davet kodunu taşıyor
/// (`…?davet=<kod>`), olduğu gibi açılmalı.
class FeedbackLink {
  const FeedbackLink({
    required this.url,
    required this.title,
    required this.answered,
    this.sessionId,
  });

  final String url;

  /// Oturumun başlığı; etkinliğin formunda etkinliğin adı.
  final String title;

  /// Oturumun formuysa oturum id'si; etkinliğin formunda `null`.
  final String? sessionId;

  final bool answered;

  /// Adresi `https` olmayan ya da eksik öğe atlanıyor.
  static FeedbackLink? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final url = json['url'];
    if (url is! String || !url.startsWith('https://')) return null;
    return FeedbackLink(
      url: url,
      title: json['title'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
      answered: json['answered'] == true,
    );
  }
}
