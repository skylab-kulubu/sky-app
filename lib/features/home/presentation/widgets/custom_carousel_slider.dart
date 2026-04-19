import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({
    super.key,
    required this.imgList,
    required this.sliderController,
    required this.onPageChanged,
  });

  final List<String> imgList;
  final CarouselSliderController sliderController;
  final ValueChanged<int> onPageChanged;

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: widget.sliderController,
      itemCount: widget.imgList.length,
      itemBuilder: (context, index, realIndex) {
        final imgUrl = widget.imgList[index];
        return Image.network(imgUrl, fit: BoxFit.cover);
      },
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          widget.onPageChanged(index);
        },
      ),
    );
  }
}
