import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_paddings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Container(),
      ),
    );
  }
}