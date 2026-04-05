import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sky_app/core/constants/app_colors.dart';

class ProfileWebViewPage extends StatefulWidget {
  const ProfileWebViewPage({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<ProfileWebViewPage> createState() => _ProfileWebViewPageState();
}

class _ProfileWebViewPageState extends State<ProfileWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.scaffoldBackgroundColor)
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
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.open_in_browser_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Web platformunda site dışarıda açıldı.',
                    style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
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
