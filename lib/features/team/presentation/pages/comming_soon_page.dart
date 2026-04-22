import 'package:flutter/material.dart';

class CommingSoonPage extends StatelessWidget {
  const CommingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Text(
            'Bu sayfa yakında gelecek!\nBeklemede Kalın.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}
