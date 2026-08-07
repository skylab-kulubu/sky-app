import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(context.backgroundColor)
        ..loadRequest(Uri.parse(widget.url));
    } else {
      // Web platformu için otomatik olarak tarayıcıda açalım
      _launchInBrowser(widget.url);
    }
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    AppIcons.browser,
                    color: context.textPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Web platformunda site dışarıda açıldı.',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _launchInBrowser(widget.url),
                    child: const Text('Tekrar Aç'),
                  ),
                ],
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
