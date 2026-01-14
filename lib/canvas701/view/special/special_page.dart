import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/canvas701_theme_data.dart';
import '../widgets/widgets.dart';
import '../../../core/widgets/app_mode_switcher.dart';
import '../../viewmodel/special_viewmodel.dart';
import '../../model/size_model.dart';
import '../../model/type_model.dart';

class SpecialPage extends StatelessWidget {
  const SpecialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpecialViewModel(),
      child: const _SpecialPageContent(),
    );
  }
}

class _SpecialPageContent extends StatelessWidget {
  const _SpecialPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpecialViewModel>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Canvas701Colors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Canvas701Colors.primary,
                elevation: 0,
                toolbarHeight: 45,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                pinned: true,
                title: const AppModeSwitcher(),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Canvas701SearchBar(),
                ),
              ),
              const SliverToBoxAdapter(
                child: _HeroSection(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Canvas701Colors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Görsel ve Boyut Seçin',
                                style: Canvas701Typography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.selectedVariants.length < 5)
                            Material(
                              color: Canvas701Colors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => viewModel.addSlot(),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(CupertinoIcons.plus_circle_fill, size: 16, color: Canvas701Colors.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Ekle',
                                        style: Canvas701Typography.labelMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Canvas701Colors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 46),
                        child: Text(
                          'Sipariş etmek istediğiniz her tablo için bir görsel seçin.',
                          style: Canvas701Typography.bodySmall.copyWith(
                            color: Canvas701Colors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final variant = viewModel.selectedVariants[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ImageUploadCard(
                          index: index,
                          selectedSize: variant.sizeTitle,
                          selectedType: variant.tableType,
                          suggestedType: variant.suggestedType,
                          imagePath: variant.image?.path,
                          onTap: () => viewModel.pickImage(index, context),
                          onRemove: () => viewModel.removeSlot(index),
                          onEdit: () => viewModel.editImage(index, context),
                          onSizeChanged: (val) => viewModel.updateSize(index, val),
                          onTypeChanged: (val) => viewModel.updateType(index, val),
                          availableSizes: viewModel.availableSizes,
                          availableTypes: viewModel.productTypes,
                        ),
                      );
                    },
                    childCount: viewModel.selectedVariants.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: _ContactFormSection(),
              ),
              const SliverToBoxAdapter(
                child: _SubmitSection(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
        if (viewModel.showOnboarding)
          _SpecialOnboarding(
            images: viewModel.onboardingImages,
            onClose: (dontShowAgain) => viewModel.completeOnboarding(dontShowAgain: dontShowAgain),
          ),
      ],
    );
  }
}

class _SpecialOnboarding extends StatefulWidget {
  final List<String> images;
  final Function(bool) onClose;

  const _SpecialOnboarding({
    required this.images,
    required this.onClose,
  });

  @override
  State<_SpecialOnboarding> createState() => _SpecialOnboardingState();
}

