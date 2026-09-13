part of 'shell_page.dart';

abstract class ShellPagemodel extends State<ShellPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  /// Etkinlikler sekmesindeki arama kutusu açık mı.
  bool isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  /// Arama metni doğrudan provider'a gidiyor; liste yazdıkça süzülüyor.
  void _onSearchChanged() {
    context.read<EventProvider>().setSearchQuery(searchController.text);
  }

  /// Kutu açılıyor; klavye, genişleme bitince [AppBarSearchField] içinde
  /// açılıyor.
  void openSearch() => setState(() => isSearchOpen = true);

  /// Kutu kapanırken arama da temizleniyor: kapalı bir kutunun arkasında
  /// süzülmüş bir liste kalmamalı.
  void closeSearch() {
    searchFocusNode.unfocus();
    searchController.clear();
    setState(() => isSearchOpen = false);
  }

  /// Sekme değişince açık arama kapanıyor; geri dönüldüğünde liste tam ve
  /// başlık yerinde olmalı.
  ///
  /// `build` içinden çağrılıyor, bu yüzden kapatma bir sonraki kareye
  /// bırakılıyor: temizlik provider'ı bilgilendiriyor ve build sırasında
  /// bildirim hata veriyor.
  void closeSearchIfLeftCalendar(String location) {
    if (!isSearchOpen || location.startsWith('/calendar')) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isSearchOpen) closeSearch();
    });
  }
}
