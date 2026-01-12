import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../../theme/canvas701_theme_data.dart';
import '../../../viewmodel/ticket_viewmodel.dart';
import '../../../model/ticket_model.dart';

class TicketDetailPage extends StatefulWidget {
  final int ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<File> _selectedFiles = [];
  final List<String> _base64Files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketViewModel>().fetchTicketDetail(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          if (file.path != null) {
            final f = File(file.path!);
            final bytes = await f.readAsBytes();
            final base64String = base64Encode(bytes);

            setState(() {
              _selectedFiles.add(f);
              _base64Files.add(base64String);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _base64Files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text(
          'Talep Detayı',
          style: TextStyle(
            color: Canvas701Colors.background,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        iconTheme: const IconThemeData(color: Canvas701Colors.background),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TicketViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.selectedTicket == null) {
            return const Center(
              child: CircularProgressIndicator(color: Canvas701Colors.primary),
            );
          }

          if (viewModel.errorMessage != null &&
              viewModel.selectedTicket == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Canvas701Colors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: Canvas701Typography.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        viewModel.fetchTicketDetail(widget.ticketId),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final ticket = viewModel.selectedTicket;
          if (ticket == null) {
            return const Center(child: Text('Talep bulunamadı.'));
          }

          return Column(
            children: [
              _buildTicketInfo(ticket),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: ticket.messages.length,
                  itemBuilder: (context, index) {
                    final message = ticket.messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
              ),
              if (_selectedFiles.isNotEmpty) _buildSelectedFilesList(),
              _buildReplyInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketInfo(Ticket ticket) {
    Color statusColor;
    try {
      statusColor = Color(
        int.parse(ticket.statusColor.replaceAll('#', '0xFF')),
      );
    } catch (e) {
      statusColor = Canvas701Colors.primary;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Canvas701Colors.surface,
        border: Border(bottom: BorderSide(color: Canvas701Colors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.ticketTitle,
                  style: Canvas701Typography.titleLarge.copyWith(
                    color: Canvas701Colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ticket.subjectTitle} • #${ticket.ticketId}',
                  style: Canvas701Typography.bodySmall.copyWith(
                    color: Canvas701Colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ticket.statusTitle.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Canvas701Colors.surface,
        border: Border(top: BorderSide(color: Canvas701Colors.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          final String extension = file.path.split('.').last.toLowerCase();
          final bool isPdf = extension == 'pdf';

          return Container(
            margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Canvas701Colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Canvas701Colors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.image,
                  size: 18,
                  color: isPdf ? Canvas701Colors.error : Canvas701Colors.primary,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    file.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _removeFile(index),
                  child: const Icon(Icons.close,
                      size: 16, color: Canvas701Colors.textTertiary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        border: const Border(top: BorderSide(color: Canvas701Colors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickFiles,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Canvas701Colors.textSecondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                style: Canvas701Typography.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  hintStyle: TextStyle(
                    color: Canvas701Colors.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final message = _messageController.text.trim();
              if (message.isNotEmpty || _base64Files.isNotEmpty) {
                final viewModel = context.read<TicketViewModel>();
                final response = await viewModel.sendMessage(
                  ticketId: widget.ticketId,
                  message: message.isEmpty ? 'Dosya eki' : message,
                  files: _base64Files,
                );

                if (response.success) {
                  _messageController.clear();
                  setState(() {
                    _selectedFiles.clear();
                    _base64Files.clear();
                  });
                  if (mounted) {
                    FocusScope.of(context).unfocus();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.message ?? 'Mesaj gönderilemedi'),
                        backgroundColor: Canvas701Colors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Canvas701Colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: context.watch<TicketViewModel>().isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final TicketMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = !message.isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Canvas701Colors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.support_agent,
                    size: 14,
                    color: Canvas701Colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                isMe ? 'Siz' : message.senderName,
                style: Canvas701Typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Canvas701Colors.textPrimary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.createDate,
                style: Canvas701Typography.bodySmall.copyWith(
                  color: Canvas701Colors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isMe ? Canvas701Colors.primary : Canvas701Colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isMe ? null : Border.all(color: Canvas701Colors.divider),
            ),
            child: Text(
              message.message,
              style: Canvas701Typography.bodyMedium.copyWith(
                color: isMe ? Colors.white : Canvas701Colors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
