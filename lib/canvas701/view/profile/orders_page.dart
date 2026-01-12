import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/order_models.dart';
import '../../services/order_service.dart';
import '../../theme/canvas701_theme_data.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  UserOrdersResponse? _ordersResponse;
  List<OrderStatusModel> _statusList = [];
  String? _selectedStatusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Future.wait ile paralel istek at (Performans artışı)
      final results = await Future.wait([
        _orderService.getOrders(),
        _orderService.getOrderStatusList(),
      ]);

      final ordersResponse = results[0] as UserOrdersResponse;
      final statusResponse = results[1] as OrderStatusListResponse;

      setState(() {
        _isLoading = false;

        if (ordersResponse.isSuccess) {
          _ordersResponse = ordersResponse;
        } else {
          _errorMessage = ordersResponse.message;
        }

        if (statusResponse.isSuccess) {
          _statusList = statusResponse.statusList;
        }
        // Status listesi kritik hata sebebi değil, orders geldiyse devam et
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Veriler yüklenirken bir hata oluştu';
      });
    }
  }

  List<UserOrder> get _allOrders => _ordersResponse?.orders ?? [];

  List<UserOrder> get _filteredOrders {
    var orders = _allOrders;

    // Durum filtreleme
    if (_selectedStatusFilter != null) {
      orders = orders
          .where((order) => order.orderStatus == _selectedStatusFilter)
          .toList();
    }

    // Arama filtreleme
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        final orderCodeMatch = order.orderCode.toLowerCase().contains(
          _searchQuery,
        );
        final productMatch = order.products.any(
          (product) => product.productName.toLowerCase().contains(_searchQuery),
        );
        final statusMatch = order.orderStatus.toLowerCase().contains(
          _searchQuery,
        );
        return orderCodeMatch || productMatch || statusMatch;
      }).toList();
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Canvas701Colors.background,
          ),
        ),
        title: Text(
          'Siparişlerim',
          style: Canvas701Typography.headlineSmall.copyWith(fontSize: 18, color: Canvas701Colors.background),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Canvas701Colors.surface,
            child: Column(
              children: [
                _buildSearchBar(),
                _buildStatusFilter(),
                const SizedBox(height: Canvas701Spacing.sm),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : _buildOrderList(_filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Canvas701Colors.primary,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color: Canvas701Colors.textTertiary,
          ),
          const SizedBox(height: Canvas701Spacing.md),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            style: Canvas701Typography.bodyMedium.copyWith(
              color: Canvas701Colors.textSecondary,
            ),
          ),
          const SizedBox(height: Canvas701Spacing.md),
          TextButton(
            onPressed: _loadData,
            style: TextButton.styleFrom(
              foregroundColor: Canvas701Colors.primary,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<UserOrder> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Canvas701Colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(Canvas701Spacing.md),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: Canvas701Spacing.sm),
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    final emptyMessage =
        _ordersResponse?.data?.emptyMessage ?? 'Henüz siparişiniz yok';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Canvas701Colors.textTertiary,
          ),
          const SizedBox(height: Canvas701Spacing.md),
          Text(
            emptyMessage,
            style: Canvas701Typography.bodyMedium.copyWith(
              color: Canvas701Colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(UserOrder order) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderID: order.orderID,
              orderCode: order.orderCode,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(Canvas701Spacing.md),
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: Canvas701Radius.cardRadius,
          border: Border.all(color: Canvas701Colors.border),
          boxShadow: const [Canvas701Shadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tarih ve Toplam | Detaylar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderDate,
                      style: Canvas701Typography.bodySmall.copyWith(
                        color: Canvas701Colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: Canvas701Spacing.xxs),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Toplam: ',
                            style: Canvas701Typography.bodySmall.copyWith(
                              fontSize: 11,
                              color: Canvas701Colors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: order.orderAmount,
                            style: Canvas701Typography.labelMedium.copyWith(
                              color: Canvas701Colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(
                          orderID: order.orderID,
                          orderCode: order.orderCode,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Detaylar',
                          style: Canvas701Typography.labelMedium.copyWith(
                            color: Canvas701Colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Canvas701Colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Canvas701Spacing.sm,
              ),
              child: const Divider(height: 1, color: Canvas701Colors.divider),
            ),

            // Durum satırı
            Row(
              children: [
                Icon(
                  order.isDelivered
                      ? Icons.check_circle_outline
                      : Icons.local_shipping_outlined,
                  color: _getStatusColor(order),
                  size: 16,
                ),
                const SizedBox(width: Canvas701Spacing.xs),
                Expanded(
                  child: Text(
                    order.orderStatus,
                    style: Canvas701Typography.labelMedium.copyWith(
                      color: _getStatusColor(order),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Değerlendir butonu (teslim edildiyse)
                if (order.isDelivered && !order.canTrack)
                  _buildOutlinedButton(
                    'Değerlendir',
                    Icons.star_border,
                    Canvas701Colors.primary,
                    () {
                      // TODO: Review action
                    },
                  ),
              ],
            ),

            const SizedBox(height: Canvas701Spacing.sm),

            // Ürün görselleri ve Bilgiler (Yan yana)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Görselleri (Stack ile üst üste, sabit genişlik)
                SizedBox(
                  width: 50,
                  height: 56,
                  child: order.products.isEmpty
                      ? const SizedBox()
                      : order.products.length == 1
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: _buildProductThumbnail(
                                order.products.first.productImage,
                                width: 42,
                                height: 56,
                              ),
                            )
                          : Stack(
                              children: [
                                // İkinci Ürün (Arkada)
                                Positioned(
                                  right: 0,
                                  top: 4,
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: _buildProductThumbnail(
                                      order.products[1].productImage,
                                      width: 36,
                                      height: 48,
                                    ),
                                  ),
                                ),
                                // Birinci Ürün (Önde)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: _buildProductThumbnail(
                                    order.products.first.productImage,
                                    width: 36,
                                    height: 50,
                                  ),
                                ),
                                // Ekstra ürün sayısı (+X)
                                if (order.products.length > 2)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Canvas701Colors.primary,
                                        borderRadius: BorderRadius.circular(
                                            Canvas701Radius.xs),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '+${order.products.length - 1}',
                                        style: Canvas701Typography.labelSmall
                                            .copyWith(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                ),
                const SizedBox(width: Canvas701Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Footer bilgisi: durum açıklaması
                      Text(
                        order.orderStatusText,
                        textAlign: TextAlign.right,
                        style: Canvas701Typography.bodySmall.copyWith(
                          fontSize: 10,
                          color: Canvas701Colors.textTertiary,
                        ),
                      ),
                      // Kargo bilgisi
                      if (order.orderCargo.isNotEmpty) ...[
                        const SizedBox(height: Canvas701Spacing.xxs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                order.orderCargo +
                                    (order.orderTrackingNo.isNotEmpty
                                        ? ' • ${order.orderTrackingNo}'
                                        : ''),
                                textAlign: TextAlign.right,
                                style: Canvas701Typography.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: Canvas701Colors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 10,
                              color: Canvas701Colors.textTertiary,
                            ),
                          ],
                        ),
                      ],
                      // Ödeme yöntemi
                      if (order.orderPayment.isNotEmpty) ...[
                        const SizedBox(height: Canvas701Spacing.xxs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                order.orderPayment,
                                textAlign: TextAlign.right,
                                style: Canvas701Typography.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: Canvas701Colors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.payment_outlined,
                              size: 10,
                              color: Canvas701Colors.textTertiary,
                            ),
                          ],
                        ),
                      ],
                      // İptal durumu
                      if (order.isCanceled) ...[
                        const SizedBox(height: Canvas701Spacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Canvas701Spacing.xs,
                            vertical: Canvas701Spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: Canvas701Colors.error.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(Canvas701Radius.xs),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sipariş iptal edildi',
                                style: Canvas701Typography.labelSmall.copyWith(
                                  color: Canvas701Colors.error,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.cancel_outlined,
                                size: 10,
                                color: Canvas701Colors.error,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(String imageUrl,
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Canvas701Colors.border),
        borderRadius: BorderRadius.circular(Canvas701Radius.xs),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported,
              size: 12,
              color: Canvas701Colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(UserOrder order) {
    if (order.isCanceled) return Canvas701Colors.error;

    // API'den gelen status listesinden renk bul
    final status = _statusList
        .where((s) => s.statusName == order.orderStatus)
        .firstOrNull;
    if (status != null && status.statusColor.isNotEmpty) {
      return _parseColor(status.statusColor);
    }

    // Fallback: teslim edildi mi kontrolü
    if (order.isDelivered) return Canvas701Colors.success;

    return Canvas701Colors.textSecondary;
  }

  Widget _buildOutlinedButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Canvas701Spacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Canvas701Radius.xs),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: Canvas701Spacing.xs,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          setState(() => _searchQuery = v.toLowerCase());
        },
        decoration: InputDecoration(
          hintText: 'Sipariş Ara',
          hintStyle: Canvas701Typography.bodySmall.copyWith(
            color: Canvas701Colors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Canvas701Colors.textTertiary,
            size: 20,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: Canvas701Spacing.sm,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Canvas701Colors.textTertiary,
                    size: 14,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Canvas701Radius.sm),
            borderSide: const BorderSide(color: Canvas701Colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Canvas701Radius.sm),
            borderSide: const BorderSide(color: Canvas701Colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Canvas701Radius.sm),
            borderSide: const BorderSide(color: Canvas701Colors.primary),
          ),
        ),
        style: Canvas701Typography.bodyMedium.copyWith(
          color: Canvas701Colors.textPrimary,
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    if (colorString.isEmpty) return Canvas701Colors.textTertiary;
    try {
      var hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      if (hexColor.length == 8) {
        return Color(int.parse('0x$hexColor'));
      }
    } catch (e) {
      // Color parse error
    }
    return Canvas701Colors.textTertiary;
  }

  Widget _buildStatusFilter() {
    if (_statusList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Canvas701Colors.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.sm),
        itemCount: _statusList.length + 1,
        itemBuilder: (context, index) {
          final isAllFilter = index == 0;
          final filterValue = isAllFilter ? null : _statusList[index - 1].statusName;
          final statusName = isAllFilter
              ? 'Tümü'
              : _statusList[index - 1].statusName;
          final isSelected = _selectedStatusFilter == filterValue;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedStatusFilter = filterValue;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Canvas701Spacing.xs,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Canvas701Spacing.xs,
              ),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border(
                        bottom: BorderSide(
                          color: isAllFilter
                              ? Canvas701Colors.primary
                              : _parseColor(_statusList[index - 1].statusColor),
                          width: 2,
                        ),
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                statusName,
                style: isSelected
                    ? Canvas701Typography.labelLarge.copyWith(
                        color: isAllFilter
                            ? Canvas701Colors.primary
                            : _parseColor(_statusList[index - 1].statusColor),
                        fontSize: 13,
                      )
                    : Canvas701Typography.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}
