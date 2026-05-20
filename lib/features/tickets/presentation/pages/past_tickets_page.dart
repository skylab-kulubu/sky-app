import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/features/tickets/presentation/providers/ticket_provider.dart';
import 'package:sky_app/features/tickets/presentation/widgets/ticket_card.dart';

class PastTicketsPage extends StatelessWidget {
  const PastTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketProvider>();
    final tickets = provider.pastTickets;

    if (provider.isLoading && provider.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError && provider.tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Biletler yüklenemedi.'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<TicketProvider>().fetchTickets(
                forceRefresh: true,
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }

    if (tickets.isEmpty) {
      return const Center(child: Text('Geçmiş biletiniz bulunmuyor.'));
    }

    return ListView.separated(
      itemCount: tickets.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSizes.bigSpace),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return TicketCard(
          eventName: ticket.event.name,
          location: ticket.event.location,
          date: ticket.event.formattedDate,
          time: ticket.event.formattedTime,
          ticketNo: ticket.id,
          holderName: ticket.holderName,
          isActive: ticket.isActive,
        );
      },
    );
  }
}
