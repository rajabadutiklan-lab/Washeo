import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/beranda_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const EwashoApp());
}

class EwashoApp extends StatelessWidget {
  const EwashoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EWASHO Kasir Laundry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE1251A)),
        textTheme: GoogleFonts.barlowTextTheme(),
      ),
      home: const BerandaScreen(),
    );
  }
}
