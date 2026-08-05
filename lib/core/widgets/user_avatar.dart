import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Kullanıcı avatarı. Görsel yoksa ya da yüklenemezse baş harflerine düşer.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.imageUrl, this.size});

  final String name;
  final String? imageUrl;
  final double? size;

  static const double _defaultSize = 40;

  double get _size => size ?? _defaultSize;

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  /// Ad ve soyadın ilk harfleri; ad boşsa ikon gösterilir.
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        color: AppColors.tileBackgroundColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    if (_initials.isEmpty) {
      return Center(
        child: AppIcon(
          AppIcons.profile,
          size: _size * 0.5,
          color: AppColors.primaryColor,
        ),
      );
    }

    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: _size * 0.36,
        ),
      ),
    );
  }
}
