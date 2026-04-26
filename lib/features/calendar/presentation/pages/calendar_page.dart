import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'calendar_page_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends CalendarPageModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: AppPaddings.mainPaddingAll,
        itemCount: events.length + 1,
        itemBuilder: (context, index) {
          if (index == events.length) {
            return const SizedBox(height: 100);
          }
          final event = events[index];
          return Padding(
            key: Key(event.id),
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _eventCard(event),
          );
        },
      ),
    );
  }

  Widget _eventCard(EventModel event) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        onTap: () => showEventDetails(context, event),
        contentPadding: const EdgeInsets.all(12.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: event.coverImageUrl.isNotEmpty
              ? Image.network(
                  event.coverImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                    'assets/images/skylab.svg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                )
              : SvgPicture.asset(
                  'assets/images/skylab.svg',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
        ),
        title: Text(
          event.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              event.formattedDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              event.formattedTime,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
        trailing: _trailinButton(event),
      ),
    );
  }

  Widget _trailinButton(EventModel event) {
<<<<<<< HEAD
    if (event.isJoinable) {
=======
    if (event.active) {
>>>>>>> 1130271 (abi wifi sifresi ne)
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: ElevatedButton(
          onPressed: () => showJoinFlow(context, event),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
          ),
          child: const Text(
            'Katıl',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.orange9,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time,
                size: 16.0,
                color: AppColors.orange,
              ),
              const SizedBox(width: 4.0),
              Flexible(
                child: Text(
                  'Yakında',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void showEventDetails(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: event.coverImageUrl.isNotEmpty
                      ? Image.network(
                          event.coverImageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => SvgPicture.asset(
                            'assets/images/skylab.svg',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/images/skylab.svg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: AppColors.primaryColor),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              event.location.isNotEmpty ? event.location : 'Konum Belirtilmemiş',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        event.description.isNotEmpty ? event.description : 'Açıklama bulunmuyor.',
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('Kapat', style: context.textTheme.bodyMedium),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showJoinFlow(BuildContext context, EventModel event) {
    final days = event.eventDays;
    if (days.isEmpty) return;

    if (days.length == 1) {
      showConfirmationDialog(context, event, days);
      return;
    }

    List<DateTime> selectedDays = List.from(days);

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              title: Text('Katılacağın Günler', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: days.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return CheckboxListTile(
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      value: isSelected,
                      title: Text(
                        '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}',
                        style: context.textTheme.bodyLarge,
                      ),
                      activeColor: AppColors.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('İptal', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textGray)),
                ),
                ElevatedButton(
                  onPressed: selectedDays.isEmpty
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                          showConfirmationDialog(context, event, selectedDays);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textWhite,
                  ),
                  child: Text('Devam Et', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showConfirmationDialog(BuildContext context, EventModel event, List<DateTime> selectedDays) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text('Emin misin?', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          content: Text(
            '${event.name} etkinliğine ${selectedDays.length} gün için katılım kaydın oluşturulacak. Onaylıyor musun?',
            style: context.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('İptal', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textGray)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kaydın başarıyla alındı!', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textWhite))),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textWhite,
              ),
              child: Text('Onayla', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
