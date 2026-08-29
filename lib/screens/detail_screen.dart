import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import 'package:crame_longexam/constants.dart';

// Enhancement 3: Detail screen displaying post, comments list, interactive likes, and comment input
class DetailScreen extends StatefulWidget {
  final int postId;
  final int userId;
  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final String imageUrl;
  final String profileImageUrl;

  const DetailScreen({
    super.key,
    this.postId = 1,
    this.userId = 1,
    required this.userName,
    required this.postContent,
    this.numOfLikes = 0,
    required this.date,
    this.imageUrl = '',
    this.profileImageUrl = '',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  late int _currentLikes;
  bool _isLiked = false;

  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  bool _isSubmittingComment = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.numOfLikes;
    _loadCurrentUser();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // Loads current user info for comment authorship and profile picture syncing
  Future<void> _loadCurrentUser() async {
    final user = await _userService.getUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  // Enhancement 3: Fetches comments for this post from DummyJSON API
  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await _commentService.getCommentsByPostId(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  // Enhancement 3: Toggles like state and counter for post
  void _handleLike() {
    setState(() {
      if (_isLiked) {
        _currentLikes--;
        _isLiked = false;
      } else {
        _currentLikes++;
        _isLiked = true;
      }
    });
  }

  // Enhancement 3: Toggles like state and counter for individual comment
  void _handleCommentLike(Comment comment) {
    setState(() {
      if (comment.isLiked) {
        comment.likes--;
        comment.isLiked = false;
      } else {
        comment.likes++;
        comment.isLiked = true;
      }
    });
  }

  // Enhancement 3: Submits comment to DummyJSON, syncing profile image and prepending to comments list
  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);

    final currentUserId = _currentUser?.id ?? widget.userId;
    final currentUserName = _currentUser?.username ?? 'me';
    final currentFullName = _currentUser?.fullName ?? 'Me';
    final currentUserImage = _currentUser?.image ?? '';

    try {
      final newComment = await _commentService.addComment(
        postId: widget.postId,
        body: text,
        userId: currentUserId,
      );

      // Create comment instance syncing with the logged-in user profile picture
      final commentWithProfile = Comment(
        id: newComment.id,
        body: newComment.body,
        postId: newComment.postId,
        likes: newComment.likes,
        user: CommentUser(
          id: currentUserId,
          username: currentUserName,
          fullName: currentFullName,
          image: currentUserImage,
        ),
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, commentWithProfile);
          _commentController.clear();
          _isSubmittingComment = false;
        });
        _commentFocusNode.unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            duration: Duration(seconds: 2),
            backgroundColor: FB_DARK_PRIMARY,
          ),
        );
      }
    } catch (e) {
      // Fallback local addition with synced profile image
      if (mounted) {
        final fallbackComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          body: text,
          postId: widget.postId,
          likes: 0,
          user: CommentUser(
            id: currentUserId,
            username: currentUserName,
            fullName: currentFullName,
            image: currentUserImage,
          ),
        );
        setState(() {
          _comments.insert(0, fallbackComment);
          _commentController.clear();
          _isSubmittingComment = false;
        });
        _commentFocusNode.unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            duration: Duration(seconds: 2),
            backgroundColor: FB_DARK_PRIMARY,
          ),
        );
      }
    }
  }

  // Resolves Asset vs Network image provider
  ImageProvider? _getImageProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http')) {
      return CachedNetworkImageProvider(path);
    }
    return AssetImage(path);
  }

  // Builds main post image widget
  Widget _buildPostImage(String path) {
    if (path.isEmpty) return SizedBox(height: ScreenUtil().setHeight(0));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY;

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(color: primaryAccent),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : FB_PRIMARY),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomFont(
          text: widget.userName,
          fontSize: ScreenUtil().setSp(18),
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : FB_PRIMARY,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Image
                  _buildPostImage(widget.imageUrl),

                  SizedBox(height: ScreenUtil().setHeight(15)),

                  // User Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        (widget.profileImageUrl == '')
                            ? CircleAvatar(
                                radius: ScreenUtil().setSp(22),
                                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                child: Icon(Icons.person, color: isDark ? Colors.white70 : Colors.grey.shade700),
                              )
                            : CircleAvatar(
                                radius: ScreenUtil().setSp(22),
                                backgroundImage:
                                    _getImageProvider(widget.profileImageUrl),
                              ),
                        SizedBox(width: ScreenUtil().setWidth(10)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomFont(
                              text: widget.userName,
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                            ),
                            Row(
                              children: [
                                CustomFont(
                                  text: widget.date,
                                  fontSize: ScreenUtil().setSp(12),
                                  color: Colors.grey,
                                ),
                                SizedBox(width: ScreenUtil().setWidth(3)),
                                Icon(
                                  Icons.public,
                                  color: Colors.grey,
                                  size: ScreenUtil().setSp(14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.more_horiz, color: isDark ? Colors.white70 : Colors.grey),
                      ],
                    ),
                  ),

                  SizedBox(height: ScreenUtil().setHeight(15)),

                  // Post Content
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(16),
                    ),
                    alignment: Alignment.centerLeft,
                    child: CustomFont(
                      text: widget.postContent,
                      fontSize: ScreenUtil().setSp(16),
                    ),
                  ),

                  SizedBox(height: ScreenUtil().setHeight(15)),
                  Divider(height: 1, color: Theme.of(context).dividerColor),

                  // Action Buttons (Likes, Comment, Share)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(10),
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Enhancement 3: Clickable like button for post
                        TextButton.icon(
                          onPressed: _handleLike,
                          icon: Icon(
                            _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: _isLiked ? primaryAccent : Colors.grey,
                          ),
                          label: CustomFont(
                            text: '$_currentLikes',
                            fontSize: ScreenUtil().setSp(13),
                            color: _isLiked ? primaryAccent : Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _commentFocusNode.requestFocus(),
                          icon: Icon(Icons.comment_outlined, color: primaryAccent),
                          label: CustomFont(
                            text: '${_comments.length} Comments',
                            fontSize: ScreenUtil().setSp(13),
                            color: primaryAccent,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.share_outlined, color: primaryAccent),
                          label: CustomFont(
                            text: 'Share',
                            fontSize: ScreenUtil().setSp(13),
                            color: primaryAccent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, thickness: 4, color: Theme.of(context).dividerColor),

                  // Comments Header & List
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                    child: CustomFont(
                      text: 'Comments (${_comments.length})',
                      fontSize: ScreenUtil().setSp(15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (_isLoadingComments)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(color: primaryAccent),
                      ),
                    )
                  else if (_comments.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Center(
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, indent: 60, color: Theme.of(context).dividerColor),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildCommentItem(comment);
                      },
                    ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Enhancement 3: Comment Input Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: primaryAccent,
                    backgroundImage: _currentUser?.image.isNotEmpty == true
                        ? CachedNetworkImageProvider(_currentUser!.image)
                        : null,
                    child: _currentUser?.image.isEmpty ?? true
                        ? const Icon(Icons.person, size: 18, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _isSubmittingComment
                      ? SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: primaryAccent,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: primaryAccent),
                          onPressed: _submitComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhancement 3: Comment tile builder syncing profile image of the user
  Widget _buildCommentItem(Comment comment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY;

    // Sync profile picture with profile page if comment is by current logged in user or user has image
    final isCurrentLoggedInUser = (comment.user.id == _currentUser?.id) ||
        (_currentUser != null && comment.user.username.isNotEmpty && comment.user.username == _currentUser!.username);
    final userAvatarUrl = isCurrentLoggedInUser
        ? (_currentUser?.image ?? '')
        : (comment.user.image.isNotEmpty ? comment.user.image : '');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: FB_LIGHT_PRIMARY.withValues(alpha: 0.3),
            backgroundImage: userAvatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(userAvatarUrl)
                : null,
            child: userAvatarUrl.isEmpty
                ? Text(
                    comment.user.fullName.isNotEmpty
                        ? comment.user.fullName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryAccent,
                      fontSize: 14.sp,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: comment.user.fullName,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        comment.body,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4.w, top: 4.h),
                  child: Row(
                    children: [
                      // Enhancement 3: Clickable like button for comment
                      GestureDetector(
                        onTap: () => _handleCommentLike(comment),
                        child: Row(
                          children: [
                            Icon(
                              comment.isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 14.sp,
                              color: comment.isLiked
                                  ? primaryAccent
                                  : Colors.grey,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              comment.likes > 0 ? '${comment.likes}' : 'Like',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: comment.isLiked
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: comment.isLiked
                                    ? primaryAccent
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {
                          _commentController.text =
                              '@${comment.user.username} ';
                          _commentFocusNode.requestFocus();
                        },
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
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