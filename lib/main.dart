import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Vision Week Virtual Exploration',
            theme: themeProvider.getTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: AuthService().isUserLoggedIn() ? HomeScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}

// Enum for game states
enum GameState {
  playing,
  gameOver,
}

class FluttersGame extends Game {
  GameState currentGameState = GameState.playing;
  late Size viewport;
  late Background skyBackground;
  late Floor groundFloor;
  late Level currentLevel;
  late Bird birdPlayer;
  late TextComponent scoreText;
  late TextComponent floorText;
  late Dialog gameOverDialog;

  late double tileSize;
  late double birdPosY;
  double birdPosYOffset = 8;
  bool isFluttering = false;
  double flutterValue = 0;
  double flutterIntensity = 20;
  double floorHeight = 250;
  double currentHeight = 0; // Game score

  FluttersGame(Size screenDimensions) {
    resize(screenDimensions);
    skyBackground = Background(this, 0, 0, viewport.width, viewport.height);
    groundFloor = Floor(this, 0, viewport.height - floorHeight, viewport.width, floorHeight, 0xff48BB78);
    currentLevel = Level(this);
    birdPlayer = Bird(this, 0, birdPosY, tileSize, tileSize);
    scoreText = TextComponent(this, '0', 30.0, 60);
    floorText = TextComponent(this, 'Tap to flutter!', 40.0, viewport.height - floorHeight / 2);
    gameOverDialog = Dialog(this);
  }

  @override
  void resize(Size size) {
    viewport = size;
    tileSize = viewport.width / 6;
    birdPosY = viewport.height - floorHeight - tileSize + (tileSize / 8);
  }

  @override
  void render(Canvas c) {
    skyBackground.render(c);
    c.save();
    c.translate(0, currentHeight);
    currentLevel.levelObstacles.forEach((obstacle) {
      if (isObstacleInRange(obstacle)) {
        obstacle.render(c);
      }
    });
    groundFloor.render(c);
    floorText.render(c);
    c.restore();

    birdPlayer.render(c);

    if (currentGameState == GameState.gameOver) {
      gameOverDialog.render(c);
    } else {
      scoreText.render(c);
    }
  }

  @override
  void update(double t) {
    if (currentGameState == GameState.playing) {
      currentLevel.levelObstacles.forEach((obstacle) {
        if (isObstacleInRange(obstacle)) {
          obstacle.update(t);
        }
      });
      skyBackground.update(t);
      birdPlayer.update(t);

      scoreText.setText(currentHeight.floor().toString());
      scoreText.update(t);
      floorText.update(t);
      gameOverDialog.update(t);

      flutterHandler();
      checkCollision();
    }
  }

  void checkCollision() {
    currentLevel.levelObstacles.forEach((obstacle) {
      if (isObstacleInRange(obstacle)) {
        if (birdPlayer.toCollisionRect().overlaps(obstacle.toRect())) {
          obstacle.markHit();
          gameOver();
        }
      }
    });
  }

  void gameOver() {
    currentGameState = GameState.gameOver;
  }

  void restartGame() {
    birdPlayer.setRotation(0);
    currentHeight = 0;
    currentLevel.generateObstacles();
    currentGameState = GameState.playing;
  }

  bool isObstacleInRange(Obstacle obs) {
    return -obs.y < viewport.height + currentHeight && -obs.y > currentHeight - viewport.height;
  }

  void flutterHandler() {
    if (isFluttering) {
      flutterValue *= 0.8;
      currentHeight += flutterValue;
      birdPlayer.setRotation(-flutterValue * birdPlayer.direction * 1.5);

      if (flutterValue < 1) isFluttering = false;
    } else {
      if (flutterValue < 15) {
        flutterValue *= 1.2;
      }
      if (currentHeight > flutterValue) {
        birdPlayer.setRotation(flutterValue * birdPlayer.direction * 2);
        currentHeight -= flutterValue;
      } else if (currentHeight > 0) {
        currentHeight = 0;
        birdPlayer.setRotation(0);
      }
    }
  }

  void onTapDown(TapDownDetails d) {
    if (currentGameState != GameState.gameOver) {
      birdPlayer.startFlutter();
      isFluttering = true;
      flutterValue = flutterIntensity;
    } else if (gameOverDialog.playButton.contains(d.globalPosition)) {
      restartGame();
    } else if (gameOverDialog.creditsText.toRect().contains(d.globalPosition)) {
      _launchURL();
    }
  }

  void onTapUp(TapUpDetails d) {
    birdPlayer.endFlutter();
  }

  Future<void> _launchURL() async {
    const url = 'https://github.com/ecklf';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// Auth service class
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'An undefined error happened.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

// Theme provider class
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(isDark);
    notifyListeners();
  }

  ThemeData getTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData.dark().copyWith(
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    if (_themeMode != (isDark ? ThemeMode.dark : ThemeMode.light)) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeWidget(),
    MiniGameScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision Week Virtual Exploration'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          Switch(
            value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Switch to English
                },
                child: Text('English'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Switch to French
                },
                child: Text('Français'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'Mini-Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to Vision Week Virtual Exploration!'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _launchURL('https://kvnbbg.fr');
            },
            child: Text('Visit my blog'),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  _MiniGameScreenState createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  double _bankBalance = 100.0;
  double _temperature = 20.0;
  int _grabCount = 0;
  final Random _random = Random();

  void _grabAnimal() {
    int units = _random.nextInt(4) + 1;
    setState(() {
      _bankBalance += units * 10;
      _temperature += units * 2;
      _grabCount += units;
    });
  }

  double _calculateLevelProgress() {
    return (_grabCount % 100) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mini-Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bank Balance: \$${_bankBalance.toStringAsFixed(2)}'),
            Text('Temperature: ${_temperature.toStringAsFixed(1)}°C'),
            ElevatedButton(
              onPressed: _grabAnimal,
              child: Text('Grab Animal'),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: _calculateLevelProgress(),
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text('Level Progress: ${(_calculateLevelProgress() * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings'),
    );
  }
}

class DataService {
  final String apiUrl = "https://jsonplaceholder.typicode.com/posts";

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Post> posts = body.map((dynamic item) => Post.fromJson(item)).toList();
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(post.toJson()),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<Post> updatePost(int id, Post post) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(post.toJson()),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }
}
