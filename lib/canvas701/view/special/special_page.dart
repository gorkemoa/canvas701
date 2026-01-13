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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Görsel ve Boyut Seçin',
                                style: Canvas701Typography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.selectedVariants.length < 5)
                            TextButton.icon(
                              onPressed: () => viewModel.addSlot(),
                              icon: const Icon(CupertinoIcons.add_circled, size: 18),
                              label: const Text('Ekle'),
                              style: TextButton.styleFrom(
                                foregroundColor: Canvas701Colors.primary,
                                textStyle: Canvas701Typography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          'İstediğiniz boyutlar için görselleri yükleyin',
                          style: Canvas701Typography.bodySmall.copyWith(
                            color: Canvas701Colors.textTertiary,
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
                          imagePath: variant.image?.path,
                          onTap: () => viewModel.pickImage(index),
                          onRemove: () => viewModel.removeSlot(index),
                          onSizeChanged: (val) => viewModel.updateSize(index, val),
                          availableSizes: viewModel.availableSizes,
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
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Function(String) onSizeChanged;
  final List<CanvasSize> availableSizes;

  const _ImageUploadCard({
    required this.index,
    this.selectedSize,
    this.imagePath,
    required this.onTap,
    required this.onRemove,
    required this.onSizeChanged,
    required this.availableSizes,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null;

    return Container(
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? Canvas701Colors.primary.withOpacity(0.4) : Canvas701Colors.border,
          width: hasImage ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Preview Area
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasImage ? null : Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: hasImage ? null : Border.all(
                  color: Canvas701Colors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: hasImage
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(imagePath!),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.photo_on_rectangle,
                          color: Canvas701Colors.textTertiary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yükle',
                          style: Canvas701Typography.labelSmall.copyWith(
                            color: Canvas701Colors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Info Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boyut Seçin',
                    style: Canvas701Typography.labelSmall.copyWith(
                      color: Canvas701Colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  availableSizes.isEmpty
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : InkWell(
                          onTap: () => _showIOSPicker(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Canvas701Colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Canvas701Colors.border.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedSize ?? 'Seçiniz',
                                    style: Canvas701Typography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Canvas701Colors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (selectedSize != null)
                                  Text(
                                    availableSizes.firstWhere((s) => s.sizeTitle == selectedSize).sizePrice,
                                    style: Canvas701Typography.labelSmall.copyWith(
                                      color: Canvas701Colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                Icon(
                                  CupertinoIcons.chevron_down,
                                  size: 14,
                                  color: Canvas701Colors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        hasImage ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.arrow_up_circle,
                        size: 14,
                        color: hasImage ? Canvas701Colors.success : Canvas701Colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasImage ? 'Görsel Hazır' : 'Görsel Bekleniyor',
                        style: Canvas701Typography.labelSmall.copyWith(
                          color: hasImage ? Canvas701Colors.success : Canvas701Colors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              CupertinoIcons.trash,
              size: 20,
              color: Canvas701Colors.error.withOpacity(0.7),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Canvas701Typography.labelSmall.copyWith(
            color: Canvas701Colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
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
            hintText: hint,
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
        ),
      ],
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

