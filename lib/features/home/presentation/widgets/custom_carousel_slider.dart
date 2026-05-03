import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/home/data/models/announcement_model.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({super.key, required this.items});

  final List<AnnouncementModel> items;

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  static const int _initialVirtualPage = 10000;
  static const double _sliderHeight = 220.0;
  static const double _dotHeight = 8.0;
  static const double _dotActiveWidth = 12.0;
  static const double _dotInactiveWidth = 8.0;
  static const double _dotBorderRadius = 4.0;
  static const double _dotSpacing = 10.0;
  static const double _textBottomOffset = 12.0;
  static const double _textHorizontalPadding = 16.0;

  late final PageController _pageController;
  int _currentPage = _initialVirtualPage;
  Timer? _autoPlayTimer;

  int get _current => _currentPage % widget.items.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialVirtualPage);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goToIndex(int itemIndex) {
    if (itemIndex == _current) return;
    final n = widget.items.length;
    int diff = itemIndex - _current;
    if (diff > n ~/ 2) diff -= n;
    if (diff < -(n ~/ 2)) diff += n;
    _startAutoPlay();
    _pageController.animateToPage(
      _currentPage + diff,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _showAnnouncementDialog(BuildContext context, AnnouncementModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(item.image, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(item.subtitle),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF333333), width: 2),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadiuses.navitem),
              child: SizedBox(
                height: _sliderHeight,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final item = widget.items[index % widget.items.length];
                    return GestureDetector(
                      onTap: () {
                        _showAnnouncementDialog(context, item);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(item.image, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: _textBottomOffset,
                            left: _textHorizontalPadding,
                            right: _textHorizontalPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,

                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _dotSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) {
            final isActive = _current == i;
            return GestureDetector(
              onTap: () => _goToIndex(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActive ? _dotActiveWidth : _dotInactiveWidth,
                height: _dotHeight,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_dotBorderRadius),
                  color: isActive
                      ? AppColors.primaryColor
                      : Colors.grey.withValues(alpha: 0.4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
