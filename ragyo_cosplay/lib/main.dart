import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ragyo_cosplay/screens/permissions.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 221, 161, 228),
    background: const Color.fromARGB(255, 239, 246, 238),
    onPrimaryContainer: const Color.fromARGB(255, 60, 13, 64),
  ),
  textTheme: GoogleFonts.montserratTextTheme(),
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: theme, home: const PermissionsScreen());
  }
}
