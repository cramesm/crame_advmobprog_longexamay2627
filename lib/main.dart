import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:crame_longexam/providers/theme_provider.dart';
import 'package:crame_longexam/screens/home_screen.dart';
import 'package:crame_longexam/screens/login_screen.dart';
import 'package:crame_longexam/screens/register_screen.dart';
import 'package:crame_longexam/screens/settings_screen.dart';
import 'package:crame_longexam/screens/splash_screen.dart';
import 'package:crame_longexam/constants.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const CrameFacebook(),
      ),
    );

class CrameFacebook extends StatelessWidget {
  const CrameFacebook({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          scrollBehavior: AppScrollBehavior(),
          debugShowCheckedModeBanner: false,
          title: 'FaceGram',
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.light,
            primaryColor: FB_PRIMARY,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            dividerColor: Colors.black12,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: FB_PRIMARY,
              elevation: 1,
              iconTheme: IconThemeData(color: FB_PRIMARY),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: FB_PRIMARY,
              unselectedItemColor: Colors.grey,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
              bodyLarge: TextStyle(color: Colors.black),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.dark,
            primaryColor: FB_LIGHT_PRIMARY,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: const Color(0xFF2C2C2C),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 1,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: FB_LIGHT_PRIMARY,
              unselectedItemColor: Colors.grey,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/splash': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LogInScreen(),
            '/register': (context) => const RegisterScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}