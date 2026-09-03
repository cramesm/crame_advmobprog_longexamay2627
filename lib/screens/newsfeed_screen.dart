import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/post_card.dart';
import '../widgets/custom_font.dart';
import '../constants.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostService _postService = PostService();
  List<Post> _apiPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Fetches live posts from https://dummyjson.com/posts
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _postService.getAllPosts(limit: 30);
      if (mounted) {
        setState(() {
          _apiPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        color: FB_DARK_PRIMARY,
        child: SizedBox(
          width: ScreenUtil().screenWidth,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            // itemCount = Carousel Header (1) + (Loading / Error / Posts + Interleaved Ads)
            itemCount: 1 + (_isLoading && _apiPosts.isEmpty
                ? 1
                : _errorMessage != null && _apiPosts.isEmpty
                    ? 1
                    : _calculateTotalFeedCount()),
            itemBuilder: (context, index) {
              // ---------------------------------------------------------
              // HEADER (Index 0): Advertisement / Promotion Carousel
              // ---------------------------------------------------------
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomFont(
                            text: 'Advertisement / Promotion',
                            fontSize: ScreenUtil().setSp(18),
                            fontWeight: FontWeight.bold,
                            color: isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY,
                          ),
                          if (_isLoading)
                            SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FB_LIGHT_PRIMARY,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 550.0,
                        enableInfiniteScroll: true,
                        padEnds: false,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                        aspectRatio: 16 / 9,
                        scrollPhysics: const BouncingScrollPhysics(),
                      ),
                      items: carouselPosts.asMap().entries.map((entry) {
                        final postIndex = entry.key;
                        final post = entry.value;
                        return PostCard(
                          postId: postIndex + 1,
                          userName: post.username,
                          postContent: post.content,
                          numOfLikes: post.likes,
                          date: post.date,
                          imageUrl: post.imagePath ?? '',
                          profileImageUrl: post.profileImageUrl,
                          adsMarket: post.adsMarket,
                          productUrl: post.productUrl,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Divider(thickness: 4, color: Theme.of(context).dividerColor),
                  ],
                );
              }

              // Loading State (below carousel)
              if (_isLoading && _apiPosts.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: FB_DARK_PRIMARY),
                        SizedBox(height: 12.h),
                        Text(
                          'Loading posts from DummyJSON...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Error State (below carousel)
              if (_errorMessage != null && _apiPosts.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48.r, color: Colors.redAccent),
                        SizedBox(height: 10.h),
                        Text(
                          'Failed to load posts: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton.icon(
                          onPressed: _fetchPosts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FB_DARK_PRIMARY,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ---------------------------------------------------------
              // FEED ITEMS: Dynamic DummyJSON Posts + Interleaved Ads
              // ---------------------------------------------------------
              final feedIndex = index - 1;
              return _buildFeedItem(feedIndex);
            },
          ),
        ),
      ),
    );
  }

  // Calculates feed length including interleaved sponsored carousels
  int _calculateTotalFeedCount() {
    if (_apiPosts.isEmpty) return 0;
    // Interleave 1 sponsored carousel every 5 posts
    final adCount = (_apiPosts.length / 5).floor().clamp(0, adCarousels.length);
    return _apiPosts.length + adCount;
  }

  // Builds either a dynamic DummyJSON PostCard or a Sponsored Ad Carousel
  Widget _buildFeedItem(int feedIndex) {
    // Check if this position is designated for an ad carousel (every 6th item in feed)
    final adKeys = adCarousels.keys.toList();
    if (feedIndex > 0 && feedIndex % 6 == 5) {
      final adSlot = (feedIndex ~/ 6) % adKeys.length;
      final adKey = adKeys[adSlot];
      final adImages = adCarousels[adKey] ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setHeight(10)),
          CarouselSlider(
            options: CarouselOptions(
              height: 550.0,
              enableInfiniteScroll: true,
              padEnds: false,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              aspectRatio: 16 / 9,
              scrollPhysics: const BouncingScrollPhysics(),
            ),
            items: adImages.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              return PostCard(
                postId: 1000 + feedIndex * 10 + itemIndex,
                userName: item.username,
                postContent: item.content,
                numOfLikes: 1500 + itemIndex * 100,
                date: 'Sponsored',
                imageUrl: item.imagePath,
                profileImageUrl: item.profileImageUrl,
                adsMarket: item.adsMarket,
                productUrl: item.productUrl,
              );
            }).toList(),
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          Divider(thickness: 1, color: Theme.of(context).dividerColor),
        ],
      );
    }

    // Calculate the post index mapped from the interleaved feed
    final postIndex = feedIndex - (feedIndex ~/ 6);
    if (postIndex < 0 || postIndex >= _apiPosts.length) {
      return const SizedBox.shrink();
    }

    final post = _apiPosts[postIndex];
    final tagsText = post.tags.isNotEmpty
        ? post.tags.map((t) => '#$t').join(' ')
        : 'General';

    final contentText = post.title.isNotEmpty
        ? '${post.title.toUpperCase()}\n\n${post.body}'
        : post.body;

    return PostCard(
      postId: post.id,
      userId: post.userId,
      userName: 'User #${post.userId}',
      postContent: contentText,
      numOfLikes: post.likes,
      date: tagsText,
      imageUrl: '',
      profileImageUrl: 'https://dummyjson.com/icon/user${post.userId}/128',
      adsMarket: '',
      productUrl: null,
    );
  }
}

