import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../theme/canvas701_theme_data.dart';

class ImageFilterSheet extends StatefulWidget {
  final File imageFile;

  const ImageFilterSheet({super.key, required this.imageFile});

  @override
  State<ImageFilterSheet> createState() => _ImageFilterSheetState();
}

class _ImageFilterSheetState extends State<ImageFilterSheet> {
  bool _isProcessing = false;
  String? _selectedFilter;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Orijinal', 'type': 'none', 'matrix': [
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]},
    {'name': 'Siyah Beyaz', 'type': 'grayscale', 'matrix': [
      0.2126, 0.7152, 0.0722, 0.0, 0.0,
      0.2126, 0.7152, 0.0722, 0.0, 0.0,
      0.2126, 0.7152, 0.0722, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]},
    {'name': 'Sepya', 'type': 'sepia', 'matrix': [
      0.393, 0.769, 0.189, 0.0, 0.0,
      0.349, 0.686, 0.168, 0.0, 0.0,
      0.272, 0.534, 0.131, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]},
    {'name': 'Soğuk', 'type': 'cool', 'matrix': [
      0.9, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.9, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.2, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]},
    {'name': 'Sıcak', 'type': 'warm', 'matrix': [
      1.2, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.8, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ]},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'none';
  }

  Future<void> _applyAndFinish() async {
    if (_selectedFilter == 'none') {
      Navigator.pop(context, widget.imageFile);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final bytes = await widget.imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        img.Image filteredImage;
        
        switch (_selectedFilter) {
          case 'grayscale':
            filteredImage = img.grayscale(decodedImage);
            break;
          case 'sepia':
            filteredImage = img.sepia(decodedImage);
            break;
          case 'warm':
             filteredImage = img.adjustColor(decodedImage, exposure: 0.1, saturation: 1.2);
            break;
          case 'cool':
             filteredImage = img.adjustColor(decodedImage, exposure: -0.05, saturation: 0.8);
            break;
          default:
            filteredImage = decodedImage;
        }

        final tempDir = await getTemporaryDirectory();
        final filteredFile = File('${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await filteredFile.writeAsBytes(img.encodeJpg(filteredImage));
        
        if (mounted) Navigator.pop(context, filteredFile);
      } else {
        if (mounted) Navigator.pop(context, widget.imageFile);
      }
    } catch (e) {
      debugPrint('Error applying filter: $e');
      if (mounted) Navigator.pop(context, widget.imageFile);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Canvas701Colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtre Seçin',
                    style: Canvas701Typography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_isProcessing)
                    const CupertinoActivityIndicator()
                  else
                    TextButton(
                      onPressed: _applyAndFinish,
                      child: const Text('Bitti', style: TextStyle(fontWeight: FontWeight.bold, color: Canvas701Colors.primary)),
                    ),
                ],
              ),
            ),
            
            // Image Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      List<double>.from(_filters.firstWhere((f) => f['type'] == _selectedFilter)['matrix'] as List),
                    ),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Filter List
            Container(
              height: 140,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter['type'];
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter['type']),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Canvas701Colors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.matrix(
                                    List<double>.from(filter['matrix'] as List),
                                  ),
                                  child: Image.file(
                                    widget.imageFile,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            filter['name'],
                            style: Canvas701Typography.labelSmall.copyWith(
                              color: isSelected ? Canvas701Colors.primary : Canvas701Colors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}
