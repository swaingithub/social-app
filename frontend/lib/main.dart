
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/providers/user_provider.dart';
import 'package:jivvi/core/routing/app_router.dart';
import 'package:jivvi/core/services/api_service.dart';
import 'package:jivvi/theme/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, __) {
          return MaterialApp.router(
            title: 'Flutter Social Media App',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  var baseTheme = ThemeData(brightness: brightness);
  const primaryColor = Color(0xFF8E44AD);
  const secondaryColor = Color(0xFFF1C40F);

  return baseTheme.copyWith(
    primaryColor: primaryColor,
    colorScheme: baseTheme.colorScheme.copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: brightness == Brightness.light ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50),
      background: brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF212F3D),
    ),
    textTheme: GoogleFonts.nunitoTextTheme(baseTheme.textTheme).apply(
      bodyColor: brightness == Brightness.light ? const Color(0xFF2C3E50) : const Color(0xFFECF0F1),
      displayColor: brightness == Brightness.light ? const Color(0xFF2C3E50) : const Color(0xFFECF0F1),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: brightness == Brightness.light ? const Color(0xFF2C3E50) : const Color(0xFFECF0F1)),
      titleTextStyle: TextStyle(
        color: brightness == Brightness.light ? const Color(0xFF2C3E50) : const Color(0xFFECF0F1),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.nunito().fontFamily,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF2C3E50),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light ? Colors.white : const Color(0xFF2C3E50),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: Colors.grey,
        fontFamily: GoogleFonts.nunito().fontFamily,
      ),
    ),
  );
}
