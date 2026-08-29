import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/post_card.dart';
import '../widgets/custom_font.dart';
import '../constants.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: ScreenUtil().screenWidth,
        child: ListView.builder(
          // itemCount = Carousel (1) + Mixed Feed Items
          itemCount: mixedFeed.length + 1,
          itemBuilder: (context, index) {
            
            // ---------------------------------------------------------
            // ENHANCEMENT 2: Advertisement/Promotion Carousel
            // ---------------------------------------------------------
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(15)),
                    child: CustomFont(
                      text: 'Advertisement/ Promotion',
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.bold,
                      color: isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY,
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

            // ---------------------------------------------------------
            // ENHANCEMENT 1: Alternating Posts and Ads
            // ---------------------------------------------------------
            // Adjust index by -1 because index 0 is used by the Carousel
            int feedIndex = index - 1;
            final post = mixedFeed[feedIndex];

            // ---------------------------------------------------------
            // ENHANCEMENT 2: Advertisement/Promotion Carousel for Specific Ads
            // ---------------------------------------------------------
            if (post.date == 'Sponsored' && adCarousels.containsKey(post.username)) {
               final adImages = adCarousels[post.username]!;
               
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
                        postId: feedIndex * 5 + itemIndex + 1,
                        userName: item.username,        // Unique per slide
                        postContent: item.content,      // Unique per slide
                        numOfLikes: post.likes,         // Shared likes count
                        date: post.date,
                        imageUrl: item.imagePath,       // Unique image
                        profileImageUrl: item.profileImageUrl, // Unique avatar
                        adsMarket: item.adsMarket,      // Unique CTA
                        productUrl: item.productUrl,    // NEW: Unique link
                      );
                    }).toList(),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  Divider(thickness: 1, color: Theme.of(context).dividerColor),
                 ],
               );
            }

            return PostCard(
              postId: feedIndex + 1,
              userName: post.username,
              postContent: post.content,
              numOfLikes: post.likes,
              date: post.date,
              imageUrl: post.imagePath ?? '',
              profileImageUrl: post.profileImageUrl,
              adsMarket: post.adsMarket,
              productUrl: post.productUrl,
            );
          },
        ),
      ),
    );
  }
}
// --- DATA MODELS ---

class CarouselItem {
  final String imagePath;
  final String username;
  final String profileImageUrl;
  final String content;       // Optional: unique caption per slide
  final String adsMarket;     // Optional: unique CTA per slide
  final String? productUrl;   // Optional: direct link to product

  CarouselItem({
    required this.imagePath,
    required this.username,
    required this.profileImageUrl,
    this.content = '',
    this.adsMarket = 'Learn More',
    this.productUrl,
  });
}

class Post {
  final String username;
  final String content;
  final String date;
  final int likes;
  final int comments;
  final String? imagePath;
  final String profileImageUrl;
  final String adsMarket;
  final String? productUrl; // NEW: Direct link to product

  Post({
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

// --- DATA SOURCE ---

// Mapping for Ad Carousels (Exactly 3 for the Mixed Feed)
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

final List<Post> carouselPosts = [
  // 1. Nike Dunk Low
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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
  Post(
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

final List<Post> mixedFeed = [
  // --- Post 1 (User) ---
  Post(
    username: 'Sean Angelo Crame',
    content: 'Kwatro sana this sem T_T',
    date: 'October 11',
    likes: 100,
    comments: 10,
    imagePath: null,
    profileImageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=200&q=80',
  ),
  
  // --- Post 2 (Carousel 1 - Retro & Skate) ---
  Post(
    username: 'Retro & Skate',
    content: 'Timeless classics. Vans, New Balance, and more.',
    date: 'Sponsored',
    likes: 1200,
    comments: 45,
    imagePath: 'https://th.bing.com/th/id/R.b8541404bccde3a57ddbb7de60c8f3ac?rik=eHfLv8krXIu2rA&riu=http%3a%2f%2fshoenami.com.ph%2fcdn%2fshop%2ffiles%2fWS327KB-1.jpg%3fv%3d1690189059%26width%3d2048', 
    profileImageUrl: 'https://th.bing.com/th/id/R.b8541404bccde3a57ddbb7de60c8f3ac?rik=eHfLv8krXIu2rA&riu=http%3a%2f%2fshoenami.com.ph%2fcdn%2fshop%2ffiles%2fWS327KB-1.jpg%3fv%3d1690189059%26width%3d2048',
    adsMarket: 'Shop Classics',
  ),

  // --- Post 3 (User) ---
  Post(
    username: 'ako nalang kasi',
    content: 'Sana all',
    date: 'December 2',
    likes: 200,
    comments: 20,
    imagePath: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80',
    profileImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
  ),

  // --- Post 4 (Carousel 2 - Performance & Air) ---
  Post(
    username: 'Performance & Air',
    content: 'Engineered for speed. Innovation by Nike and Adidas.',
    date: 'Sponsored',
    likes: 4200,
    comments: 156,
    imagePath: 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/fjfip8ga1ep22vhxdcew/air-max-97-shoe-EBZrb8.png', 
    profileImageUrl: 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/fjfip8ga1ep22vhxdcew/air-max-97-shoe-EBZrb8.png',
    adsMarket: 'Shop Tech',
  ),
  
  // --- Post 5 (User) ---
  Post(
    username: 'Samuel',
    content: 'Aray ko',
    date: 'December 3',
    likes: 50,
    comments: 5,
    imagePath: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=500&q=80',
    profileImageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80',
  ),

  // --- Post 6 (Carousel 3 - Hype & Utility) ---
  Post(
    username: 'Hype & Utility',
    content: 'Grail status drops. Jordan, Salomon, Hoka, and Crocs.',
    date: 'Sponsored',
    likes: 8500,
    comments: 320,
    imagePath: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/c873f01d-4c83-4a08-ace4-a4ce8589f122/AIR+JORDAN+1+LOW+SE.png', 
    profileImageUrl: 'https://static.nike.com/a/images/t_web_pdp_936_v2/f_auto,u_126ab356-44d8-4a06-89b4-fcdcc8df0245,c_scale,fl_relative,w_1.0,h_1.0,fl_layer_apply/c873f01d-4c83-4a08-ace4-a4ce8589f122/AIR+JORDAN+1+LOW+SE.png',
    adsMarket: 'Explore Hype',
  ),

  // --- Post 7 (User) ---
  Post(
    username: 'Kurt',
    content: 'Baka kai makalimutan ko -_-',
    date: 'December 3',
    likes: 50,
    comments: 5,
    imagePath: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=500&q=80',
    profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
  ),
];