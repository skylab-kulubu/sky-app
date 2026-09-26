import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/nav_menu_action.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Shell'in yüzen navbar'ı.
///
/// [actions] boşsa yalnızca sekmeler var: seçili sekme etiketini gösteren
/// bir hap. Doluysa sekmeler etiketsiz verilir ve hap'ın sağına yuvarlak bir
/// menü butonu gelir. Butona basınca sekme ikonları kaybolurken hap yukarı
/// doğru uzayıp [actions] satırlarını gösteren bir karta dönüşür; buton
/// kapatma butonu olur.
///
/// Kart navbar'ın yerini aştığı için widget ekranın tamamını kaplamalı
/// (bir [Stack] içinde `Positioned.fill`): Scaffold'un `bottomNavigationBar`
/// yuvasında dursaydı yuvanın dışına taşan satırlar dokunma almazdı. Açıkken
/// dışarıya dokunmak ve geri tuşu menüyü kapatıyor.
class ExpandableNavBar extends StatefulWidget {
  const ExpandableNavBar({
    super.key,
    required this.items,
    this.actions = const [],
    this.menuIcon = AppIcons.adminMenu,
  });

  /// Sekmeler (`NavItem`). [actions] varken `showLabel: false` verilmeli.
  final List<Widget> items;

  final List<NavMenuAction> actions;

  /// Menü kapalıyken yuvarlak butonun ikonu.
  final String menuIcon;

  /// Hap'ın yüksekliği: navbar öğesi (ikon + dikey boşluğu) ve hap'ın iç
  /// boşluğu. Menü butonu da bu çapta, ikisi aynı hizada duruyor.
  static double get barHeight =>
      AppSizes.icon +
      AppPaddings.navItem.vertical +
      AppPaddings.navBarContent.vertical;

  /// Navbar'ın ekranın altında kapladığı yükseklik (kenar boşluklarıyla).
  static double get slotHeight => barHeight + AppPaddings.navBar.vertical;

  @override
  State<ExpandableNavBar> createState() => _ExpandableNavBarState();
}

