import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/sky_button.dart';

/// Paylaşılan bağlantıyla (`/news/<slug>`, `/events/<id>`) açılan içeriği
/// yükleyip detay sayfasını gösterir.
///
/// Link soğuk açılışta gelebildiği için liste yüklenmesi beklenmiyor; içerik
/// doğrudan tek kayıt endpoint'inden çekiliyor. Yüklenirken gösterge,
/// bulunamazsa (silinmiş/yanlış link) bilgi, başka hatada tekrar dene.
class ContentLinkPage<T> extends StatefulWidget {
  const ContentLinkPage({
    super.key,
    required this.load,
    required this.builder,
    required this.notFoundTitle,
  });

  final Future<T> Function() load;
  final Widget Function(T content) builder;

  /// Bulunamadığında başlık, ör. "Haber bulunamadı".
  final String notFoundTitle;

  @override
  State<ContentLinkPage<T>> createState() => _ContentLinkPageState<T>();
}

class _ContentLinkPageState<T> extends State<ContentLinkPage<T>> {
  T? _content;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final content = await widget.load();
      if (mounted) setState(() => _content = content);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    if (content != null) return widget.builder(content);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          // Link doğrudan açıldıysa altta sekme sayfası var (rota iç içe);
          // yine de geri gidilemiyorsa ana sayfaya.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: _error == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _message(context, _error!),
    );
  }

  Widget _message(BuildContext context, ApiException error) {
    final notFound = error.type == ApiErrorType.notFound;

    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              notFound ? AppIcons.search : AppIcons.warning,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              notFound ? widget.notFoundTitle : 'Yüklenemedi',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              notFound
                  ? 'Bağlantı hatalı ya da içerik kaldırılmış olabilir.'
                  : error.userMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            if (!notFound) ...[
              const SizedBox(height: AppSizes.largeSpace),
              SkyButton(text: 'Tekrar Dene', onPressed: _load),
            ],
          ],
        ),
      ),
    );
  }
}
