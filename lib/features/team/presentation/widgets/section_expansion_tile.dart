import 'package:flutter/material.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

class SectionExpansionTile extends StatelessWidget {
  const SectionExpansionTile({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    this.notificationCount,
    this.child,
  });
  final String title;
  final Color color;
  final IconData icon;
  final int? notificationCount;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(vertical: 12),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: context.textTheme.titleMedium),
            SizedBox(width: 8),
            notificationCount == null
                ? const SizedBox.shrink()
                : Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$notificationCount',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        children: [
          child ??
              Padding(
                padding: context.mainHorizontalPadding,
                child: SizedBox(
                  height: 70,
                  child: Center(
                    child: Text(
                      'Gösterilecek birşey yok',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
