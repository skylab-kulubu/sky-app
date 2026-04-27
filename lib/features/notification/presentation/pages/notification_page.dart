import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/notification/data/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Bildirimler', style: context.textTheme.titleMedium),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: numberOfNotifications,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    color: notifications[index].isRead == true
                        ? Color(0xFF1E90FF).withAlpha(10)
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF2A2A2A),
                        width: 0.664,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      selected: notifications[index].isRead,
                      titleAlignment: ListTileTitleAlignment.top,

                      leading: Container(
                        alignment: Alignment.center,
                        height: 39.999,
                        width: 39.999,
                        decoration: BoxDecoration(
                          color: notifications[index].isRead == false
                              ? Color(0xFF333333)
                              : Color(0xFF1E90FF).withAlpha(41),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.campaign_outlined,
                          size: AppSizes.icon,
                        ),
                      ),
                      title: Text(
                        notifications[index].title,
                        style: context.textTheme.titleSmall,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              notifications[index].description,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Color(0Xff888888),
                              ),
                            ),
                          ),

                          Text(
                            timeago.format(
                              notifications[index].dateTime,
                              locale: 'tr',
                            ),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: notifications[index].isRead == true
                              ? Color(0xFF1E90FF)
                              : null,
                          shape: BoxShape.circle,
                        ),

                        height: 8,
                        width: 8,
                      ),

                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: AppColors.cardBackground,
                              title: Text(
                                notifications[index].title,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(notifications[index].content),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Tamam'),
                                ),
                              ],

                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Color(0xFF333333),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