// --- DATA MODELS FOR ADS ---

class CarouselItem {
  final String imagePath;
  final String username;
  final String profileImageUrl;
  final String content;
  final String adsMarket;
  final String? productUrl;

  CarouselItem({
    required this.imagePath,
    required this.username,
    required this.profileImageUrl,
    this.content = '',
    this.adsMarket = 'Learn More',
    this.productUrl,
  });
}

class SponsoredPost {
  final String username;
  final String content;
  final String date;
  final int likes;
  final int comments;
  final String? imagePath;
  final String profileImageUrl;
  final String adsMarket;
  final String? productUrl;

  SponsoredPost({
    required this.username,
    required this.content,
    required this.date,
    required this.likes,
    required this.comments,
    this.imagePath,
    this.profileImageUrl = '',
    this.adsMarket = '',
    this.productUrl,
  });
}

// --- DATA SOURCE FOR ADS ---

// Mapping for Ad Carousels (Sponsored Feed)
final Map<String, List<CarouselItem>> adCarousels = {
  'Retro & Skate': [
    CarouselItem(
      imagePath: 'https://th.bing.com/th/id/R.b8541404bccde3a57ddbb7de60c8f3ac?rik=eHfLv8krXIu2rA&riu=http%3a%2f%2fshoenami.com.ph%2fcdn%2fshop%2ffiles%2fWS327KB-1.jpg%3fv%3d1690189059%26width%3d2048&ehk=X5ZZIOkhLDJOtQDetwsINKm65Az0UR86If4v11hnG3g%3d&risl=&pid=ImgRaw&r=0',
      username: 'New Balance',
      profileImageUrl: 'https://th.bing.com/th/id/R.b8541404bccde3a57ddbb7de60c8f3ac?rik=eHfLv8krXIu2rA&riu=http%3a%2f%2fshoenami.com.ph%2fcdn%2fshop%2ffiles%2fWS327KB-1.jpg%3fv%3d1690189059%26width%3d2048&ehk=X5ZZIOkhLDJOtQDetwsINKm65Az0UR86If4v11hnG3g%3d&risl=&pid=ImgRaw&r=0',
      content: '327',
      adsMarket: '₱ 4,700.00',
      productUrl: 'https://th.bing.com/th/id/R.b8541404bccde3a57ddbb7de60c8f3ac?rik=eHfLv8krXIu2rA&riu=http%3a%2f%2fshoenami.com.ph%2fcdn%2fshop%2ffiles%2fWS327KB-1.jpg%3fv%3d1690189059%26width%3d2048&ehk=X5ZZIOkhLDJOtQDetwsINKm65Az0UR86If4v11hnG3g%3d&risl=&pid=ImgRaw&r=0',
    ),
    CarouselItem(
      imagePath: 'https://tse2.mm.bing.net/th/id/OIP.QGFbQO8B2j4gcnR6xzBpswHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
      username: 'Vans',
      profileImageUrl: 'https://tse2.mm.bing.net/th/id/OIP.QGFbQO8B2j4gcnR6xzBpswHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
      content: 'Old Skool Pro',
      adsMarket: '₱ 3,500.00',
      productUrl: 'https://tse2.mm.bing.net/th/id/OIP.QGFbQO8B2j4gcnR6xzBpswHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    CarouselItem(
      imagePath: 'https://www.pricerunner.se/product/1200x1200/3000219743/Converse-Run-Star-Hike-High-Top-Black-White-Gum.jpg',
      username: 'Converse',
      profileImageUrl: 'https://www.pricerunner.se/product/1200x1200/3000219743/Converse-Run-Star-Hike-High-Top-Black-White-Gum.jpg',
      content: 'Run Star',
      adsMarket: '₱ 5,450.00',
      productUrl: 'https://www.pricerunner.se/product/1200x1200/3000219743/Converse-Run-Star-Hike-High-Top-Black-White-Gum.jpg',
    ),
    CarouselItem(
      imagePath: 'https://is4.revolveassets.com/images/p4/n/uv/REEF-MZ65_V1.jpg',
      username: 'Reebok',
      profileImageUrl: 'https://is4.revolveassets.com/images/p4/n/uv/REEF-MZ65_V1.jpg',
      content: 'Classic',
      adsMarket: '₱ 4,200.00',
      productUrl: 'https://is4.revolveassets.com/images/p4/n/uv/REEF-MZ65_V1.jpg',
    ),
    CarouselItem(
      imagePath: 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/391928/01/sv01/fnd/PNA/fmt/png/RS-X-Triple-Sneakers',
      username: 'Puma',
      profileImageUrl: 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/391928/01/sv01/fnd/PNA/fmt/png/RS-X-Triple-Sneakers',
      content: 'RS-X',
      adsMarket: '₱ 5,400.00',
      productUrl: 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/391928/01/sv01/fnd/PNA/fmt/png/RS-X-Triple-Sneakers',
    ),
  ],
  'Performance & Air': [
    CarouselItem(
      imagePath: 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/fjfip8ga1ep22vhxdcew/air-max-97-shoe-EBZrb8.png',
      username: 'Nike',
      profileImageUrl: 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/fjfip8ga1ep22vhxdcew/air-max-97-shoe-EBZrb8.png',
      content: 'Air Max 97',
      adsMarket: '₱ 8,500.00',
      productUrl: 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/fjfip8ga1ep22vhxdcew/air-max-97-shoe-EBZrb8.png',
    ),
    CarouselItem(
      imagePath: 'https://images.prismic.io/sportsshoesprod/d6f5b2b1-c8bf-403d-8a9d-61c2ff3323a2_nike-pegasus-40.jpg?auto=compress,format&rect=0,0,1250,1250&w=850&h=850',
      username: 'Nike',
      profileImageUrl: 'https://images.prismic.io/sportsshoesprod/d6f5b2b1-c8bf-403d-8a9d-61c2ff3323a2_nike-pegasus-40.jpg?auto=compress,format&rect=0,0,1250,1250&w=850&h=850',
      content: 'Pegasus 40',
      adsMarket: '₱ 6,550.00',
      productUrl: 'https://images.prismic.io/sportsshoesprod/d6f5b2b1-c8bf-403d-8a9d-61c2ff3323a2_nike-pegasus-40.jpg?auto=compress,format&rect=0,0,1250,1250&w=850&h=850',
    ),
    CarouselItem(
      imagePath: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/c9e82b89-af61-48de-9109-943240cbeb3f/AIR+VAPORMAX+2023+FK.png',
      username: 'Nike',
      profileImageUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/c9e82b89-af61-48de-9109-943240cbeb3f/AIR+VAPORMAX+2023+FK.png',
      content: 'VaporMax',
      adsMarket: '₱ 10,500.00',
      productUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/c9e82b89-af61-48de-9109-943240cbeb3f/AIR+VAPORMAX+2023+FK.png',
    ),
    CarouselItem(
      imagePath: 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/6be9d64a933e4652b77c3463591cb88a_9366/ID5935_01_standard.jpg',
      username: 'Adidas',
      profileImageUrl: 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/6be9d64a933e4652b77c3463591cb88a_9366/ID5935_01_standard.jpg',
      content: 'Ultraboost',
      adsMarket: '₱ 7,600.00',
      productUrl: 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/6be9d64a933e4652b77c3463591cb88a_9366/ID5935_01_standard.jpg',
    ),
    CarouselItem(
      imagePath: 'https://cdn.weartesters.com/wp-content/uploads/2021/03/UA-Flow-Velociti-Wind-Product-Image-1536x806.png',
      username: 'Under Armour',
      profileImageUrl: 'https://cdn.weartesters.com/wp-content/uploads/2021/03/UA-Flow-Velociti-Wind-Product-Image-1536x806.png',
      content: 'Flow',
      adsMarket: '₱ 8,400.00',
      productUrl: 'https://cdn.weartesters.com/wp-content/uploads/2021/03/UA-Flow-Velociti-Wind-Product-Image-1536x806.png',
    ),
  ],
  'Hype & Utility': [
    CarouselItem(
      imagePath: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/c873f01d-4c83-4a08-ace4-a4ce8589f122/AIR+JORDAN+1+LOW+SE.png',
      username: 'Jordan',
      profileImageUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/c873f01d-4c83-4a08-ace4-a4ce8589f122/AIR+JORDAN+1+LOW+SE.png',
      content: '1 Low',
      adsMarket: '₱ 6,800.00',
      productUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/c873f01d-4c83-4a08-ace4-a4ce8589f122/AIR+JORDAN+1+LOW+SE.png',
    ),
    CarouselItem(
      imagePath: 'https://is4.revolveassets.com/images/p4/n/z/SOMO-WZ72_V1.jpg',
      username: 'Salomon',
      profileImageUrl: 'https://is4.revolveassets.com/images/p4/n/z/SOMO-WZ72_V1.jpg',
      content: 'XT-6',
      adsMarket: '₱ 11,900.00',
      productUrl: 'https://is4.revolveassets.com/images/p4/n/z/SOMO-WZ72_V1.jpg',
    ),
    CarouselItem(
      imagePath: 'https://dms.deckers.com/hoka/image/upload/f_auto,q_auto,dpr_auto/b_rgb:f7f7f9/w_1650/v1732554745/1162011-LNMT_1.png?_s=RAABAB0',
      username: 'Hoka',
      profileImageUrl: 'https://dms.deckers.com/hoka/image/upload/f_auto,q_auto,dpr_auto/b_rgb:f7f7f9/w_1650/v1732554745/1162011-LNMT_1.png?_s=RAABAB0',
      content: 'Bondi 8',
      adsMarket: '₱ 9,550.00',
      productUrl: 'https://dms.deckers.com/hoka/image/upload/f_auto,q_auto,dpr_auto/b_rgb:f7f7f9/w_1650/v1732554745/1162011-LNMT_1.png?_s=RAABAB0',
    ),
    CarouselItem(
      imagePath: 'https://sneakernews.com/wp-content/uploads/2022/05/salehe-bembury-crocs-pollex-clog-black-4.jpg',
      username: 'Crocs',
      profileImageUrl: 'https://sneakernews.com/wp-content/uploads/2022/05/salehe-bembury-crocs-pollex-clog-black-4.jpg',
      content: 'Pollex Clog',
      adsMarket: '₱ 5,650.00',
      productUrl: 'https://sneakernews.com/wp-content/uploads/2022/05/salehe-bembury-crocs-pollex-clog-black-4.jpg',
    ),
    CarouselItem(
      imagePath: 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/c3bd9dda9fdd4a7cbc9aad1e00dd0045_9366/GZ9260_01_standard.jpg',
      username: 'Adidas',
      profileImageUrl: 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/c3bd9dda9fdd4a7cbc9aad1e00dd0045_9366/GZ9260_01_standard.jpg',
      content: 'NMD R1',
      adsMarket: '₱ 7,650.00',
      productUrl: 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/c3bd9dda9fdd4a7cbc9aad1e00dd0045_9366/GZ9260_01_standard.jpg',
    ),
  ],
};

