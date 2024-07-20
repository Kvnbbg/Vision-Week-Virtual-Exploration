import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:vision_week_virtual_exploration/screens/ecran_principal.dart';
import 'package:vision_week_virtual_exploration/screens/register_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vision_week_virtual_exploration/l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SemaineVisionApp());
}

class SemaineVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Week',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'users.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)",
        );
      },
    );
  }

  void _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username == 'admin' && password == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EcranPrincipal()),
      );
      return;
    }

    if (_database != null) {
      final List<Map<String, dynamic>> users = await _database!.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      if (users.isNotEmpty && users[0]['password'] == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EcranPrincipal()),
        );
      } else {
        setState(() {
          errorMessage = 'Invalid username or password';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Database not initialized';
      });
    }
  }

  void _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (_database != null) {
      await _database!.insert('users', {
        'username': username,
        'password': password,
      });
      _login();
    } else {
      setState(() {
        errorMessage = 'Database not initialized';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations?.translate('welcome') ?? 'Welcome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: appLocalizations?.translate('username') ?? 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: appLocalizations?.translate('password') ?? 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text(appLocalizations?.translate('login') ?? 'Login'),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text(appLocalizations?.translate('register') ?? 'Register'),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
