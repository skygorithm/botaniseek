import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'BotaniSeek',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
          useMaterial3: true,
        ),
        home: const HomePage(title: 'BotaniSeek'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // Example app-wide states
  final List<Map<String, String>> _favoritePlants = [];

  List<Map<String, String>> get favoritePlants => _favoritePlants;

  void toggleFavorite(Map<String, String> plant) {
    if (_favoritePlants.contains(plant)) {
      _favoritePlants.remove(plant);
    } else {
      _favoritePlants.add(plant);
    }
    notifyListeners();
  }

  bool isFavorite(Map<String, String> plant) {
    return _favoritePlants.contains(plant);
  }
}