final List<SponsoredPost> carouselPosts = [
  // 1. Nike Dunk Low
  SponsoredPost(
    username: 'Nike',
    content: 'Dunk Low',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/79a35c4b-23ec-4d9e-a2f3-bb0049f96fbd/NIKE+DUNK+LOW+RETRO.png',
    profileImageUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/79a35c4b-23ec-4d9e-a2f3-bb0049f96fbd/NIKE+DUNK+LOW+RETRO.png',
    adsMarket: '₱ 5,200.00',
    productUrl: 'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/79a35c4b-23ec-4d9e-a2f3-bb0049f96fbd/NIKE+DUNK+LOW+RETRO.png',
  ),
  // 2. Adidas Samba
  SponsoredPost(
    username: 'Adidas',
    content: 'Samba',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://is4.revolveassets.com/images/p4/n/z/AORI-WZ267_V1.jpg',
    profileImageUrl: 'https://is4.revolveassets.com/images/p4/n/z/AORI-WZ267_V1.jpg',
    adsMarket: '₱ 6,500.00',
    productUrl: 'https://is4.revolveassets.com/images/p4/n/z/AORI-WZ267_V1.jpg',
  ),
  // 3. New Balance 550 White
  SponsoredPost(
    username: 'New Balance',
    content: '550 White',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://tse4.mm.bing.net/th/id/OIP.l_JZ7dC5UTnnf1nZgEjBpQHaFM?rs=1&pid=ImgDetMain&o=7&rm=3',
    profileImageUrl: 'https://tse4.mm.bing.net/th/id/OIP.l_JZ7dC5UTnnf1nZgEjBpQHaFM?rs=1&pid=ImgDetMain&o=7&rm=3',
    adsMarket: '₱ 7,800.00',
    productUrl: 'https://tse4.mm.bing.net/th/id/OIP.l_JZ7dC5UTnnf1nZgEjBpQHaFM?rs=1&pid=ImgDetMain&o=7&rm=3',
  ),
  // 4. Jordan 1 High
  SponsoredPost(
    username: 'Jordan',
    content: '1 High',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/a278b4e6-1eea-43b5-83b6-5073e377b634/AIR+JORDAN+1+RETRO+HIGH+OG.png',
    profileImageUrl: 'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/a278b4e6-1eea-43b5-83b6-5073e377b634/AIR+JORDAN+1+RETRO+HIGH+OG.png',
    adsMarket: '₱ 9,500.00',
    productUrl: 'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/a278b4e6-1eea-43b5-83b6-5073e377b634/AIR+JORDAN+1+RETRO+HIGH+OG.png',
  ),
  // 5. Yeezy 350 V2
  SponsoredPost(
    username: 'Yeezy',
    content: '350 V2',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://tse1.mm.bing.net/th/id/OIP.hNficaGtPU8djSV8zKzIfQHaFL?rs=1&pid=ImgDetMain&o=7&rm=3',
    profileImageUrl: 'https://tse1.mm.bing.net/th/id/OIP.hNficaGtPU8djSV8zKzIfQHaFL?rs=1&pid=ImgDetMain&o=7&rm=3',
    adsMarket: '₱ 12,100.00',
    productUrl: 'https://tse1.mm.bing.net/th/id/OIP.hNficaGtPU8djSV8zKzIfQHaFL?rs=1&pid=ImgDetMain&o=7&rm=3',
  ),
  // 6. Vans Slip-On
  SponsoredPost(
    username: 'Vans',
    content: 'Slip-On',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/f8649f02-96f0-4c4c-b330-99cac1ea0c7a/NIKE+SB+JANOSKI%2B+SLIP.png',
    profileImageUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/f8649f02-96f0-4c4c-b330-99cac1ea0c7a/NIKE+SB+JANOSKI%2B+SLIP.png', 
    adsMarket: '₱ 1,800.00',
    productUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/f8649f02-96f0-4c4c-b330-99cac1ea0c7a/NIKE+SB+JANOSKI%2B+SLIP.png',
  ),
  // 7. Converse Chucks
  SponsoredPost(
    username: 'Converse',
    content: 'Chucks',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://tse3.mm.bing.net/th/id/OIP.zJVjxB6V9zIb-utpk7NpnQHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
    profileImageUrl: 'https://tse3.mm.bing.net/th/id/OIP.zJVjxB6V9zIb-utpk7NpnQHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
    adsMarket: '₱ 1,500.00',
    productUrl: 'https://tse3.mm.bing.net/th/id/OIP.zJVjxB6V9zIb-utpk7NpnQHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',
  ),
  // 8. Nike Air Force 1
  SponsoredPost(
    username: 'Nike',
    content: 'Air Force 1',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/b7d9211c-26e7-431a-ac24-b0540fb3c00f/AIR+FORCE+1+%2707.png',
    profileImageUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/b7d9211c-26e7-431a-ac24-b0540fb3c00f/AIR+FORCE+1+%2707.png',
    adsMarket: '₱ 3,200.00',
    productUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/b7d9211c-26e7-431a-ac24-b0540fb3c00f/AIR+FORCE+1+%2707.png',
  ),
  // 9. Puma Suede
  SponsoredPost(
    username: 'Puma',
    content: 'Suede',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/395205/02/sv01/fnd/PNA/fmt/png/Suede-XL-Sneakers',
    profileImageUrl: 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/395205/02/sv01/fnd/PNA/fmt/png/Suede-XL-Sneakers',
    adsMarket: '₱ 2,000.00',
    productUrl: 'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/395205/02/sv01/fnd/PNA/fmt/png/Suede-XL-Sneakers',
  ),
  // 10. Reebok Club C
  SponsoredPost(
    username: 'Reebok',
    content: 'Club C',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://is4.revolveassets.com/images/p4/n/uv/REEF-MZ65_V2.jpg',
    profileImageUrl: 'https://is4.revolveassets.com/images/p4/n/uv/REEF-MZ65_V2.jpg',
    adsMarket: '₱ 2,900.00',
    productUrl: 'https://is4.revolveassets.com/images/p4/n/uv/REEF-MZ65_V2.jpg',
  ),
  // 11. Asics Gel-Lyte
  SponsoredPost(
    username: 'Asics',
    content: 'Gel-Lyte',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://media.sivasdescalzo.com/media/catalog/product/1/2/1203A330-400_sivasdescalzo-Asics-GEL-LYTE_III_OG-1687351258-2.jpg',
    profileImageUrl: 'https://media.sivasdescalzo.com/media/catalog/product/1/2/1203A330-400_sivasdescalzo-Asics-GEL-LYTE_III_OG-1687351258-2.jpg',
    adsMarket: '₱ 3,600.00',
    productUrl: 'https://media.sivasdescalzo.com/media/catalog/product/1/2/1203A330-400_sivasdescalzo-Asics-GEL-LYTE_III_OG-1687351258-2.jpg',
  ),
  // 12. Saucony Jazz
  SponsoredPost(
    username: 'Saucony',
    content: 'Jazz',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://th.bing.com/th/id/OIP.L1v4Lej5aHhfr3FW6GqU0QHaD4?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
    profileImageUrl: 'https://th.bing.com/th/id/OIP.L1v4Lej5aHhfr3FW6GqU0QHaD4?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
    adsMarket: '₱ 2,300.00',
    productUrl: 'https://th.bing.com/th/id/OIP.L1v4Lej5aHhfr3FW6GqU0QHaD4?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
  ),
  // 13. Fila Disruptor
  SponsoredPost(
    username: 'Fila',
    content: 'Disruptor',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://th.bing.com/th/id/OIP.uWf-4-hEfXZIcwrgcWyIXwHaFj?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
    profileImageUrl: 'https://th.bing.com/th/id/OIP.uWf-4-hEfXZIcwrgcWyIXwHaFj?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
    adsMarket: '₱ 1,700.00',
    productUrl: 'https://th.bing.com/th/id/OIP.uWf-4-hEfXZIcwrgcWyIXwHaFj?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
  ),
  // 14. Under Armour Curry
  SponsoredPost(
    username: 'Under Armour',
    content: 'Curry',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://tse1.mm.bing.net/th/id/OIP.q7eKFo-4QdytFzE2hltR2AHaE8?rs=1&pid=ImgDetMain&o=7&rm=3',
    profileImageUrl: 'https://tse1.mm.bing.net/th/id/OIP.q7eKFo-4QdytFzE2hltR2AHaE8?rs=1&pid=ImgDetMain&o=7&rm=3',
    adsMarket: '₱ 5,100.00',
    productUrl: 'https://tse1.mm.bing.net/th/id/OIP.q7eKFo-4QdytFzE2hltR2AHaE8?rs=1&pid=ImgDetMain&o=7&rm=3',
  ),
  // 15. Nike Blazer Mid
  SponsoredPost(
    username: 'Nike',
    content: 'Blazer Mid',
    date: 'Sponsored',
    likes: 0,
    comments: 0,
    imagePath: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/fb7eda3c-5ac8-4d05-a18f-1c2c5e82e36e/BLAZER+MID+%2777+VNTG.png',
    profileImageUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/fb7eda3c-5ac8-4d05-a18f-1c2c5e82e36e/BLAZER+MID+%2777+VNTG.png',
    adsMarket: '₱ 3,400.00',
    productUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto/fb7eda3c-5ac8-4d05-a18f-1c2c5e82e36e/BLAZER+MID+%2777+VNTG.png',
  ),
];