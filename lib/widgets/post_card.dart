import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/detail_screen.dart';
import '../constants.dart';
import 'custom_font.dart';

// Enhancement 2 & 3: Reusable post card with interactive like and detail navigation
class PostCard extends StatefulWidget {
  final int postId;
  final int userId;
  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final String imageUrl;
  final String profileImageUrl;
  final String adsMarket; // If not empty, renders ad layout
  final String? productUrl;

  const PostCard({
    super.key,
    this.postId = 1,
    this.userId = 1,
    required this.userName,
    required this.postContent,
    this.numOfLikes = 0,
    required this.date,
    this.imageUrl = '',
    this.profileImageUrl = '',
    this.adsMarket = '',
    this.productUrl,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    likesCount = widget.numOfLikes;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numOfLikes != widget.numOfLikes) {
      likesCount = widget.numOfLikes;
    }
  }

  // Enhancement 3: Navigates to DetailScreen with postId and post details
  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          postId: widget.postId,
          userId: widget.userId,
          userName: widget.userName,
          postContent: widget.adsMarket.isNotEmpty ? widget.adsMarket : widget.postContent,
          numOfLikes: likesCount,
          date: widget.date,
          imageUrl: widget.imageUrl,
          profileImageUrl: widget.profileImageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY;

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Card(
        elevation: isDark ? 1 : 2,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        margin: EdgeInsets.all(ScreenUtil().setSp(10)),
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setSp(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (widget.profileImageUrl == '')
                      ? CircleAvatar(
                          radius: 20.r,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          child: Icon(Icons.person, color: isDark ? Colors.white70 : Colors.grey.shade700),
                        )
                      : CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: 40.r,
                              height: 40.r,
                              imageUrl: widget.profileImageUrl,
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                color: primaryAccent,
                                value: downloadProgress.progress,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: widget.userName,
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                            size: ScreenUtil().setSp(12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.more_horiz, color: isDark ? Colors.white70 : Colors.grey),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(5)),

              // Post Content
              if (widget.postContent.isNotEmpty) ...[
                CustomFont(
                  text: widget.postContent,
                  fontSize: ScreenUtil().setSp(13),
                ),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],

              // Post Image
              (widget.imageUrl == '')
                  ? const SizedBox()
                  : SizedBox(
                      height: ScreenUtil().setHeight(172),
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              color: primaryAccent,
                              value: downloadProgress.progress,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),

              SizedBox(height: ScreenUtil().setHeight(10)),

              // Standard Action Buttons
              if (widget.adsMarket == '') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enhancement 3: Clickable like button
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          if (isLiked) {
                            likesCount--;
                            isLiked = false;
                          } else {
                            likesCount++;
                            isLiked = true;
                          }
                        });
                      },
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: isLiked ? primaryAccent : Colors.grey,
                      ),
                      label: CustomFont(
                        text: (likesCount == 0 && !isLiked) ? 'Like' : likesCount.toString(),
                        fontSize: ScreenUtil().setSp(12),
                        color: isLiked ? primaryAccent : Colors.grey,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _navigateToDetail,
                      icon: Icon(Icons.comment_outlined, color: primaryAccent),
                      label: CustomFont(
                        text: 'Comment',
                        fontSize: ScreenUtil().setSp(12),
                        color: primaryAccent,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined, color: primaryAccent),
                      label: CustomFont(
                        text: 'Share',
                        fontSize: ScreenUtil().setSp(12),
                        color: primaryAccent,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _navigateToDetail,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        child: Icon(Icons.person, size: 15, color: isDark ? Colors.white70 : Colors.grey),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setSp(12),
                            vertical: 8,
                          ),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(ScreenUtil().setSp(18)),
                          ),
                          child: CustomFont(
                            text: 'Write a comment...',
                            fontSize: ScreenUtil().setSp(11),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(8)),
                GestureDetector(
                  onTap: _navigateToDetail,
                  child: CustomFont(
                    text: 'View comments',
                    fontSize: ScreenUtil().setSp(12),
                    fontWeight: FontWeight.bold,
                    color: primaryAccent,
                  ),
                ),
              ],

              // Ad Footer Layout
              if (widget.adsMarket != '')
                Container(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFont(
                            text: 'MORE DETAILS',
                            fontSize: ScreenUtil().setSp(10),
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                          CustomFont(
                            text: widget.adsMarket,
                            fontSize: ScreenUtil().setSp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          if (widget.productUrl != null && widget.productUrl!.isNotEmpty) {
                            final Uri url = Uri.parse(widget.productUrl!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                              return;
                            }
                          }

                          if (!context.mounted) return;
                          _navigateToDetail();
                        },
                        child: Container(
                          width: ScreenUtil().setWidth(80),
                          height: ScreenUtil().setHeight(35),
                          decoration: BoxDecoration(
                            color: primaryAccent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}