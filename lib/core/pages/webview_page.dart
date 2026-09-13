import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
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

  /// Web'de site dış tarayıcıda açılamadı.
  bool _launchFailed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _launchInBrowser();
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  /// Zemin rengi burada veriliyor: tema `initState` içinde okunamıyor, debug'da
  /// assertion fırlatıyor. Tema sayfa açıkken değişirse de yeniden çağrılıyor.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb) _controller.setBackgroundColor(context.backgroundColor);
  }

  /// Hata fırlatmıyor; `initState`'ten çağrıldığı için yakalayan olmazdı.
  Future<void> _launchInBrowser() async {
    bool launched;
    try {
      launched = await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;
    setState(() => _launchFailed = !launched);
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
          ? _webFallback(context)
          : WebViewWidget(controller: _controller),
    );
  }

  Widget _webFallback(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              _launchFailed ? AppIcons.warning : AppIcons.browser,
              size: AppSizes.iconLarge,
              color: _launchFailed ? context.textTertiary : context.textPrimary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              _launchFailed
                  ? 'Site açılamadı.'
                  : 'Web platformunda site dışarıda açıldı.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _launchInBrowser,
              child: const Text('Tekrar Aç'),
            ),
          ],
        ),
      ),
    );
  }
}
