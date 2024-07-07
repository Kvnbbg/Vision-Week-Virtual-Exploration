import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool useFirebase = true; // Toggle this based on your needs or configuration

  if (useFirebase) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      useFirebase = false;
      print('Failed to initialize Firebase: $e');
    }
  }

  runApp(MyApp(useFirebase: useFirebase));
}

class MyApp extends StatelessWidget {
  final bool useFirebase;

  MyApp({required this.useFirebase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login/Register by Kevin Marville',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: LoginRegisterScreen(useFirebase: useFirebase),
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  final bool useFirebase;

  LoginRegisterScreen({required this.useFirebase});

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool showLogin = true; // Toggle between login and register screen
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String errorMessage = '';
  Database? database;

  @override
  void initState() {
    super.initState();
    if (!widget.useFirebase) {
      _initDatabase();
    }
  }

  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)",
        );
      },
      version: 1,
    );
  }

  void _login() async {
    // Implement login logic here
    // Use Firebase Authentication or local database
  }

  void _register() async {
    // Implement registration logic here
    // Use Firebase Authentication or local database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showLogin ? 'Login' : 'Register'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (showLogin) {
                      _login();
                    } else {
                      _register();
                    }
                  }
                },
                child: Text(showLogin ? 'Login' : 'Register'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    showLogin = !showLogin;
                  });
                },
                child: Text(showLogin
                    ? 'Don\'t have an account? Register'
                    : 'Already have an account? Login'),
              ),
              SizedBox(height: 16),
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

  void _register() async {
    // Implement registration logic here
    // Use Firebase Authentication or local database
    if (widget.useFirebase) {
      // Firebase registration logic
    } else {
      // Local database registration logic
      if (database != null) {
        try {
          await database!.insert(
            'users',
            {'username': username, 'password': password},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print('User registered successfully!');
        } catch (e) {
          print('Error registering user: $e');
          setState(() {
            errorMessage = 'Error registering user';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Database not initialized';
        });
      }
    }
  }

  void _login() async {
    // Implement login logic here
    // Use Firebase Authentication or local database
    if (widget.useFirebase) {
      // Firebase login logic
    } else {
      // Local database login logic
      if (database != null) {
        try {
          final List<Map<String, dynamic>> users = await database!.query(
            'users',
            where: 'username = ?',
            whereArgs: [username],
          );
          if (users.isNotEmpty && users[0]['password'] == password) {
            print('Login successful!');
          } else {
            print('Invalid username or password');
            setState(() {
              errorMessage = 'Invalid username or password';
            });
          }
        } catch (e) {
          print('Error logging in: $e');
          setState(() {
            errorMessage = 'Error logging in';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Database not initialized';
        });
      }
    }
  }
}

class LoginRegisterScreen extends StatefulWidget {
  final bool useFirebase;

  LoginRegisterScreen({required this.useFirebase});

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool showLogin = true; // Toggle between login and register screen
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String errorMessage = '';
  Database? database;

  @override
  void initState() {
    super.initState();
    if (!widget.useFirebase) {
      _initDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Implement UI here
    return Scaffold(
      appBar: AppBar(title: Text(showLogin ? 'Login' : 'Register')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Add TextFormFields for username and password
            // Add buttons for toggling login/register and submitting
          ],
        ),
      ),
    );
  }
}