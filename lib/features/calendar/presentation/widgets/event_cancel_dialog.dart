import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';

/// İptal için sebep (herkese açık, isteğe bağlı) ve bilet sahiplerine e-posta
/// seçimi; vazgeçilirse `null`.
class EventCancelDialog extends StatefulWidget {
  const EventCancelDialog({super.key, required this.eventName});

  final String eventName;

  /// Core sebebi 500 karakterle sınırlıyor.
  static const int _maxReasonLength = 500;

  static Future<({String reason, bool notify})?> show(
    BuildContext context, {
    required String eventName,
  }) {
    return showDialog<({String reason, bool notify})>(
      context: context,
      builder: (_) => EventCancelDialog(eventName: eventName),
    );
  }

  @override
  State<EventCancelDialog> createState() => _EventCancelDialogState();
}

class _EventCancelDialogState extends State<EventCancelDialog> {
  late final TextEditingController _reason = TextEditingController();
  bool _notify = true;

  @override
  void dispose() {
    _reason.dispose();
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
        'Etkinlik iptal edilsin mi?',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.eventName} görünür kalır ama yeni kayıt ve giriş '
            'alınmaz. Kayıtlar silinmez, iptali sonra geri alabilirsin.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: _reason,
            hintText: 'Sebep (isteğe bağlı, herkes görür)',
            minLines: 2,
            maxLines: 4,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                EventCancelDialog._maxReasonLength,
              ),
            ],
            fillColor: context.elevatedColor,
          ),
          const SizedBox(height: AppSizes.midSpace),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kayıtlı olanlara e-posta gönder',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              Switch.adaptive(
                value: _notify,
                activeTrackColor: context.accentColor,
                onChanged: (value) => setState(() => _notify = value),
              ),
            ],
          ),
        ],
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
          onPressed: () => Navigator.pop(context, (
            reason: _reason.text.trim(),
            notify: _notify,
          )),
          child: Text(
            'İptal Et',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
