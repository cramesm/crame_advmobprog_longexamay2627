import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_font.dart'; 

class CustomInfo extends StatelessWidget {
  final String name;
  final String description;
  final String date; 
  final String profileImage;

  const CustomInfo({
    super.key,
    required this.name,
    required this.description,
    required this.date,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper to determine Image Provider
    ImageProvider? getImageProvider(String path) {
      if (path.isEmpty) return null;
      if (path.startsWith('http')) {
        return NetworkImage(path);
      } else {
        return AssetImage(path);
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setHeight(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: ScreenUtil().setSp(25),
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            backgroundImage: getImageProvider(profileImage),
            child: (profileImage.isEmpty)
                ? Icon(
                    Icons.notifications,
                    color: isDark ? Colors.white70 : Colors.white,
                    size: ScreenUtil().setSp(25),
                  )
                : null,
          ),
          SizedBox(width: ScreenUtil().setWidth(15)),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomFont(
                      text: name,
                      fontSize: ScreenUtil().setSp(16),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    CustomFont(
                      text: date,
                      fontSize: ScreenUtil().setSp(12),
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(5)),
                CustomFont(
                  text: description,
                  fontSize: ScreenUtil().setSp(14),
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}