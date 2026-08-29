import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_info.dart'; 
import 'detail_screen.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: ScreenUtil().screenWidth,
        child: ListView.separated(
          itemCount: demoNotifications.length,
          separatorBuilder: (context, index) => Divider(color: Theme.of(context).dividerColor, height: 1),
          itemBuilder: (context, index) {
            final n = demoNotifications[index];
            
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      userName: n.name,
                      postContent: n.description,
                      date: n.date,
                      numOfLikes: 0, 
                      imageUrl: '', 
                      profileImageUrl: n.profileImage,
                    ),
                  ),
                );
              },
              child: CustomInfo(
                name: n.name,
                date: n.date,
                description: n.description,
                profileImage: n.profileImage,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppNotification {
  final String name;
  final String description;
  final String date;
  final String profileImage; 

  AppNotification({
    required this.name,
    required this.description,
    required this.date,
    required this.profileImage,
  });
}

// ALL IMAGES UPDATED TO NETWORK URLS
final List<AppNotification> demoNotifications = [
  AppNotification(
    name: 'Sean Angelo Crame',
    description: 'posted a new photo.',
    date: '2 mins ago',
    profileImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80',
  ),
  AppNotification(
    name: 'Sarah Connor',
    description: 'commented: "Looks great!"',
    date: '5 mins ago',
    profileImage: 'https://randomuser.me/api/portraits/women/44.jpg', 
  ),
  AppNotification(
    name: 'James Bond',
    description: 'liked your post.',
    date: '10 mins ago',
    profileImage: 'https://randomuser.me/api/portraits/men/32.jpg', 
  ),
  AppNotification(
    name: 'Samuel',
    description: 'commented on your post: "Sana all"',
    date: '10 mins ago',
    profileImage: 'https://randomuser.me/api/portraits/men/32.jpg', 
  ),
  AppNotification(
    name: 'FaceGram Security',
    description: 'We noticed a new login from a device you don\'t usually use.',
    date: '1 hr ago',
    profileImage: '', 
  ),
  AppNotification(
    name: 'Kurt',
    description: 'mentioned you in a comment.',
    date: '3 hrs ago',
    profileImage: 'https://randomuser.me/api/portraits/men/85.jpg', 
  ),
  AppNotification(
    name: 'Emily Rose',
    description: 'shared a memory with you.',
    date: '4 hrs ago',
    profileImage: 'https://randomuser.me/api/portraits/women/68.jpg', 
  ),
  AppNotification(
    name: 'ako nalang kasi',
    description: 'sent you a friend request.',
    date: '5 hrs ago',
    profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80', 
  ),
  AppNotification(
    name: 'System',
    description: 'Your password was successfully changed.',
    date: 'Yesterday',
    profileImage: '',
  ),
  AppNotification(
    name: 'Travel Buddies',
    description: 'posted in the group "Backpackers PH".',
    date: 'Yesterday',
    profileImage: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80', 
  ),
  AppNotification(
    name: 'John Doe',
    description: 'liked your cover photo.',
    date: '2 days ago',
    profileImage: 'https://th.bing.com/th/id/OIP.lRjYAiUvhN2HUSrLikoiFAHaKN?w=141&h=195&c=7&r=0&o=7&pid=1.7&rm=3', 
  ),
  AppNotification(
    name: 'Jane Smith',
    description: 'shared your post.',
    date: '2 days ago',
    profileImage: 'https://randomuser.me/api/portraits/women/22.jpg', 
  ),
  AppNotification(
    name: 'Event Reminder',
    description: 'It\'s Samuel\'s birthday today! Wish him the best.',
    date: '3 days ago',
    profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
  ),
  AppNotification(
    name: 'Mark Z.',
    description: 'poked you.',
    date: '4 days ago',
    profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
  ),
  AppNotification(
    name: 'Group Admin',
    description: 'approved your request to join "Flutter Developers".',
    date: '5 days ago',
    profileImage: '',
  ),
];