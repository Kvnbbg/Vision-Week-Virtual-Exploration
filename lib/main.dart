import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VisionWeekApp());
}

class VisionWeekApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Vision Week 🎉',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: TextTheme(
                headlineMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData.dark(),
            themeMode: settingsProvider.themeMode,
            locale: settingsProvider.locale,
            supportedLocales: [Locale('en', ''), Locale('fr', '')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = Locale('en', '');
  String _username = '';

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  String get username => _username;

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  void switchLocale(String languageCode) async {
    _locale = Locale(languageCode, '');
    await _saveSettings();
    notifyListeners();
  }

  void setUsername(String input, BuildContext context) async {
    _username = _generateUsername(input);
    await _saveSettings();
    _showUsernameModifiedPopup(context);
    notifyListeners();
  }

  String _generateUsername(String input) {
    input = input.trim(); // Trim leading and trailing whitespace
    if (input.isEmpty) return "User";

    StringBuffer username = StringBuffer();
    bool hasAlpha = false;

    for (int i = 0; i < input.length; i++) {
      if (isAlphanumeric(input[i])) {
        username.write(input[i]);
        if (isAlphabetic(input[i])) hasAlpha = true;
      }
    }

    if (!hasAlpha) {
      username.write("User"); // Ensure the username contains alphabetic characters
    }

    return username.toString().isEmpty ? "User" : username.toString();
  }

  bool isAlphanumeric(String char) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(char);
  }

  bool isAlphabetic(String char) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(char);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkTheme') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    _username = prefs.getString('username') ?? "User";
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
    await prefs.setString('languageCode', _locale.languageCode);
    await prefs.setString('username', _username);
  }

  void _showUsernameModifiedPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud, size: 50, color: Colors.blueAccent),
              SizedBox(height: 10),
              Text(
                'Username Modified!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your username has been modified to follow the Kvnbbg story as featured in his ebooks, blog posts, and other adventures!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Got it!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static final _widgetOptions = [HomeContent(), ArenaScreen(), SettingsScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Center(child: _widgetOptions[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: AppLocalizations.of(context)!.arena),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppLocalizations.of(context)!.settings),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.welcomeMessage, style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 20),
          Text('Author: Kevin Marville\nLinkedIn: https://linkedin.com/in/kevin-marville', textAlign: TextAlign.center),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text(AppLocalizations.of(context)!.visitBlog),
          ),
        ],
      ),
    );
  }
}

class ArenaScreen extends StatefulWidget {
  @override
  _ArenaScreenState createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  int _score = 0;
  final _adversaries = List.generate(4, (index) {
    final random = Random();
    final adversaryNames = ['Fire Wizard 🔥', 'Ice Queen ❄️', 'Earth Giant 🌍', 'Wind Spirit 🌬️'];
    return Adversary(
      name: adversaryNames[random.nextInt(adversaryNames.length)],
      strength: random.nextInt(100),
    );
  });

  void _fightAdversary() {
    final random = Random();
    final adversary = _adversaries[random.nextInt(_adversaries.length)];
    setState(() {
      _score += random.nextInt(100) < adversary.strength ? -10 : 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.arena)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${AppLocalizations.of(context)!.score}: $_score', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _fightAdversary, child: Text(AppLocalizations.of(context)!.fight)),
            SizedBox(height: 20),
            Column(
              children: _adversaries.map((adversary) => Text('${adversary.name} - ${adversary.strength} 💪')).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class Adversary {
  final String name;
  final int strength;

  Adversary({required this.name, required this.strength});
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.settings, style: Theme.of(context).textTheme.headlineSmall),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.darkTheme),
            value: settingsProvider.themeMode == ThemeMode.dark,
            onChanged: settingsProvider.toggleTheme,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => settingsProvider.switchLocale('en'), child: Text('English')),
              SizedBox(width: 10),
              ElevatedButton(onPressed: () => settingsProvider.switchLocale('fr'), child: Text('Français')),
            ],
          ),
        ],
      ),
    );
  }
}
 
