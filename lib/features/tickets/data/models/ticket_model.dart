import 'package:sky_app/features/tickets/data/models/ticket_event_model.dart';

class TicketModel {
  final String id;
  final bool sent;
  final String ticketType;
  final String ownerFirstName;
  final String ownerLastName;
  final String? guestFirstName;
  final String? guestLastName;
  final TicketEventModel event;
  final int checkInCount;

  const TicketModel({
    required this.id,
    required this.sent,
    required this.ticketType,
    required this.ownerFirstName,
    required this.ownerLastName,
    this.guestFirstName,
    this.guestLastName,
    required this.event,
    required this.checkInCount,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? {};
    final checkIns = json['checkIns'] as List<dynamic>? ?? [];
    return TicketModel(
      id: json['id'] as String? ?? '',
      sent: json['sent'] as bool? ?? false,
      ticketType: json['ticketType'] as String? ?? '',
      ownerFirstName: owner['firstName'] as String? ?? '',
      ownerLastName: owner['lastName'] as String? ?? '',
      guestFirstName: json['guestFirstName'] as String?,
      guestLastName: json['guestLastName'] as String?,
      event: TicketEventModel.fromJson(
        json['event'] as Map<String, dynamic>? ?? {},
      ),
      checkInCount: checkIns.length,
    );
  }

  bool get isGuest => ticketType == 'GUEST';

  String get holderName {
    if (isGuest) {
      return '${guestFirstName ?? ''} ${guestLastName ?? ''}'.trim();
    }
    return '$ownerFirstName $ownerLastName'.trim();
  }

  bool get isActive => event.active;

  bool get isCheckedIn => checkInCount > 0;
}
