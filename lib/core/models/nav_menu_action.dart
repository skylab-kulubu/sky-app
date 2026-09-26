/// Navbar'ın yanındaki menüde bir satır (`ExpandableNavBar`).
class NavMenuAction {
  /// [AppIcons] içindeki ikon adı.
  final String icon;
  final String label;
  final void Function() onTap;

  const NavMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
