import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';

class SkyButton extends StatelessWidget {
  const SkyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppRadiuses.buttonRadius),
        ),
      ),
      onPressed: () {},
      child: Text('MOBILAB'),
    );
  }
}
