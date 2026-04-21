import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:sky_app/core/models/link_item.dart';

class WebviewService {
  static void openLink(BuildContext context, LinkItem link) {
    if (kIsWeb) {
      launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
    } else {
      context.push('/webview', extra: {'url': link.url, 'title': link.name});
    }
  }
}
