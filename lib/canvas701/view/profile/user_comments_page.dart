import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../services/user_service.dart';
import '../../model/user_models.dart';
import '../../model/product_models.dart';
import '../product/product_detail_page.dart';

class UserCommentsPage extends StatefulWidget {
  const UserCommentsPage({super.key});

  @override
  State<UserCommentsPage> createState() => _UserCommentsPageState();
}

class _UserCommentsPageState extends State<UserCommentsPage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserCommentsResponse? _response;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _userService.getUserComments();
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text(
          'Değerlendirmelerim',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Canvas701Colors.primary));
    }

    if (_response == null || !(_response?.success ?? false)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Yorumlar yüklenirken bir hata oluştu.'),
            TextButton(onPressed: _fetchComments, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }

    final comments = _response!.data?.comments ?? [];

    if (comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              _response!.data?.emptyMessage ?? 'Henüz bir değerlendirmeniz bulunmuyor.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Canvas701Colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchComments,
      color: Canvas701Colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: comments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildCommentCard(comments[index]),
      ),
    );
  }

  Widget _buildCommentCard(UserComment comment) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProduct(comment),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      comment.productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToProduct(comment),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.productTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Canvas701Colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.commentDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStatusBadge(comment.commentApproval),
                const SizedBox(width: 4),
                _buildPopupMenu(comment),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content: Rating and Comment
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < comment.commentRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: index < comment.commentRating ? Colors.amber : Colors.grey[300],
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  comment.commentDesc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Canvas701Colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Footer: Likes/Dislikes
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                _buildLikeDislike(Icons.thumb_up_alt_outlined, comment.commentLike),
                const SizedBox(width: 16),
                _buildLikeDislike(Icons.thumb_down_alt_outlined, comment.commentDislike),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProduct(UserComment comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: Product(
            id: comment.productID.toString(),
            code: '',
            name: comment.productTitle,
            description: '',
            price: 0.0,
            images: [comment.productImage],
            thumbnailUrl: comment.productImage,
            collectionId: '',
            categoryIds: [],
            availableSizes: [
              ProductSize(
                id: 'default',
                name: 'Standart',
                width: 0,
                height: 0,
                price: 0,
              ),
            ],
            createdAt: DateTime.now(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(UserComment comment) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'edit') {
          _showEditCommentBottomSheet(comment);
        } else if (value == 'delete') {
          _showDeleteConfirmation(comment);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Düzenle'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Sil', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(UserComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text('Bu yorumu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _handleDeleteComment(comment.commentID);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteComment(int commentID) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Canvas701Colors.primary)),
    );

    final response = await _userService.deleteComment(commentID);

    if (mounted) {
      Navigator.pop(context); // Loading kapat
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Canvas701Colors.success),
        );
        _fetchComments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Canvas701Colors.error),
        );
      }
    }
  }

  void _showEditCommentBottomSheet(UserComment comment) {
    int rating = comment.commentRating;
    bool showName = comment.showName;
    final TextEditingController commentController = TextEditingController(text: comment.commentDesc);

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
                              'Yorumu Düzenle',
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
                                child: Icon(
                                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: isSelected ? const Color(0xFFFFB300) : Colors.grey[300],
                                  size: 48,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Yorumunuzu güncelleyin...',
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => setModalState(() => showName = !showName),
                          child: Row(
                            children: [
                              Checkbox(
                                value: showName,
                                activeColor: Canvas701Colors.primary,
                                onChanged: (v) => setModalState(() => showName = v ?? true),
                              ),
                              const Text('İsmimi göster'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (commentController.text.trim().isEmpty) return;

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator(color: Canvas701Colors.primary)),
                              );

                              final response = await _userService.updateComment(
                                productID: comment.productID,
                                commentID: comment.commentID,
                                comment: commentController.text.trim(),
                                commentRating: rating,
                                showName: showName,
                              );

                              if (mounted) {
                                Navigator.pop(context); // Loading kapat
                                if (response.success) {
                                  Navigator.pop(context); // BottomSheet kapat
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response.message), backgroundColor: Canvas701Colors.success),
                                  );
                                  _fetchComments();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response.message), backgroundColor: Canvas701Colors.error),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Canvas701Colors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Güncelle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.contains('Onay Bekliyor')) color = Colors.orange;
    if (status.contains('Onaylandı')) color = Colors.green;
    if (status.contains('Reddedildi')) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLikeDislike(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