class _SpecialOnboardingState extends State<_SpecialOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // Fullscreen PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CupertinoActivityIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  CupertinoIcons.photo,
                  color: Colors.white,
                  size: 40,
                ),
              );
            },
          ),

          // Top Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Progress Bars
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(
                widget.images.length,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: _currentPage >= index ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 16,
            child: IconButton(
              onPressed: () => widget.onClose(_dontShowAgain),
              icon: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 28),
            ),
          ),

          // Navigation Taps
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_currentPage < widget.images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onClose(_dontShowAgain);
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),

          // Content at Bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sana Özel Siparişler',
                  style: Canvas701Typography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Diğer kullanıcılarımızın yaptırdığı bazı tabloları inceleyin. Kalitemizi keşfedin.',
                  style: Canvas701Typography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                // Don't show again toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _dontShowAgain = !_dontShowAgain;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(4),
                          color: _dontShowAgain ? Colors.white : Colors.transparent,
                        ),
                        child: _dontShowAgain
                            ? const Icon(Icons.check, size: 16, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'İleride bir daha gösterme',
                        style: Canvas701Typography.labelSmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < widget.images.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onClose(_dontShowAgain);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == widget.images.length - 1 ? 'BAŞLA' : 'SIRADAKİ',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Canvas701Colors.textSecondary.withOpacity(0.07),
        border: Border(
          bottom: BorderSide(
            color: Canvas701Colors.primary.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.paintbrush_fill,
            color: Canvas701Colors.secondary,
            size: 18,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kendi Tablonu Tasarla',
                style: Canvas701Typography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Canvas701Colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'En sevdiğiniz anıları kaliteli birer sanat eserine dönüştürün.',
                style: Canvas701Typography.labelSmall.copyWith(
                  color: Canvas701Colors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  final int index;
  final String? selectedSize;
  final String? selectedType;
  final String? suggestedType;
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final Function(String) onSizeChanged;
  final Function(String) onTypeChanged;
  final List<CanvasSize> availableSizes;
  final List<ProductType> availableTypes;

  const _ImageUploadCard({
    required this.index,
    this.selectedSize,
    this.selectedType,
    this.suggestedType,
    this.imagePath,
    required this.onTap,
    required this.onRemove,
    required this.onEdit,
    required this.onSizeChanged,
    required this.onTypeChanged,
    required this.availableSizes,
    required this.availableTypes,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null;

    return Container(
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasImage ? Canvas701Colors.primary.withOpacity(0.3) : Canvas701Colors.border.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview Area
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Canvas701Colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Canvas701Colors.border.withOpacity(0.5),
                          ),
                        ),
                        child: hasImage
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(imagePath!),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.camera_rotate,
                                        color: Canvas701Colors.primary,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.photo_on_rectangle,
                                    color: Canvas701Colors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Yükle',
                                    style: Canvas701Typography.labelSmall.copyWith(
                                      color: Canvas701Colors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info Area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tablo Tipi',
                            style: Canvas701Typography.labelSmall.copyWith(
                              color: Canvas701Colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (availableTypes.isEmpty)
                            const CupertinoActivityIndicator(radius: 8)
                          else
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: availableTypes.map((type) {
                                final isSelected = selectedType == type.typeName;
                                return GestureDetector(
                                  onTap: () => onTypeChanged(type.typeName),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Canvas701Colors.primary : Canvas701Colors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? Canvas701Colors.primary : Canvas701Colors.border.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      type.typeName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? Colors.white : Canvas701Colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          if (hasImage && suggestedType != null && selectedType != suggestedType)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 14, color: Colors.amber.shade900),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Görselinize en uygun tip $suggestedType olarak belirlendi.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24), // Space for action button
                  ],
                ),
                const SizedBox(height: 16),
                
                // Size Selection & Edit Button
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showIOSPicker(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Canvas701Colors.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Canvas701Colors.border.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.resize, size: 16, color: Canvas701Colors.textSecondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedSize ?? 'Boyut Seçin',
                                  style: Canvas701Typography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (selectedSize != null && availableSizes.any((s) => s.sizeTitle == selectedSize))
                                Text(
                                  availableSizes.firstWhere((s) => s.sizeTitle == selectedSize).sizePrice,
                                  style: Canvas701Typography.labelMedium.copyWith(
                                    color: Canvas701Colors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              const Icon(CupertinoIcons.chevron_down, size: 14, color: Canvas701Colors.textTertiary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (hasImage) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: onEdit,
                        style: IconButton.styleFrom(
                          backgroundColor: Canvas701Colors.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(CupertinoIcons.slider_horizontal_3, color: Canvas701Colors.primary, size: 20),
                        tooltip: 'Düzenle',
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Status Indicator
                Row(
                  children: [
                    Icon(
                      hasImage ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.info_circle,
                      size: 14,
                      color: hasImage ? Canvas701Colors.success : Canvas701Colors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasImage ? 'Görsel başarıyla yüklendi' : 'Görsel bekleniyor...',
                      style: Canvas701Typography.labelSmall.copyWith(
                        color: hasImage ? Canvas701Colors.success : Canvas701Colors.textTertiary,
                        fontWeight: hasImage ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button (Absolutely Positioned)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: onRemove,
                constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                padding: EdgeInsets.zero,
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Canvas701Colors.error.withOpacity(0.3),
                  size: 24,
                ),
                hoverColor: Canvas701Colors.error.withOpacity(0.1),
                splashRadius: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIOSPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 380,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // Picker Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Canvas701Colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Boyut Seçin',
                      style: Canvas701Typography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Canvas701Colors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Bitti'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.25,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 44,
                  backgroundColor: Colors.transparent,
                  onSelectedItemChanged: (int selectedIndex) {
                    onSizeChanged(availableSizes[selectedIndex].sizeTitle);
                  },
                  children: availableSizes.map((size) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              size.sizeTitle,
                              style: Canvas701Typography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              size.sizePrice,
                              style: Canvas701Typography.bodyMedium.copyWith(
                                color: Canvas701Colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactFormSection extends StatelessWidget {
  const _ContactFormSection();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpecialViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Canvas701Colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'İletişim & Teslimat',
                style: Canvas701Typography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Canvas701Colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Canvas701Colors.border),
            ),
            child: Column(
              children: [
                if (viewModel.userAddresses.isNotEmpty) ...[
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.userAddresses.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isManual = viewModel.selectedUserAddress == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Yeni Adres'),
                              selected: isManual,
                              onSelected: (selected) {
                                if (selected) viewModel.selectAddress(null);
                              },
                              selectedColor: Canvas701Colors.primary.withOpacity(0.1),
                              checkmarkColor: Canvas701Colors.primary,
                              labelStyle: Canvas701Typography.labelSmall.copyWith(
                                color: isManual ? Canvas701Colors.primary : Canvas701Colors.textSecondary,
                                fontWeight: isManual ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: Canvas701Colors.surfaceVariant,
                              side: BorderSide(
                                color: isManual ? Canvas701Colors.primary : Colors.transparent,
                              ),
                            ),
                          );
                        }
                        
                        final address = viewModel.userAddresses[index - 1];
                        final isSelected = viewModel.selectedUserAddress?.addressId == address.addressId;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(address.addressTitle),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) viewModel.selectAddress(address);
                            },
                            selectedColor: Canvas701Colors.primary.withOpacity(0.1),
                            checkmarkColor: Canvas701Colors.primary,
                            labelStyle: Canvas701Typography.labelSmall.copyWith(
                              color: isSelected ? Canvas701Colors.primary : Canvas701Colors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Canvas701Colors.surfaceVariant,
                            side: BorderSide(
                              color: isSelected ? Canvas701Colors.primary : Colors.transparent,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        controller: viewModel.firstNameController,
                        label: 'Ad',
                        hint: 'Adınız',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(
                        controller: viewModel.lastNameController,
                        label: 'Soyad',
                        hint: 'Soyadınız',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormField(
                  controller: viewModel.phoneController,
                  label: 'Telefon',
                  hint: '0 (5XX) XXX XX XX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: CupertinoIcons.phone,
                ),
                const SizedBox(height: 16),
                _FormField(
                  controller: viewModel.emailController,
                  label: 'E-posta',
                  hint: 'ornek@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail,
                ),
                const SizedBox(height: 16),
                _FormField(
                  controller: viewModel.addressController,
                  label: 'Teslimat Adresi',
                  hint: 'Mahalle, sokak, bina no, daire...',
                  maxLines: 3,
                  prefixIcon: CupertinoIcons.location,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: Canvas701Typography.bodyMedium,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: Canvas701Colors.textTertiary)
            : null,
        filled: true,
        fillColor: Canvas701Colors.surfaceVariant,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 0 : 14,
          vertical: maxLines > 1 ? 14 : 12,
        ),
        hintText: label,
        hintStyle: Canvas701Typography.bodyMedium.copyWith(
          color: Canvas701Colors.textTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Canvas701Colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _SubmitSection extends StatelessWidget {
  const _SubmitSection();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpecialViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        children: [
          if (viewModel.errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Canvas701Colors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Canvas701Colors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.exclamationmark_circle, 
                    size: 18, color: Canvas701Colors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: Canvas701Typography.bodySmall.copyWith(
                        color: Canvas701Colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _handleSubmit(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Canvas701Colors.primary.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.paperplane_fill, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Talebi Gönder',
                          style: Canvas701Typography.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Talebiniz bize ulaştıktan sonra en kısa sürede sizinle iletişime geçeceğiz.',
            textAlign: TextAlign.center,
            style: Canvas701Typography.labelSmall.copyWith(
              color: Canvas701Colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, SpecialViewModel viewModel) async {
    final response = await viewModel.submitSpecialTable();
    if (!context.mounted) return;
    
    if (response.success) {
      _showSuccessDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data?.message ?? 'Bir hata oluştu'),
          backgroundColor: Canvas701Colors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Canvas701Colors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 48,
                  color: Canvas701Colors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Talebiniz Alındı',
                style: Canvas701Typography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'En kısa sürede sizinle iletişime geçeceğiz. Teşekkür ederiz!',
                textAlign: TextAlign.center,
                style: Canvas701Typography.bodyMedium.copyWith(
                  color: Canvas701Colors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Canvas701Colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Tamam'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

