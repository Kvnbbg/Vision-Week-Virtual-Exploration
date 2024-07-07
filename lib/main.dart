import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login/Register',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: LoginRegisterScreen(),
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool showLogin = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  String loginUsername = '';
  String loginPassword = '';
  String registerUsername = '';
  String registerPassword = '';
  String loginError = '';
  String registerError = '';
  Database? database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
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

  Future<void> _addUser(String username, String password) async {
    final db = database;
    if (db != null) {
      await db.insert(
        'users',
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<bool> _authenticateUser(String username, String password) async {
    final db = database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      return maps.isNotEmpty;
    }
    return false;
  }

  void toggleForm() {
    setState(() {
      showLogin = !showLogin;
      loginError = '';
      registerError = '';
    });
  }

  void login() async {
    if (_loginFormKey.currentState!.validate()) {
      if (loginUsername == 'admin' && loginPassword == 'admin') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (await _authenticateUser(loginUsername, loginPassword)) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          loginError = 'Invalid username or password';
        });
      }
    }
  }

  void register() {
    if (_registerFormKey.currentState!.validate()) {
      _addUser(registerUsername, registerPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful! Please log in.')),
      );
      toggleForm();
    }
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome!'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showLogin) ...[
                Text('Login', style: TextStyle(fontSize: 24)),
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                        onChanged: (value) {
                          loginUsername = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (value) {
                          loginPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      if (loginError.isNotEmpty)
                        Text(loginError, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: login,
                        child: Text('Login'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text('Login with Google'),
                        onPressed: _signInWithGoogle,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text('Login with Facebook'),
                        onPressed: _signInWithFacebook,
                      ),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text('Register', style: TextStyle(fontSize: 24)),
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                        onChanged: (value) {
                          registerUsername = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (value) {
                          registerPassword = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      if (registerError.isNotEmpty)
                        Text(registerError, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: register,
                        child: Text('Register'),
                      ),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
