import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../model/order_models.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderID;
  final String orderCode;

  const OrderDetailPage({
    super.key,
    required this.orderID,
    required this.orderCode,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _orderService = OrderService();
  final UserService _userService = UserService();
  final TextEditingController _cancelDescController = TextEditingController();
  UserOrderDetail? _orderDetail;
  List<OrderCancelType> _cancelTypes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
    _fetchCancelTypes();
  }

  @override
  void dispose() {
    _cancelDescController.dispose();
    super.dispose();
  }

  Future<void> _fetchCancelTypes() async {
    try {
      final response = await _orderService.getCancelTypes();
      if (mounted && response.isSuccess) {
        setState(() {
          _cancelTypes = response.types;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cancel types: $e');
    }
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _orderService.getOrderDetail(widget.orderID);

      if (mounted) {
        setState(() {
          if (response.isSuccess) {
            _orderDetail = response.data;
          } else {
            _errorMessage = 'Sipariş detayları yüklenemedi.';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Bir hata oluştu.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Sipariş Detay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Canvas701Colors.background
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        foregroundColor: Canvas701Colors.background,
        iconTheme: const IconThemeData(color: Canvas701Colors.background),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Canvas701Colors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Canvas701Colors.textTertiary,
            ),
            const SizedBox(height: Canvas701Spacing.md),
            Text(_errorMessage!, style: Canvas701Typography.bodyMedium),
            const SizedBox(height: Canvas701Spacing.md),
            ElevatedButton(
              onPressed: _fetchOrderDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_orderDetail == null) {
      return const Center(child: Text('Sipariş bulunamadı.'));
    }

    final order = _orderDetail!;

    return RefreshIndicator(
      onRefresh: _fetchOrderDetail,
      color: Canvas701Colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Sipariş Özet Kartı (Üst Kısım)
            _buildOrderSummaryCard(order),

            // Teslimat Bilgileri & Aksiyon Butonları
            _buildDeliveryInfoSection(order),

            // Ürünler Listesi
            _buildProductsSection(order),

            // Hızlı Aksiyonlar
            _buildQuickActionsSection(order),

            // Adres Bilgileri
            _buildAddressSection(order),

            // Ödeme Özeti
            _buildPaymentSummary(order),

            // Sözleşmeler
            if (order.salesAgreement.isNotEmpty) _buildContractsSection(order),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Sipariş Özet Kartı - Trendyol Tarzı
  Widget _buildOrderSummaryCard(UserOrderDetail order) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Sipariş No:', '#${order.orderCode}', isBold: true),
          const SizedBox(height: 8),
          _buildInfoRow('Sipariş Tarihi:', order.orderDate),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Sipariş Özeti:',
            '${order.totalProduct} Ürün',
            valueColor: Canvas701Colors.primary,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Sipariş Detayı:',
            order.orderStatus,
            valueColor: _getStatusColor(order.orderStatus),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Toplam:',
            order.orderGrandAmount,
            valueColor: Canvas701Colors.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  /// Teslimat Bilgileri Bölümü
  Widget _buildDeliveryInfoSection(UserOrderDetail order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.orderStatusText.isNotEmpty) ...[
            Text(
              'Tahmini Teslimat',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              order.orderStatusText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (order.orderTrackingNo.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Teslimat No: ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: order.orderTrackingNo),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Takip numarası kopyalandı'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          order.orderTrackingNo,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.copy, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (order.orderCargo.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Kargo: ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                if (order.orderCargoLogo.isNotEmpty)
                  Image.network(
                    order.orderCargoLogo,
                    height: 20,
                    errorBuilder: (_, __, ___) => Text(
                      order.orderCargo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    order.orderCargo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Spacer(),
                if (order.orderTrackingLink.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse(order.orderTrackingLink);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Kargo Takip >',
                      style: TextStyle(
                        fontSize: 13,
                        color: Canvas701Colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Aksiyon Butonları
          if (!order.isCanceled) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelOrderDialog(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Canvas701Colors.primary,
                  side: const BorderSide(color: Canvas701Colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Siparişi İptal Et'),
              ),
            ),
          ],
        ],
      ),
    );
  }


 
  /// Ürünler Bölümü - Trendyol Tarzı
  Widget _buildProductsSection(UserOrderDetail order) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          // Başlık Info Satırı
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E1),
              border: Border(
                left: BorderSide(color: Canvas701Colors.primary, width: 4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Canvas701Colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.orderStatusText.isNotEmpty
                        ? order.orderStatusText
                        : '${order.totalProduct} ürün sipariş edildi.',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          // Kargo Bilgisi Satırı
          if (order.orderCargo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kargo Firması: ${order.orderCargo}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  if (order.orderTrackingLink.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(order.orderTrackingLink);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: const Text(
                        'Teslimat Detay',
                        style: TextStyle(
                          fontSize: 13,
                          color: Canvas701Colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Ürün Kartları
          ...order.products.map(
            (p) => _buildProductCard(
              p,
              isLast: p == order.products.last,
              order: order,
            ),
          ),
        ],
      ),
    );
  }

  /// Ürün Kartı - Trendyol Tarzı
  Widget _buildProductCard(
    OrderDetailProduct product, {
    bool isLast = false,
    required UserOrderDetail order,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Görseli
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        product.productImage,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Canvas701Colors.textTertiary,
                        ),
                      ),
                      // Özel Ölçü Etiketi
                      if (product.isCustomTable)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            color: Canvas701Colors.primary.withOpacity(0.9),
                            child: const Text(
                              'Özel Ölçü',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Ürün Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün Adı
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.productVariants.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.productVariants,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Adet ve Fiyat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adet: ${product.productCurrentQuantity}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          product.productPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Canvas701Colors.primary,
                          ),
                        ),
                      ],
                    ),
                    // İptal bilgisi
                    if (product.productCancelQuantity > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${product.productQuantity} Sipariş / ${product.productCancelQuantity} İptal',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Canvas701Colors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Değerlendirme Butonu
          if (order.isRating && !product.isCommented) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAddCommentBottomSheet(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Canvas701Colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ürünü Değerlendir',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          // Değerlendirilmiş Bilgisi
          if (product.isCommented) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Canvas701Colors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ürünü Değerlendirdiniz',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          // Ürün Notları
          if (product.productNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.productNotes,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // İptal Bilgileri
          if (product.isCanceled || product.productStatusText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Canvas701Colors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Canvas701Colors.error.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        size: 14,
                        color: Canvas701Colors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.isCanceled
                            ? 'İptal Edildi'
                            : product.productStatus,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Canvas701Colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (product.productStatusText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 22),
                      child: Text(
                        product.productStatusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: Canvas701Colors.error.withOpacity(0.8),
                        ),
                      ),
                    ),
                  if (product.productCancelDesc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 22),
                      child: Text(
                        'Sebep: ${product.productCancelDesc}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Canvas701Colors.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (product.productCancelDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 22),
                      child: Text(
                        'Tarih: ${product.productCancelDate}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Canvas701Colors.error.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Hızlı Aksiyonlar Bölümü - Trendyol Tarzı
  Widget _buildQuickActionsSection(UserOrderDetail order) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          // Fatura Görüntüle
          if (order.orderInvoice.isNotEmpty)
            _buildActionItem(
              icon: Icons.description_outlined,
              title: 'Fatura Görüntüle',
              onTap: () async {
                final url = Uri.parse(order.orderInvoice);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Canvas701Colors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Adres Bölümü - Trendyol Tarzı
  Widget _buildAddressSection(UserOrderDetail order) {
    if (order.shippingAddress == null && order.billingAddress == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          if (order.shippingAddress != null)
            _buildAddressCard(
              'Teslimat Adresi',
              order.shippingAddress!,
              icon: Icons.local_shipping_outlined,
            ),
          if (order.shippingAddress != null && order.billingAddress != null)
            const Divider(height: 1, indent: 16, endIndent: 16),
          if (order.billingAddress != null)
            _buildAddressCard(
              'Fatura Adresi',
              order.billingAddress!,
              icon: Icons.receipt_long_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    String title,
    OrderAddress address, {
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Canvas701Colors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (address.addressType.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    address.addressType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Alıcı Bilgileri
          Text(
            'Alıcı: ${address.addressName}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (address.addressTitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address.addressTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Adres Detayı
          Text(
            address.address,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${address.addressDistrict} / ${address.addressCity}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Telefon (maskelenmiş gösterim)
          if (address.addressPhone.isNotEmpty)
            Text(
              address.addressPhone,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          // Email
          if (address.addressEmail.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              address.addressEmail,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          // Kurumsal Bilgiler
          if (address.realCompanyName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              address.realCompanyName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
          if (address.taxNumber.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'VN: ${address.taxNumber}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (address.taxAdministration.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'VD: ${address.taxAdministration}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (address.identityNumber.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'TC: ${address.identityNumber}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  /// Ödeme Özeti - Trendyol Tarzı
  Widget _buildPaymentSummary(UserOrderDetail order) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ödeme Yöntemi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ödeme Bilgileri',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.credit_card, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    '${order.orderPaymentType} - ${order.orderInstallment}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fiyat Detayları
          _buildPriceRow('Ara Toplam', order.orderCartTotal),
          const SizedBox(height: 8),
          _buildPriceRow('Kargo', order.orderCargoAmount),
          if (order.orderDiscount != '0,00 TL') ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'İndirim',
              '- ${order.orderDiscount}',
              valueColor: Canvas701Colors.success,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          // Toplam
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                order.orderGrandAmount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Canvas701Colors.primary,
                ),
              ),
            ],
          ),
          // Sipariş Notu
          if (order.orderDesc.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderDesc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Sözleşmeler Bölümü - Trendyol Tarzı
  Widget _buildContractsSection(UserOrderDetail order) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            'Sözleşmeler',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          children: [
            const Divider(height: 1),
            if (order.salesAgreement.isNotEmpty)
              ListTile(
                dense: true,
                title: const Text(
                  'Mesafeli Satış Sözleşmesi',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () async {
                  final url = Uri.parse(order.salesAgreement);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelOrderDialog(UserOrderDetail order) {
    if (_cancelTypes.isEmpty) {
      _fetchCancelTypes().then((_) {
        if (mounted && _cancelTypes.isNotEmpty) {
          _showCancelOrderDialog(order);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İptal nedenleri yüklenemedi.')),
          );
        }
      });
      return;
    }

    // İptal edilebilir ürünleri her bir adet için ayrı bir öğe olarak düzleştir
    // Örn: Üründen 3 adet varsa, listede 3 ayrı satır görünür
    final List<Map<String, dynamic>> flatProducts = [];
    for (var p in order.products) {
      if (!p.isCanceled && p.quantities.isNotEmpty) {
        // En yüksek miktar kadar (veya currentQuantity kadar) satır ekle
        final int count = p.productCurrentQuantity;
        for (int i = 0; i < count; i++) {
          flatProducts.add({
            'product': p,
            'uid': '${p.productID}_$i', // Benzersiz ID
            'selected': false,
            'reason': _cancelTypes.isNotEmpty ? _cancelTypes.last.typeID : null,
            'desc': '',
          });
        }
      }
    }

    if (flatProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İptal edilebilecek ürün bulunamadı.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final selectedItems = flatProducts.where((item) => item['selected']).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Expanded(
                        child: Text(
                          'Ürün İptal İşlemi',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: flatProducts.length,
                    itemBuilder: (context, index) {
                      final item = flatProducts[index];
                      final product = item['product'] as OrderDetailProduct;
                      final isSelected = item['selected'] as bool;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Canvas701Colors.primary : Colors.grey[200]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Ürün Üst Bilgisi (Her zaman görünür)
                            InkWell(
                              onTap: () => setModalState(() => item['selected'] = !isSelected),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            product.productImage,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 60, height: 60, color: Colors.grey[100],
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            right: 0, top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(color: Canvas701Colors.primary, shape: BoxShape.circle),
                                              child: const Icon(Icons.check, color: Colors.white, size: 14),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${product.productVariants} • ${product.productPrice}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: isSelected ? Canvas701Colors.primary : Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // İptal Formu (Akordiyon - Sadece seçiliyse açılır)
                            if (isSelected) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'İptal Bilgileri',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Canvas701Colors.primary),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<int>(
                                      value: item['reason'],
                                      isDense: true,
                                      decoration: InputDecoration(
                                        labelText: 'İptal Nedeni',
                                        labelStyle: const TextStyle(fontSize: 12),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      items: _cancelTypes.map((t) => DropdownMenuItem(
                                        value: t.typeID,
                                        child: Text(t.typeName, style: const TextStyle(fontSize: 13)),
                                      )).toList(),
                                      onChanged: (val) => setModalState(() => item['reason'] = val),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      onChanged: (val) => item['desc'] = val,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Açıklama giriniz...',
                                        hintStyle: const TextStyle(fontSize: 12),
                                        contentPadding: const EdgeInsets.all(12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Footer
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
                  child: ElevatedButton(
                    onPressed: selectedItems.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            _handleBulkCancelOrder(order, selectedItems);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Canvas701Colors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      selectedItems.isEmpty 
                        ? 'Lütfen Ürün Seçin' 
                        : '${selectedItems.length} Ürünü İptal Et',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

  Future<void> _handleBulkCancelOrder(
    UserOrderDetail order,
    List<Map<String, dynamic>> selectedItems,
  ) async {
    // Aynı productID'ye sahip satırları gruplayabilirdik ama API her satırı ayrı bir iptal kaydı olarak bekliyor 
    // veya biz her birini 1 adet olarak göndereceğiz.
    final List<CancelOrderProduct> cancelProducts = [];

    // Aynı ürünleri gruplayalım (Çünkü API products dizisi içinde her productID'den bir tane bekleyebilir)
    // Eğer API her satırı ayrı obje olarak kabul ediyorsa düz liste de olur.
    // Ancak standart yapı gereği aynı ID'li ürünleri adetleriyle birleştirmek daha güvenli:
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (var item in selectedItems) {
      final pid = (item['product'] as OrderDetailProduct).productID;
      grouped.putIfAbsent(pid, () => []).add(item);
    }

    // Gruplanmış her bir "iptal satırı" için ayrı bir CancelOrderProduct nesnesi oluşturulacak 
    // ama API bizden List<CancelOrderProduct> bekliyor.
    // Kullanıcı her adet için farklı form doldurduğu için, teknik olarak her birini 1 adet olarak ayrı öğe veya tek öğe (ilk form geçerli) gönderebiliriz.
    // Sizin istediğiniz "her adet için ayrı form" olduğu için, her seçili öğeyi 1 adet olarak gönderiyorum:
    for (var item in selectedItems) {
      final p = item['product'] as OrderDetailProduct;
      cancelProducts.add(CancelOrderProduct(
        productID: p.productID,
        productQuantity: 1, // Her satır 1 adet temsil ediyor
        cancelType: item['reason'] ?? _cancelTypes.last.typeID,
        cancelDesc: item['desc'].toString().isEmpty ? 'Kullanıcı tarafından iptal edildi.' : item['desc'],
      ));
    }

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Canvas701Colors.primary),
      ),
    );

    try {
      final response = await _orderService.cancelOrder(
        orderID: order.orderID,
        products: cancelProducts,
      );

      if (mounted) {
        Navigator.pop(context); // Loading kapat

        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Canvas701Colors.success,
            ),
          );

          if (response.updatedOrder != null) {
            setState(() {
              _orderDetail = response.updatedOrder;
            });
          } else {
            _fetchOrderDetail(); // Yedek olarak API'den tekrar çek
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Canvas701Colors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bir hata oluştu.'),
            backgroundColor: Canvas701Colors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('iptal')) return Canvas701Colors.error;
    if (status.contains('teslim')) return Canvas701Colors.success;
    if (status.contains('yeni')) return Canvas701Colors.info;
    if (status.contains('hazırlanıyor')) return Canvas701Colors.warning;
    return Canvas701Colors.textSecondary;
  }

  void _showAddCommentBottomSheet(OrderDetailProduct product) {
    int rating = 5;
    bool showName = true;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ürünü Değerlendir',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Canvas701Colors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 20, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Ürün Kartı (Daha şık)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: product.productImage.isNotEmpty
                                      ? Image.network(
                                          product.productImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.image_not_supported, color: Colors.grey),
                                        )
                                      : const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Canvas701Colors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (product.productVariants.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        product.productVariants,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Center(
                          child: Text(
                            'Ürünü puanla',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Canvas701Colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final isSelected = index < rating;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  rating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isSelected ? const Color(0xFFFFB300) : Colors.grey[300],
                                    size: 48,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Deneyimlerinizi paylaşın',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Canvas701Colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: commentController,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Ürün nasıl? Kalitesi, rengi beklediğin gibi mi?',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Canvas701Colors.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              showName = !showName;
                            });
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: showName,
                                  activeColor: Canvas701Colors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                  onChanged: (value) {
                                    setModalState(() {
                                      showName = value ?? true;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'İsmimi göster',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Canvas701Colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (commentController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lütfen bir yorum yazın.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(color: Canvas701Colors.primary),
                                ),
                              );

                              final response = await _userService.addComment(
                                productID: product.productID,
                                comment: commentController.text.trim(),
                                commentRating: rating,
                                showName: showName,
                              );

                              if (mounted) {
                                Navigator.pop(context);
                                if (response.success) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message),
                                      backgroundColor: Canvas701Colors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      margin: const EdgeInsets.all(12),
                                    ),
                                  );
                                  _fetchOrderDetail();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message),
                                      backgroundColor: Canvas701Colors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      margin: const EdgeInsets.all(12),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Canvas701Colors.primary,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Canvas701Colors.primary.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Değerlendirmeyi Gönder',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
}
