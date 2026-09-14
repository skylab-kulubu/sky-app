import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';

/// Kontenjanı soran dialog; girilen sayıyı döner (boş ya da 0 = sınırsız),
/// vazgeçilirse `null`.
///
/// Metin alanının controller'ı dialogun kendi state'inde. Çağıran tarafta
/// tutulup `showDialog` dönünce silindiğinde, dialog kapanma animasyonu
/// sürerken alan hâlâ çizildiği için "used after being disposed" hatası
/// veriyordu.
class EventCapacityDialog extends StatefulWidget {
  const EventCapacityDialog({super.key, required this.initialValue});

  final int initialValue;

  static Future<int?> show(BuildContext context, {required int initialValue}) {
    return showDialog<int>(
      context: context,
      builder: (_) => EventCapacityDialog(initialValue: initialValue),
    );
  }

  @override
  State<EventCapacityDialog> createState() => _EventCapacityDialogState();
}

class _EventCapacityDialogState extends State<EventCapacityDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue > 0 ? '${widget.initialValue}' : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.tileColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.cardBorderRadius,
      ),
      title: Text(
        'Kontenjan',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      // Formlardaki alanın aynısı; dialog zaten tile renginde olduğu için
      // zemini bir tık yükseltilmiş.
      content: SkyTextField(
        controller: _controller,
        autofocus: true,
        hintText: 'Sınırsız için boş bırak',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        fillColor: context.elevatedColor,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Vazgeç',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            int.tryParse(_controller.text.trim()) ?? 0,
          ),
          child: Text(
            'Tamam',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
