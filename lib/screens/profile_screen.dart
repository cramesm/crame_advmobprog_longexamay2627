import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';

// Enhancement 2: Displays user profile details and renders posts by userId
class ProfileScreen extends StatefulWidget {
  final User? user;
  final String username;

  const ProfileScreen({
    super.key,
    this.user,
    this.username = 'User',
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  User? _currentUser;
  List<Post> _userPosts = [];
  bool _isLoadingPosts = false;
  String? _postsErrorMessage;

  final String _coverPhotoUrl =
      'https://images.unsplash.com/photo-1707343843437-caacff5cfa74?auto=format&fit=crop&w=1200&q=80';
  final String _gridImageUrl =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80';

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  // Enhancement 2: Resolves current user and initiates posts fetch
  Future<void> _initProfile() async {
    if (widget.user != null) {
      _currentUser = widget.user;
    } else {
      final user = await _userService.getUserData();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    }

    final userId = _currentUser?.id ?? 5;
    _fetchUserPosts(userId);
  }

  // Enhancement 2: Fetches posts authored by this userId from DummyJSON
  Future<void> _fetchUserPosts(int userId) async {
    setState(() {
      _isLoadingPosts = true;
      _postsErrorMessage = null;
    });

    try {
      final posts = await _postService.getPostsByUserId(userId);
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _postsErrorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingPosts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _currentUser?.fullName.isNotEmpty == true
        ? _currentUser!.fullName
        : (_currentUser?.username.isNotEmpty == true
            ? _currentUser!.username
            : widget.username);

    final avatarUrl = _currentUser?.image ?? '';

    return DefaultTabController(
      length: 3,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo and Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(_coverPhotoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: ScreenUtil().setWidth(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: avatarUrl.isNotEmpty
                              ? CachedNetworkImageProvider(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 50, color: FB_PRIMARY)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: ScreenUtil().setHeight(55)),

              // User Info & Metrics
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFont(
                      text: displayName,
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(20),
                    ),
                    if (_currentUser?.email.isNotEmpty == true) ...[
                      SizedBox(height: 2.h),
                      Text(
                        _currentUser!.email,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(13),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    Row(
                      children: [
                        CustomFont(
                          text: '${_userPosts.length}',
                          fontSize: ScreenUtil().setSp(15),
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(width: ScreenUtil().setWidth(5)),
                        CustomFont(
                          text: 'posts',
                          fontSize: ScreenUtil().setSp(15),
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        SizedBox(width: ScreenUtil().setWidth(15)),
                        CustomFont(
                          text: '8.2B',
                          fontSize: ScreenUtil().setSp(15),
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(width: ScreenUtil().setWidth(5)),
                        CustomFont(
                          text: 'followers',
                          fontSize: ScreenUtil().setSp(15),
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: ScreenUtil().setHeight(10)),
              TabBar(
                indicatorColor: Theme.of(context).brightness == Brightness.dark
                    ? FB_LIGHT_PRIMARY
                    : FB_DARK_PRIMARY,
                labelColor: Theme.of(context).brightness == Brightness.dark
                    ? FB_LIGHT_PRIMARY
                    : FB_DARK_PRIMARY,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(child: CustomFont(text: 'Posts', fontSize: ScreenUtil().setSp(15))),
                  Tab(child: CustomFont(text: 'About', fontSize: ScreenUtil().setSp(15))),
                  Tab(child: CustomFont(text: 'Photos', fontSize: ScreenUtil().setSp(15))),
                ],
              ),

              // Tab Content Views
              SizedBox(
                height: ScreenUtil().setHeight(1800),
                child: TabBarView(
                  children: [
                    _buildPostsTab(displayName, avatarUrl),
                    _buildAboutTab(displayName),
                    _buildPhotosTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhancement 2: Renders dynamic posts list fetched by userId
  Widget _buildPostsTab(String displayName, String avatarUrl) {
    if (_isLoadingPosts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(color: FB_DARK_PRIMARY),
        ),
      );
    }

    if (_postsErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 10),
              Text(
                'Could not load posts: $_postsErrorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _fetchUserPosts(_currentUser?.id ?? 5),
                style: ElevatedButton.styleFrom(backgroundColor: FB_DARK_PRIMARY),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.article_outlined, size: 50, color: Colors.grey),
              const SizedBox(height: 10),
              Text(
                'No posts yet by $displayName.',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        final postTitle = post.title.isNotEmpty ? post.title : 'Post #${post.id}';
        final content = post.body.isNotEmpty ? post.body : postTitle;

        return PostCard(
          postId: post.id,
          userId: post.userId != 0 ? post.userId : (_currentUser?.id ?? 1),
          userName: displayName,
          profileImageUrl: avatarUrl,
          imageUrl: '',
          postContent: content,
          date: post.tags.isNotEmpty ? '#${post.tags.join(" #")}' : 'Just now',
          numOfLikes: post.likes,
        );
      },
    );
  }

  // Renders user details in About tab
  Widget _buildAboutTab(String displayName) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFont(
            text: 'Profile Details',
            fontSize: ScreenUtil().setSp(18),
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 15.h),
          _buildAboutRow(
            Icons.person,
            'Name: $displayName',
          ),
          if (_currentUser?.username.isNotEmpty == true)
            _buildAboutRow(
              Icons.alternate_email,
              'Username: @${_currentUser!.username}',
            ),
          if (_currentUser?.email.isNotEmpty == true)
            _buildAboutRow(
              Icons.email,
              'Email: ${_currentUser!.email}',
            ),
          if (_currentUser?.gender.isNotEmpty == true)
            _buildAboutRow(
              Icons.wc,
              'Gender: ${_currentUser!.gender.toUpperCase()}',
            ),
          _buildAboutRow(
            Icons.school,
            'Studied BSIT-MWA at National University',
          ),
          _buildAboutRow(
            Icons.home,
            'Lives in Taguig City',
          ),
          _buildAboutRow(
            Icons.location_on,
            'From Manila, Philippines',
          ),
        ],
      ),
    );
  }

  // Renders photo gallery grid
  Widget _buildPhotosTab() {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: _gridImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }

  // Helper row builder for details
  Widget _buildAboutRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          SizedBox(width: ScreenUtil().setWidth(15)),
          Expanded(
            child: CustomFont(
              text: text,
              fontSize: ScreenUtil().setSp(15),
            ),
          ),
        ],
      ),
    );
  }
}