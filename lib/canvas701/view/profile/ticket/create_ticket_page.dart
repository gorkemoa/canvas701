import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  final List<File> _selectedFiles = [];
  final List<String> _base64Files = [];

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
        files: _base64Files,
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

            final extension = file.extension?.toLowerCase() ?? '';
            String mimeType = 'image/jpeg';
            if (extension == 'pdf') {
              mimeType = 'application/pdf';
            } else if (extension == 'png') {
              mimeType = 'image/png';
            } else if (extension == 'jpg' || extension == 'jpeg') {
              mimeType = 'image/jpeg';
            }

            final formattedBase64 = 'data:$mimeType;base64,$base64String';

            setState(() {
              _selectedFiles.add(f);
              _base64Files.add(formattedBase64);
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
          'Yeni Destek Talebi',
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dosya Ekleri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Canvas701Colors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file, size: 20),
                        label: const Text('Dosya Ekle'),
                        style: TextButton.styleFrom(
                          foregroundColor: Canvas701Colors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedFiles.isNotEmpty)
                    Container(
                      height: 100,
                      margin: const EdgeInsets.only(top: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedFiles.length,
                        itemBuilder: (context, index) {
                          final file = _selectedFiles[index];
                          final isPdf = file.path.toLowerCase().endsWith('.pdf');

                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Canvas701Colors.divider),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: isPdf
                                      ? const Center(
                                          child: Icon(Icons.picture_as_pdf,
                                              size: 40, color: Colors.red),
                                        )
                                      : Image.file(
                                          file,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeFile(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
