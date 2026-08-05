import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/presentation/providers/event_provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final events = eventProvider.events;

        if (!eventProvider.isInitialized && !eventProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (eventProvider.isLoading && events.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: events.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Text(
                      'Gösterilecek etkinlik yok.',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
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
      },
    );
  }

  Widget _eventCard(EventModel event) {
    return Container(
      decoration: BoxDecoration(
        color: context.tileColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        onTap: () => showEventDetails(context, event),
        contentPadding: const EdgeInsets.all(12.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: event.coverImageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: event.coverImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      CircularProgressIndicator.adaptive(),
                  errorBuilder: (context, error, stackTrace) =>
                      SvgPicture.asset(
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
            color: context.textPrimary,
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
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              event.formattedTime,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        trailing: _trailingButton(event),
      ),
    );
  }

  Widget _trailingButton(EventModel event) {
    if (event.active) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: ElevatedButton(
          onPressed: () => showConfirmationDialog(context, event),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.accentColor,
            foregroundColor: context.textPrimary,
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
              const AppIcon(
                AppIcons.clock,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  child: event.coverImageUrl.isNotEmpty
                      ? Image.network(
                          event.coverImageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => SvgPicture.asset(
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
                          AppIcon(
                            AppIcons.location,
                            size: 16,
                            color: context.accentColor,
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              event.location.isNotEmpty
                                  ? event.location
                                  : 'Konum Belirtilmemiş',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        event.description.isNotEmpty
                            ? event.description
                            : 'Açıklama bulunmuyor.',
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'Kapat',
                            style: context.textTheme.bodyMedium,
                          ),
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

  void showConfirmationDialog(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        var isJoining = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                'Emin misin?',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                '${event.name} etkinliğine katılım kaydın oluşturulacak. Onaylıyor musun?',
                style: context.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: isJoining
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'İptal',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isJoining
                      ? null
                      : () async {
                          setState(() {
                            isJoining = true;
                          });

                          final eventProvider = Provider.of<EventProvider>(
                            context,
                            listen: false,
                          );
                          final joined = await eventProvider.joinEvent(
                            event.id,
                          );

                          if (!context.mounted) return;

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                joined
                                    ? 'Kaydın başarıyla alındı!'
                                    : 'Katılım kaydı oluşturulamadı.',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accentColor,
                    foregroundColor: context.textPrimary,
                  ),
                  child: isJoining
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.textPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Onayla',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
