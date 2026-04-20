import 'package:flutter/material.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

class PersonTag extends StatelessWidget {
  const PersonTag({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color(0xff1E90FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            color: Color(0xff1E90FF),
          ),
        ),
      ),
    );
  }
}
