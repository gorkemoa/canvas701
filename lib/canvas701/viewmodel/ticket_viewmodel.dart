import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../model/ticket_model.dart';

class TicketViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  List<Ticket> _tickets = [];
  List<Ticket> get tickets => _tickets;

  Ticket? _selectedTicket;
  Ticket? get selectedTicket => _selectedTicket;

  List<TicketSubject> _subjects = [];
  List<TicketSubject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getTickets();
      if (response.success && response.data != null) {
        _tickets = response.data!.tickets;
      } else {
        _errorMessage = 'Destek talepleri alınamadı';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTicketDetail(int ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getTicketDetail(ticketId);
      if (response.success && response.ticket != null) {
        _selectedTicket = response.ticket;
      } else {
        _errorMessage = 'Destek talebi detayları alınamadı';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubjects() async {
    try {
      final response = await _userService.getTicketSubjects();
      if (response.success) {
        _subjects = response.subjects;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    }
  }

  Future<CreateTicketResponse> createTicket({
    required String title,
    required int subjectId,
    required String message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _userService.addTicket(
        title: title,
        subjectId: subjectId,
        message: message,
      );
      if (response.success) {
        await fetchTickets(); // Refresh list after creation
      }
      return response;
    } catch (e) {
      return CreateTicketResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CreateTicketResponse> sendMessage({
    required int ticketId,
    required String message,
    List<String> files = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _userService.sendTicketMessage(
        ticketId: ticketId,
        message: message,
        files: files,
      );
      if (response.success) {
        await fetchTicketDetail(ticketId); // Refresh details after sending
      }
      return response;
    } catch (e) {
      return CreateTicketResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