class _ExpandableNavBarState extends State<ExpandableNavBar>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 420);
  static const Duration _iconSwitchDuration = Duration(milliseconds: 220);

  /// Butondaki ikon değişirken küçükten büyüyor.
  static const double _iconSwitchScale = 0.6;

  static const double _shadowBlur = 36;
  static const double _shadowSpread = 2;
  static const Offset _shadowOffset = Offset(0, 8);

  /// Hap'ın zemini; arkasından geçen içerik çok az seziliyor.
  static const double _surfaceOpacity = 0.95;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  /// Kartın boyu.
  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  /// Sekme ikonları ilk kısımda kayboluyor, satırlar sonra beliriyor; ikisi
  /// aynı anda görünüp birbirine karışmıyor.
  late final Animation<double> _itemsOpacity = ReverseAnimation(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _menuOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: Curves.easeOut),
  );

  bool _isOpen = false;

  bool get _hasMenu => widget.actions.isNotEmpty;

  @override
  void didUpdateWidget(covariant ExpandableNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yetki düşerse (çıkış, profil yenilenmesi) açık kart kalmasın.
    if (!_hasMenu && _controller.value > 0) {
      _isOpen = false;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  /// Kart, açılan sayfanın arkasında kapanıyor; geri dönüldüğünde navbar
  /// yine sekmeleri gösteriyor.
  void _onActionTap(NavMenuAction action) {
    _close();
    action.onTap();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasMenu) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: AppPaddings.navBar,
          // Hap içeriğe oturuyor; dar ekranda taşmak yerine küçülsün diye
          // FittedBox ile sarmalanıyor.
          child: FittedBox(fit: BoxFit.scaleDown, child: _plainBar(context)),
        ),
      );
    }

    return PopScope(
      canPop: !_isOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Stack(
        children: [
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: AppPaddings.navBar,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // Kart yukarı uzarken buton altta, hap'la aynı hizada kalıyor.
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _panel(context),
                    const SizedBox(width: AppSizes.bigSpace),
                    _menuButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menü yokken: yalnızca sekmeler.
  Widget _plainBar(BuildContext context) {
    return Container(
      padding: AppPaddings.navBarContent,
      decoration: _surface(
        context,
        borderRadius: AppRadiuses.stadiumBorderRadius,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: widget.items),
    );
  }

  /// Sekmelerle menü aynı yüzeyde üst üste: biri kısalırken öteki uzuyor.
  ///
  /// Menü `heightFactor: t`, sekmeler `1 - t` ile açılıyor; kartın boyu
  /// böylece iki içeriğin kendi yüksekliği arasında kendiliğinden
  /// geçiş yapıyor, elle ölçü hesaplanmıyor. Genişlik ikisinin genişinde
  /// sabit kalıyor ([IntrinsicWidth]).
  Widget _panel(BuildContext context) {
    final menu = _menu(context);
    final items = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widget.items,
    );

    return Container(
      padding: AppPaddings.navBarContent,
      decoration: _surface(
        context,
        // Stadium değil: uzayınca yarım daire uçlu bir hap olurdu. Kapalıyken
        // yüksekliğin yarısı olduğu için aynı hap görünüyor.
        borderRadius: BorderRadius.circular(ExpandableNavBar.barHeight / 2),
      ),
      child: IntrinsicWidth(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Menü kartın üst kenarına bağlı; kart uzadıkça onunla
              // yukarı taşınıyor.
              _reveal(
                factor: _size.value,
                alignment: Alignment.topCenter,
                opacity: _menuOpacity.value,
                isActive: _isOpen,
                child: menu,
              ),
              // Sekmeler yerinde kalıp soluyor; kesilme görünmeden bitiyor.
              _reveal(
                factor: 1 - _size.value,
                alignment: Alignment.bottomCenter,
                opacity: _itemsOpacity.value,
                isActive: !_isOpen,
                child: items,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reveal({
    required double factor,
    required Alignment alignment,
    required double opacity,
    required bool isActive,
    required Widget child,
  }) {
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: factor,
        child: Opacity(
          opacity: opacity,
          child: IgnorePointer(ignoring: !isActive, child: child),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final action in widget.actions)
          _NavMenuRow(action: action, onTap: () => _onActionTap(action)),
      ],
    );
  }

  Widget _menuButton(BuildContext context) {
    final size = ExpandableNavBar.barHeight;

    return Container(
      width: size,
      height: size,
      decoration: _surface(context),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggle,
          child: Center(
            child: AnimatedSwitcher(
              duration: _iconSwitchDuration,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: _iconSwitchScale,
                    end: 1,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: AppIcon(
                _isOpen ? AppIcons.close : widget.menuIcon,
                key: ValueKey(_isOpen),
                size: AppSizes.icon,
                // Navbar'daki seçili olmayan sekme ikonlarıyla aynı ton.
                color: context.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hap, kart ve buton aynı yüzeyi paylaşıyor. [borderRadius] verilmezse
  /// daire.
  BoxDecoration _surface(BuildContext context, {BorderRadius? borderRadius}) {
    final isDark = context.theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: context.tileColor.withValues(alpha: _surfaceOpacity),
      shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: borderRadius,
      // Kenarlık yalnızca açık temada: orada hap ile beyaz zemin arasındaki
      // fark çok az kalıyor ve sınırı belirginleştiriyor. Koyu temada hap
      // zaten siyah zeminden ayrıştığı için kenarlık fazladan bir çizgi gibi
      // duruyor.
      border: isDark ? null : Border.all(color: context.dividerColor),
      boxShadow: [
        BoxShadow(
          color: isDark ? AppColors.navShadowDark : AppColors.navShadowLight,
          blurRadius: _shadowBlur,
          spreadRadius: _shadowSpread,
          offset: _shadowOffset,
        ),
      ],
    );
  }
}

/// Menü kartındaki satır: ikon ve etiket. Yüksekliği navbar öğesiyle aynı.
class _NavMenuRow extends StatelessWidget {
  const _NavMenuRow({required this.action, required this.onTap});

  final NavMenuAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AppRadiuses.stadiumBorderRadius,
        onTap: onTap,
        child: Padding(
          padding: AppPaddings.navItem,
          child: Row(
            children: [
              AppIcon(
                action.icon,
                size: AppSizes.icon,
                color: context.textPrimary,
              ),
              const SizedBox(width: AppSizes.bigSpace),
              Flexible(
                child: Text(
                  action.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
