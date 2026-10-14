import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/app_database.dart';
import 'ui/screens/home_gen_ui_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: GenUiShopApp(),
    ),
  );
}

class GenUiShopApp extends StatelessWidget {
  const GenUiShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GenUI Shop Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
      ),
      home: const HomeGenUiScreen(),
    );
  }
}