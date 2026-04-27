import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/home/presentation/pages/home_page.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({super.key, required this.items});

  final List<CarouselItem> items;

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
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(item.imageUrl, fit: BoxFit.cover),
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
