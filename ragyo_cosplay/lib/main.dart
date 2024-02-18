import 'package:flutter/material.dart';
import 'package:ragyo_cosplay/screens/home.dart';

void main() {
  runApp(const App());
}

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color.fromARGB(0, 221, 161, 228)),
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: theme, home: const HomeScreen());
  }
}
