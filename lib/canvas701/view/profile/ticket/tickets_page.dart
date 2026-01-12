import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/canvas701_theme_data.dart';
import '../../../viewmodel/ticket_viewmodel.dart';
import '../../../model/ticket_model.dart';
import 'create_ticket_page.dart';
import 'ticket_detail_page.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketViewModel>().fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text(
          'Destek Taleplerim',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TicketViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchTickets(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Canvas701Colors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz bir destek talebiniz bulunmuyor.',
                    style: TextStyle(color: Canvas701Colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTicketPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Canvas701Colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Destek Talebi Oluştur'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchTickets(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.tickets.length,
              itemBuilder: (context, index) {
                final ticket = viewModel.tickets[index];
                return _TicketCard(ticket: ticket);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTicketPage(),
            ),
          );
        },
        backgroundColor: Canvas701Colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    try {
      statusColor = Color(
        int.parse(ticket.statusColor.replaceAll('#', '0xFF')),
      );
    } catch (e) {
      statusColor = Canvas701Colors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Canvas701Colors.divider),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailPage(ticketId: ticket.ticketId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    ticket.createDate,
                    style: Canvas701Typography.bodySmall.copyWith(
                      color: Canvas701Colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.ticketTitle,
                style: Canvas701Typography.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                ticket.subjectTitle,
                style: Canvas701Typography.bodyMedium.copyWith(
                  color: Canvas701Colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
