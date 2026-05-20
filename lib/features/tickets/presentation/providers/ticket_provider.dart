import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sky_app/features/tickets/data/models/ticket_model.dart';
import 'package:sky_app/features/tickets/data/services/tickets_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketsService _ticketsService = TicketsService();

  List<TicketModel> _tickets = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  List<TicketModel> get tickets => _tickets;
  List<TicketModel> get activeTickets =>
      _tickets.where((ticket) => ticket.isActive).toList(growable: false);
  List<TicketModel> get pastTickets =>
      _tickets.where((ticket) => !ticket.isActive).toList(growable: false);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTickets({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_tickets.isNotEmpty && !forceRefresh) {
      if (!_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await _ticketsService.fetchMyTickets();
    } on DioException catch (e) {
      log('Tickets fetch error: ${e.message}');
      _errorMessage = 'Biletler yüklenemedi.';
    } catch (e) {
      log('Tickets fetch error: $e');
      _errorMessage = 'Biletler yüklenemedi.';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }
}
