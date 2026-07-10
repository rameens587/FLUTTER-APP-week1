import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/program_listing_screen.dart';
import 'screens/program_details_screen.dart';

void main() {
  runApp(const ExcelerateConnectApp());
}

class ExcelerateConnectApp extends StatelessWidget {
  const ExcelerateConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2E5EAA);

    return MaterialApp(
      title: 'Excelerate Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: seedColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDE1E6)),
          ),
        ),
      ),
      // Named routes map directly to the navigation flow documented in
      // the wireframes: Login -> Home -> Program Listing -> Program Details.
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/programs': (context) => const ProgramListingScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/program-details') {
          final programId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ProgramDetailsScreen(programId: programId),
          );
        }
        return null;
      },
    );
  }
}
