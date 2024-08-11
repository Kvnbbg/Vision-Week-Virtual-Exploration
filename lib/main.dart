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

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkTheme') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
    await prefs.setString('languageCode', _locale.languageCode);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
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
 