import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/features/tickets/data/models/ticket_model.dart';
import 'package:sky_app/features/tickets/data/services/tickets_service.dart';
import 'package:sky_app/features/tickets/presentation/widgets/ticket_card.dart';

class PastTicketsPage extends StatefulWidget {
  const PastTicketsPage({super.key});

  @override
  State<PastTicketsPage> createState() => _PastTicketsPageState();
}

class _PastTicketsPageState extends State<PastTicketsPage> {
  final TicketsService _ticketsService = TicketsService();

  List<TicketModel> _tickets = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final all = await _ticketsService.fetchMyTickets();
      if (!mounted) return;
      setState(() {
        _tickets = all.where((t) => !t.isActive).toList(growable: false);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Biletler yüklenemedi.'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchTickets,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }

    if (_tickets.isEmpty) {
      return const Center(child: Text('Geçmiş biletiniz bulunmuyor.'));
    }

    return ListView.separated(
      itemCount: _tickets.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSizes.bigSpace),
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
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
