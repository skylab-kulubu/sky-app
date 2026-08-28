import 'package:flutter/material.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bu sayfa yakında gelecek!\nBeklemede Kalın.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
