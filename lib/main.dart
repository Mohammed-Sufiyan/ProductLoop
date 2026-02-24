import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/core/providers/theme_provider.dart';
import 'package:productloop/core/storage/hive_service.dart';
import 'package:productloop/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local persistence
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Product Loop',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF9333EA), // Purple 600
          secondary: const Color(0xFFA855F7), // Light Purple 400
          surfaceContainer: const Color(0xFFF8FAFC), // Slate 50
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          bodyLarge: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF334155)),
          bodyMedium: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569)),
          bodySmall: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
          titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: GoogleFonts.outfit(
            color: const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), 
          primary: const Color(0xFFA855F7), // Purple 400
          secondary: const Color(0xFFC084FC), 
          surfaceContainer: const Color(0xFF0F172A), // Slate 900
          surface: const Color(0xFF1E293B), // Slate 800
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFF1F5F9)),
          bodyMedium: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFCBD5E1)),
          bodySmall: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
          titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFF8FAFC)),
          titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFF8FAFC)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 1,
          iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
          titleTextStyle: GoogleFonts.outfit(
            color: const Color(0xFFF8FAFC),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F172A),
          unselectedItemColor: Color(0xFF64748B),
          selectedItemColor: Color(0xFFA855F7),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
