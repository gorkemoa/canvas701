import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../services/user_service.dart';
import '../../model/user_models.dart';

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
            color: Canvas701Colors.background,
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        foregroundColor: Canvas701Colors.background,
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
                ClipRRect(
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
                const SizedBox(width: 12),
                Expanded(
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
                _buildStatusBadge(comment.commentApproval),
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
