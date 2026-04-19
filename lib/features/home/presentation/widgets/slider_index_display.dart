import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';

class SliderIndexDisplay extends StatelessWidget {
  const SliderIndexDisplay({
    super.key,
    required this.imgList,
    required this.current,
    required this.sliderController,
  });

  final List<String> imgList;
  final int current;
  final CarouselSliderController sliderController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8.0), // TODO constant yap
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imgList.length, (index) {
            final isActive = current == index;
            return GestureDetector(
              onTap: () => sliderController.animateToPage(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250), // TODO constant yap
                width: isActive ? 12.0 : 8.0, // TODO constant yap
                height: isActive ? 12.0 : 8.0, // TODO constant yap
                margin: EdgeInsets.symmetric(
                  horizontal: 4.0,
                ), // TODO constant yap
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.blue
                      : Colors.grey, // TODO constant yap
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
