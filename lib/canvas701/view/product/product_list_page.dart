import 'package:canvas701/canvas701/viewmodel/favorites_viewmodel.dart';
import 'package:canvas701/canvas701/viewmodel/category_viewmodel.dart';
import 'package:canvas701/canvas701/viewmodel/product_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../../model/category_response.dart';
import '../../model/filter_list_response.dart';
import '../../theme/canvas701_theme_data.dart';
import '../widgets/widgets.dart';
import '../../services/product_service.dart';
import '../../model/product_models.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final String title;
  final int? categoryId;
  final String? sortKey;
  final String? typeKey;
  final String? searchText;

  const ProductListPage({
    super.key,
    required this.title,
    this.categoryId,
    this.sortKey,
    this.typeKey,
    this.searchText,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<ApiProduct> _products = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  String? _errorMessage;

  // Filter states
  String? _selectedSortKey;
  String? _selectedTypeKey;
  List<int> _selectedCategoryIds = [];
  int _activeFilterCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchText ?? '';
    _selectedSortKey = widget.sortKey;
    _selectedTypeKey = widget.typeKey;
    _selectedCategoryIds =
        widget.categoryId != null ? [widget.categoryId!] : [];
    _updateActiveFilterCount();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
      // Filtreleri yükle
      context.read<ProductViewModel>().fetchFilters();
      context.read<CategoryViewModel>().fetchCategories();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _fetchProducts(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchProducts();
    }
  }

  void _updateActiveFilterCount() {
    int count = 0;
    if (_selectedSortKey != null && _selectedSortKey != 'sortDefault') count++;
    if (_selectedTypeKey != null && _selectedTypeKey!.isNotEmpty) count++;

    // Kategori kontrolü
    final bool hasDifferentCategory =
        _selectedCategoryIds.length != (widget.categoryId != null ? 1 : 0) ||
            (widget.categoryId != null &&
                !_selectedCategoryIds.contains(widget.categoryId));

    if (_selectedCategoryIds.isNotEmpty && hasDifferentCategory) {
      count++;
    }

    setState(() => _activeFilterCount = count);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedSortKey: _selectedSortKey,
        selectedTypeKey: _selectedTypeKey,
        selectedCategoryIds: _selectedCategoryIds,
        initialCategoryId: widget.categoryId,
        onApply: (sortKey, typeKey, categoryIds) {
          setState(() {
            _selectedSortKey = sortKey;
            _selectedTypeKey = typeKey;
            _selectedCategoryIds = categoryIds;
          });
          _updateActiveFilterCount();
          _fetchProducts(refresh: true);
        },
        onReset: () {
          setState(() {
            _selectedSortKey = widget.sortKey;
            _selectedTypeKey = widget.typeKey;
            _selectedCategoryIds =
                widget.categoryId != null ? [widget.categoryId!] : [];
          });
          _updateActiveFilterCount();
          _fetchProducts(refresh: true);
        },
      ),
    );
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      // products.clear() yapmıyoruz, UI'da patlama olmasın diye.
      // Aşağıda başarılı olursa replace ederiz.
    }

    if (!_hasNextPage) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _productService.getAllProducts(
        catID: _selectedCategoryIds.isNotEmpty
            ? _selectedCategoryIds
            : (widget.categoryId != null ? [widget.categoryId!] : []),
        sortKey: _selectedSortKey ?? widget.sortKey ?? 'sortDefault',
        typeKey: _selectedTypeKey ?? widget.typeKey ?? '',
        searchText: _searchController.text,
        page: _currentPage,
      );

      if (response.success && response.data != null) {
        if (mounted) {
          context.read<FavoritesViewModel>().updateFavoritesFromProducts(
            response.data!.products,
          );
        }

        setState(() {
          if (refresh) {
            _products.clear();
          }
          _products.addAll(response.data!.products);
          _hasNextPage = response.data!.hasNextPage;
          if (_hasNextPage) _currentPage++;
        });
      } else {
        setState(() => _errorMessage = 'Ürünler yüklenemedi');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filtrele',
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Canvas701SearchBar(
            controller: _searchController,
            onSubmitted: _onSearch,
            onClear: () {
              _searchController.clear();
              _fetchProducts(refresh: true);
            },
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchProducts(refresh: true),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? '"${_searchController.text}" için sonuç bulunamadı.'
              : 'Ürün bulunamadı.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchProducts(refresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Active Filters Chips
          if (_activeFilterCount > 0)
            SliverToBoxAdapter(child: _buildActiveFiltersBar()),
          SliverPadding(
            padding: const EdgeInsets.all(Canvas701Spacing.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.5,
                crossAxisSpacing: Canvas701Spacing.md,
                mainAxisSpacing: Canvas701Spacing.md,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final apiProduct = _products[index];
                final product = Product.fromApi(apiProduct);

                return Consumer<FavoritesViewModel>(
                  builder: (context, favViewModel, child) {
                    final isFav = favViewModel.isFavorite(apiProduct.productID);
                    return ProductCard(
                      product: product,
                      isFavorite: isFav,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      onFavorite: () {
                        favViewModel.toggleFavorite(apiProduct.productID);
                      },
                    );
                  },
                );
              }, childCount: _products.length),
            ),
          ),
          if (_hasNextPage && _isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Canvas701Spacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: Canvas701Spacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        Canvas701Spacing.sm,
        Canvas701Spacing.md,
        0,
      ),
      child: Consumer2<ProductViewModel, CategoryViewModel>(
        builder: (context, productVm, categoryVm, child) {
          final chips = <Widget>[];

          // Sort chip
          if (_selectedSortKey != null && _selectedSortKey != 'sortDefault') {
            final sortItem = productVm.filters?.sorts.firstWhere(
              (s) => s.key == _selectedSortKey,
              orElse: () => FilterItem(key: '', value: ''),
            );
            if (sortItem != null && sortItem.value.isNotEmpty) {
              chips.add(
                _buildFilterChip(
                  label: sortItem.value,
                  icon: Icons.sort_rounded,
                  onRemove: () {
                    setState(() => _selectedSortKey = widget.sortKey);
                    _updateActiveFilterCount();
                    _fetchProducts(refresh: true);
                  },
                ),
              );
            }
          }

          // Type chip
          if (_selectedTypeKey != null && _selectedTypeKey!.isNotEmpty) {
            final typeItem = productVm.filters?.types.firstWhere(
              (t) => t.key == _selectedTypeKey,
              orElse: () => FilterItem(key: '', value: ''),
            );
            if (typeItem != null && typeItem.value.isNotEmpty) {
              chips.add(
                _buildFilterChip(
                  label: typeItem.value,
                  icon: Icons.label_rounded,
                  onRemove: () {
                    setState(() => _selectedTypeKey = widget.typeKey);
                    _updateActiveFilterCount();
                    _fetchProducts(refresh: true);
                  },
                ),
              );
            }
          }

          // Category Chips
          final bool hasDifferentCategory = _selectedCategoryIds.length !=
                  (widget.categoryId != null ? 1 : 0) ||
              (widget.categoryId != null &&
                  !_selectedCategoryIds.contains(widget.categoryId));

          if (hasDifferentCategory && _selectedCategoryIds.isNotEmpty) {
            for (final catId in _selectedCategoryIds) {
              final category = categoryVm.categories.firstWhere(
                (c) => c.catID == catId,
                orElse: () => ApiCategory(
                  catID: 0,
                  catName: '',
                  catMainImage: '',
                  catThumbImage: '',
                  catThumbImage1: '',
                  catThumbImage2: '',
                ),
              );
              if (category.catName.isNotEmpty) {
                chips.add(
                  _buildFilterChip(
                    label: category.catName,
                    icon: Icons.category_rounded,
                    onRemove: () {
                      setState(() {
                        _selectedCategoryIds.remove(catId);
                        if (_selectedCategoryIds.isEmpty &&
                            widget.categoryId != null) {
                          _selectedCategoryIds = [widget.categoryId!];
                        }
                      });
                      _updateActiveFilterCount();
                      _fetchProducts(refresh: true);
                    },
                  ),
                );
              }
            }
          }

          if (chips.isEmpty) return const SizedBox.shrink();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...chips.map(
                  (chip) => Padding(
                    padding: const EdgeInsets.only(right: Canvas701Spacing.xs),
                    child: chip,
                  ),
                ),
                // Clear all button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSortKey = widget.sortKey;
                      _selectedTypeKey = widget.typeKey;
                      _selectedCategoryIds =
                          widget.categoryId != null ? [widget.categoryId!] : [];
                    });
                    _updateActiveFilterCount();
                    _fetchProducts(refresh: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Canvas701Colors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Canvas701Colors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all_rounded,
                          size: 16,
                          color: Canvas701Colors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Temizle',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Canvas701Colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Canvas701Colors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Canvas701Colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Canvas701Colors.primary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),

              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Canvas701Colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final String? selectedSortKey;
  final String? selectedTypeKey;
  final List<int> selectedCategoryIds;
  final int? initialCategoryId;
  final Function(String?, String?, List<int>) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    this.selectedSortKey,
    this.selectedTypeKey,
    required this.selectedCategoryIds,
    this.initialCategoryId,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _sortKey;
  late String? _typeKey;
  late List<int> _categoryIds;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _sortKey = widget.selectedSortKey;
    _typeKey = widget.selectedTypeKey;
    _categoryIds = List.from(widget.selectedCategoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildContent()),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Canvas701Colors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Canvas701Colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Expanded(
            child: Text(
              'Filtrele & Sırala',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Canvas701Colors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Canvas701Colors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Sıralama', 'Tip', 'Kategori'];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Canvas701Colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Canvas701Colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSortOptions();
      case 1:
        return _buildTypeOptions();
      case 2:
        return _buildCategoryOptions();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSortOptions() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        final sorts = viewModel.filters?.sorts ?? [];
        if (sorts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sorts.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final sort = sorts[index];
            final isSelected = _sortKey == sort.key;

            return _buildFilterTile(
              title: sort.value,
              icon: _getSortIcon(sort.key),
              isSelected: isSelected,
              onTap: () => setState(() => _sortKey = sort.key),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeOptions() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        final types = viewModel.filters?.types ?? [];
        if (types.isEmpty) {
          return const Center(
            child: Text(
              'Tip filtresi bulunamadı',
              style: TextStyle(color: Canvas701Colors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: types.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final type = types[index];
            final isSelected = _typeKey == type.key;

            return _buildFilterTile(
              title: type.value,
              icon: _getTypeIcon(type.key),
              isSelected: isSelected,
              onTap: () => setState(() => _typeKey = type.key),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryOptions() {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        final categories = viewModel.categories;
        if (viewModel.isLoading && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categories.isEmpty) {
          return const Center(
            child: Text(
              'Kategori bulunamadı',
              style: TextStyle(color: Canvas701Colors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isAllSelected = _categoryIds.isEmpty ||
                  (_categoryIds.length == 1 && _categoryIds.first == 0);
              return _buildFilterTile(
                title: 'Tüm Kategoriler',
                icon: Icons.category_rounded,
                isSelected: isAllSelected,
                onTap: () => setState(() => _categoryIds = [0]),
              );
            }

            final category = categories[index - 1];
            final isSelected = _categoryIds.contains(category.catID);

            return _buildCategoryTile(
              category: category,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (_categoryIds.contains(0)) {
                    _categoryIds.clear();
                  }

                  if (isSelected) {
                    _categoryIds.remove(category.catID);
                    if (_categoryIds.isEmpty) {
                      _categoryIds.add(0);
                    }
                  } else {
                    _categoryIds.add(category.catID);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Canvas701Colors.primary.withOpacity(0.1)
                      : Canvas701Colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Canvas701Colors.primary
                      : Canvas701Colors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Canvas701Colors.textPrimary,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Canvas701Colors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Canvas701Colors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required ApiCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: Canvas701Colors.primary, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  category.catThumbImage1,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Canvas701Colors.surfaceVariant,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Canvas701Colors.textTertiary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.catName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Canvas701Colors.textPrimary,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Canvas701Colors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Canvas701Colors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Canvas701Colors.border.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                widget.onReset();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Sıfırla'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Canvas701Colors.textSecondary,
                side: const BorderSide(color: Canvas701Colors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onApply(_sortKey, _typeKey, _categoryIds);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Uygula'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSortIcon(String key) {
    switch (key) {
      case 'sortDefault':
        return Icons.star_rounded;
      case 'sortNewToOld':
        return Icons.new_releases_rounded;
      case 'sortOldToNew':
        return Icons.history_rounded;
      case 'sortPriceAsc':
        return Icons.arrow_upward_rounded;
      case 'sortPriceDesc':
        return Icons.arrow_downward_rounded;
      case 'sortBestSellers':
        return Icons.trending_up_rounded;
      case 'sortNameAsc':
        return Icons.sort_by_alpha_rounded;
      case 'sortNameDesc':
        return Icons.sort_by_alpha_rounded;
      default:
        return Icons.sort_rounded;
    }
  }

  IconData _getTypeIcon(String key) {
    switch (key.toLowerCase()) {
      case 'new':
        return Icons.fiber_new_rounded;
      case 'bestseller':
        return Icons.local_fire_department_rounded;
      case 'discount':
        return Icons.local_offer_rounded;
      case 'featured':
        return Icons.star_rounded;
      default:
        return Icons.label_rounded;
    }
  }
}
