class TicketResponse {
  final bool error;
  final bool success;
  final TicketData? data;

  TicketResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? TicketData.fromJson(json['data']) : null,
    );
  }
}

class TicketData {
  final String emptyMessage;
  final int totalItems;
  final List<Ticket> tickets;

  TicketData({
    required this.emptyMessage,
    required this.totalItems,
    required this.tickets,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      emptyMessage: json['emptyMessage'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      tickets: (json['tickets'] as List?)
              ?.map((e) => Ticket.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Ticket {
  final int ticketId;
  final String ticketTitle;
  final int subjectId;
  final String subjectTitle;
  final int statusId;
  final String statusTitle;
  final String statusColor;
  final int isActive;
  final String createDate;
  final String lastActionDate;
  final List<TicketMessage> messages;
  final List<String> files;

  Ticket({
    required this.ticketId,
    required this.ticketTitle,
    required this.subjectId,
    required this.subjectTitle,
    required this.statusId,
    required this.statusTitle,
    required this.statusColor,
    required this.isActive,
    required this.createDate,
    required this.lastActionDate,
    this.messages = const [],
    this.files = const [],
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketID'] ?? 0,
      ticketTitle: json['ticketTitle'] ?? '',
      subjectId: json['subjectID'] ?? 0,
      subjectTitle: json['subjectTitle'] ?? '',
      statusId: json['statusID'] ?? 0,
      statusTitle: json['statusTitle'] ?? '',
      statusColor: json['statusColor'] ?? '#000000',
      isActive: json['isActive'] ?? 0,
      createDate: json['createDate'] ?? '',
      lastActionDate: json['lastActionDate'] ?? '',
      messages: (json['messages'] as List?)
              ?.map((e) => TicketMessage.fromJson(e))
              .toList() ??
          [],
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TicketMessage {
  final int msgId;
  final String message;
  final String createDate;
  final bool isAdmin;
  final String senderName;

  TicketMessage({
    required this.msgId,
    required this.message,
    required this.createDate,
    required this.isAdmin,
    required this.senderName,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      msgId: json['msgID'] ?? 0,
      message: json['message'] ?? '',
      createDate: json['createDate'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      senderName: json['senderName'] ?? '',
    );
  }
}

class TicketDetailResponse {
  final bool error;
  final bool success;
  final Ticket? ticket;

  TicketDetailResponse({
    required this.error,
    required this.success,
    this.ticket,
  });

  factory TicketDetailResponse.fromJson(Map<String, dynamic> json) {
    return TicketDetailResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      ticket: json['data']?['ticket'] != null
          ? Ticket.fromJson(json['data']['ticket'])
          : null,
    );
  }
}

class TicketSubjectResponse {
  final bool error;
  final bool success;
  final List<TicketSubject> subjects;

  TicketSubjectResponse({
    required this.error,
    required this.success,
    required this.subjects,
  });

  factory TicketSubjectResponse.fromJson(Map<String, dynamic> json) {
    return TicketSubjectResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      subjects: (json['data']?['subjects'] as List?)
              ?.map((e) => TicketSubject.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TicketSubject {
  final int subjectId;
  final String title;

  TicketSubject({
    required this.subjectId,
    required this.title,
  });

  factory TicketSubject.fromJson(Map<String, dynamic> json) {
    return TicketSubject(
      subjectId: json['subjectID'] ?? 0,
      title: json['subjectTitle'] ?? '',
    );
  }
}

class CreateTicketResponse {
  final bool error;
  final bool success;
  final String? message;

  CreateTicketResponse({
    required this.error,
    required this.success,
    this.message,
  });

  factory CreateTicketResponse.fromJson(Map<String, dynamic> json) {
    return CreateTicketResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['data']?['message'],
    );
  }
}
