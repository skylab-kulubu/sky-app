import 'package:material_ui/material_ui.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/sky_text_field.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/presentation/widgets/date_time_picker.dart';

/// Kopyanın adı ve başlangıcı; vazgeçilirse `null`. Program ve bitiş yeni
/// başlangıçla aynı mesafede kayıyor.
class EventCopyDialog extends StatefulWidget {
  const EventCopyDialog({super.key, required this.source});

  final EventModel source;

  static Future<({String name, DateTime startDate})?> show(
    BuildContext context, {
    required EventModel source,
  }) {
    return showDialog<({String name, DateTime startDate})>(
      context: context,
      builder: (_) => EventCopyDialog(source: source),
    );
  }

  @override
  State<EventCopyDialog> createState() => _EventCopyDialogState();
}

class _EventCopyDialogState extends State<EventCopyDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.source.name,
  );

  late DateTime _startDate = _defaultStart();

  /// Kaynağın gün ve saati, bugünden sonraki ilk haftaya taşınmış; kaynak
  /// tarihsizse bir sonraki tam saat.
  DateTime _defaultStart() {
    final now = DateTime.now();
    var start =
        widget.source.startDateTime ??
        DateTime(now.year, now.month, now.day, now.hour + 1);
    while (!start.isAfter(now)) {
      start = start.add(const Duration(days: 7));
    }
    return start;
  }

  bool get _canSubmit => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _onPickStart() async {
    final value = await pickDateTime(context, _startDate);
    if (value == null || !mounted) return;
    setState(() => _startDate = value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.tileColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.cardBorderRadius,
      ),
      title: Text(
        'Kopyasını oluştur',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Açıklama, konum, kapak ve program taslak olarak kopyalanır. '
            'Kayıtlar ve formlar kopyalanmaz.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.bigSpace),
          SkyTextField(
            controller: _name,
            hintText: 'Etkinlik adı',
            fillColor: context.elevatedColor,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSizes.midSpace),
          InkWell(
            onTap: _onPickStart,
            borderRadius: AppRadiuses.cardBorderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.midSpace),
              child: Row(
                children: [
                  AppIcon(
                    AppIcons.calendar,
                    size: AppSizes.iconMedium,
                    color: context.accentColor,
                  ),
                  const SizedBox(width: AppSizes.bigSpace),
                  Expanded(
                    child: Text(
                      'Başlangıç',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    shortDateTimeLabel(_startDate),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
          onPressed: _canSubmit
              ? () => Navigator.pop(context, (
                  name: _name.text.trim(),
                  startDate: _startDate,
                ))
              : null,
          child: Text(
            'Oluştur',
            style: context.textTheme.bodyMedium?.copyWith(
              color: _canSubmit ? context.accentColor : context.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
