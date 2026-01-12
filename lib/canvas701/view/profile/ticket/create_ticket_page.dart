import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/canvas701_theme_data.dart';
import '../../../viewmodel/ticket_viewmodel.dart';
import '../../../model/ticket_model.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  TicketSubject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketViewModel>().fetchSubjects();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedSubject != null) {
      final viewModel = context.read<TicketViewModel>();
      final response = await viewModel.createTicket(
        title: _titleController.text,
        subjectId: _selectedSubject!.subjectId,
        message: _messageController.text,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destek talebiniz oluşturuldu.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Bir hata oluştu.'),
              backgroundColor: Canvas701Colors.error,
            ),
          );
        }
      }
    } else if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir konu seçin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text('Yeni Destek Talebi'),
        backgroundColor: Canvas701Colors.surface,
        foregroundColor: Canvas701Colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TicketViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Konu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Canvas701Colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TicketSubject>(
                    value: _selectedSubject,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Canvas701Colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Canvas701Colors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Canvas701Colors.divider),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: viewModel.subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                    hint: const Text('Konu Seçiniz'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Başlık',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Canvas701Colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Talebinizin özeti',
                      filled: true,
                      fillColor: Canvas701Colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Canvas701Colors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Canvas701Colors.divider),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir başlık girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mesajınız',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Canvas701Colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Lütfen detaylı bilgi verin',
                      filled: true,
                      fillColor: Canvas701Colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Canvas701Colors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Canvas701Colors.divider),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir mesaj girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Canvas701Colors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Gönder',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
