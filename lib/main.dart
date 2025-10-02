import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WordHuntApp());
}

// Main App with named routes for navigation
class WordHuntApp extends StatelessWidget {
  const WordHuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word War',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/difficulty': (_) => const DifficultySelectionScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}

// -------------
// 1. Home Screen with Drawer Navigation
// -------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Random _rnd = Random();

  // Animation controllers
  late AnimationController _bombBlinkController;
  late AnimationController _letterBlinkController;

  // Animations
  late Animation<double> _bombBlinkAnimation;
  late Animation<double> _letterBlinkAnimation;

  // Blinking and falling elements
  final List<_FallingElement> _fallingElements = [];
  Timer? _animationTimer;
  String _currentPlayerName = 'Player';
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadPlayerInfo();
    _initAnimations();
    _initFallingElements();
    _startAnimation();
  }

  Future<void> _loadPlayerInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentPlayerName = prefs.getString('currentPlayerName') ?? 'Player';
        _highScore = prefs.getInt('highScore') ?? 0;
      });
    }
  }

  void _initAnimations() {
    // Bomb blinking animation
    _bombBlinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bombBlinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _bombBlinkController, curve: Curves.easeInOut),
    );
    _bombBlinkController.repeat(reverse: true);

    // Letter blinking animation
    _letterBlinkController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _letterBlinkAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _letterBlinkController, curve: Curves.easeInOut),
    );
    _letterBlinkController.repeat(reverse: true);
  }

  void _initFallingElements() {
    _fallingElements.clear();
    // Add bombs falling from top
    for (int i = 0; i < 12; i++) {
      _fallingElements.add(_FallingElement(
        char: '💣',
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble() * -0.5,
        speed: 0.002 + _rnd.nextDouble() * 0.003,
        size: 20.0 + _rnd.nextDouble() * 15.0,
        isBomb: true,
      ));
    }
    // Add A-Z letters falling from top
    final letters = <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    ];
    for (int i = 0; i < 26; i++) {
      _fallingElements.add(_FallingElement(
        char: letters[i],
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble() * -0.5,
        speed: 0.0015 + _rnd.nextDouble() * 0.0025,
        size: 18.0 + _rnd.nextDouble() * 12.0,
        isBomb: false,
      ));
    }
  }

  void _startAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (Timer timer) {
      if (mounted) {
        setState(() {
          for (var element in _fallingElements) {
            element.y += element.speed;
            if (element.y > 1.2) {
              element.y = -0.1;
              element.x = _rnd.nextDouble();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _bombBlinkController.dispose();
    _letterBlinkController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Word War')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.games, size: 50, color: Colors.yellow),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome, $_currentPlayerName!',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'High Score: $_highScore',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/difficulty');
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leaderboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/leaderboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/profile');
                _loadPlayerInfo(); // Reload after returning from profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          // Blinking and falling elements
          ..._fallingElements.map<Widget>((_FallingElement element) {
            return Positioned(
              left: element.x * screenW,
              top: element.y * screenH,
              child: AnimatedBuilder(
                animation: element.isBomb
                    ? _bombBlinkAnimation
                    : _letterBlinkAnimation,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: element.isBomb
                        ? _bombBlinkAnimation.value
                        : _letterBlinkAnimation.value,
                    child: Text(
                      element.char,
                      style: TextStyle(
                        fontSize: element.size,
                        fontWeight: FontWeight.bold,
                        color: element.isBomb ? Colors.red : Colors.cyan,
                        shadows: const <Shadow>[
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.games,
                  size: 60,
                  color: Colors.yellow,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Word War',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    shadows: <Shadow>[
                      Shadow(
                        blurRadius: 8,
                        color: Colors.orange,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Welcome to Word War!\nOpen the drawer to start playing.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Swipe from left edge to open menu',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Falling element class
class _FallingElement {
  String char;
  double x;
  double y;
  double speed;
  double size;
  bool isBomb;

  _FallingElement({
    required this.char,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.isBomb,
  });
}

// -------------
// 2. Difficulty Selection Screen
// -------------

enum Difficulty { easy, medium, hard }

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  final Random _rnd = Random();
  final List<_FallingLetter> _fallingLetters = [];
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _initLetters();
    _startAnimation();
  }

  void _initLetters() {
    _fallingLetters.clear();
    for (int i = 0; i < 40; i++) {
      _fallingLetters.add(_FallingLetter(
        char: String.fromCharCode(65 + _rnd.nextInt(26)),
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble(),
        speed: 0.001 + _rnd.nextDouble() * 0.003,
        color: Color.fromARGB(
          255,
          100 + _rnd.nextInt(156),
          100 + _rnd.nextInt(156),
          100 + _rnd.nextInt(156),
        ),
      ));
    }
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (Timer timer) {
      if (mounted) {
        setState(() {
          for (var letter in _fallingLetters) {
            letter.y += letter.speed;
            if (letter.y > 1.0) {
              letter.y = 0.0;
              letter.x = _rnd.nextDouble();
              letter.char = String.fromCharCode(65 + _rnd.nextInt(26));
              letter.color = Color.fromARGB(
                255,
                100 + _rnd.nextInt(156),
                100 + _rnd.nextInt(156),
                100 + _rnd.nextInt(156),
              );
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _openGame(Difficulty difficulty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<GameScreen>(
        builder: (_) => GameScreen(difficulty: difficulty),
      ),
    );
  }

  String _getDifficultyInfo(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '3 minutes • Less bombs';
      case Difficulty.medium:
        return '2 minutes • More bombs';
      case Difficulty.hard:
        return '1:30 minutes • Many bombs';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Difficulty')),
      body: Stack(
        children: <Widget>[
          // Falling colorful letters background animation
          ..._fallingLetters.map<Widget>((_FallingLetter letter) {
            return Positioned(
              left: letter.x * screenW,
              top: letter.y * screenH,
              child: Text(
                letter.char,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: letter.color,
                  shadows: const <Shadow>[
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
              ),
            );
          }),

          // Title and buttons
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 40),
                const Text(
                  'Select Difficulty',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // Easy difficulty button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => _openGame(Difficulty.easy),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Column(
                      children: [
                        const Text('EASY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(_getDifficultyInfo(Difficulty.easy), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                
                // Medium difficulty button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => _openGame(Difficulty.medium),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Column(
                      children: [
                        const Text('MEDIUM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(_getDifficultyInfo(Difficulty.medium), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                
                // Hard difficulty button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => _openGame(Difficulty.hard),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Column(
                      children: [
                        const Text('HARD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(_getDifficultyInfo(Difficulty.hard), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Background letter class
class _FallingLetter {
  String char;
  double x;
  double y;
  double speed;
  Color color;

  _FallingLetter({
    required this.char,
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
  });
}

// -------------
// 3. Game Screen with profile saving and timeout
// -------------

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _rnd = Random();

  Timer? _spawnTimer;
  Timer? _gameLoopTimer;
  Timer? _timeoutTimer;

  late double screenW;
  late double screenH;

  final List<_Star> _stars = [];

  final List<String> _wordBank = <String>[
    'HUNT', 'GAME', 'FLUTTER', 'SPACE', 'STAR', 'CODE', 'ROCKET',
    'DART', 'WORD', 'FIRE', 'BOMB', 'SHOOT', 'WIN', 'SCORE'
  ];
  late String _targetWord;
  int _progressIndex = 0;

  final List<_FallingLetter> _letters = [];
  int _spawnCount = 0;

  final List<_Bomb> _bombs = [];

  double _gunX = 0.5;
  final double _gunWidthNorm = 0.12;
  final double _gunHeightPx = 24;

  final List<_Bullet> _bullets = [];

  late int _spawnIntervalMs;
  late double _letterFallSpeedNorm;
  late double _bulletSpeedNorm;
  late int _bombSpawnChance;
  late int _timeoutSeconds;

  static const int _loopMs = 16;

  int _score = 0;
  int _highScore = 0;
  String _currentPlayerName = 'Player';
  
  // Timer variables
  int _remainingTime = 0;
  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    _chooseDifficultySettings();
    _targetWord = _wordBank[_rnd.nextInt(_wordBank.length)];
    _initStars();
    _loadScores();
    _startSpawnTimer();
    _startGameLoop();
    _startTimeoutTimer();
  }

  Future<void> _loadScores() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _score = 0; // Always start with 0
        _highScore = prefs.getInt('highScore') ?? 0;
        _currentPlayerName = prefs.getString('currentPlayerName') ?? 'Player';
      });
    }
  }

  Future<void> _saveGameProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Save current game data
    await prefs.setString('currentPlayerName', _currentPlayerName);
    await prefs.setInt('currentGameScore', _score);
    
    // Update high score if current score is better
    if (_score > _highScore) {
      await prefs.setInt('highScore', _score);
      await prefs.setString('highScoreHolder', _currentPlayerName);
      setState(() {
        _highScore = _score;
      });
    }
  }

  Future<void> _saveScores() async {
    await _saveGameProfile();
  }

  Future<String> _getPlayerName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentPlayerName') ?? 'Player';
  }

  void _chooseDifficultySettings() {
    switch (widget.difficulty) {
      case Difficulty.easy:
        _spawnIntervalMs = 1200;
        _letterFallSpeedNorm = 0.004;
        _bulletSpeedNorm = 0.018;
        _bombSpawnChance = 12; // Less bombs (1 in 12 chance)
        _timeoutSeconds = 180; // 3 minutes (180 seconds)
        break;
      case Difficulty.medium:
        _spawnIntervalMs = 900;
        _letterFallSpeedNorm = 0.007;
        _bulletSpeedNorm = 0.022;
        _bombSpawnChance = 6; // More bombs (1 in 6 chance)
        _timeoutSeconds = 120; // 2 minutes (120 seconds)
        break;
      case Difficulty.hard:
        _spawnIntervalMs = 650;
        _letterFallSpeedNorm = 0.010;
        _bulletSpeedNorm = 0.028;
        _bombSpawnChance = 3; // Many bombs (1 in 3 chance)
        _timeoutSeconds = 90; // 1:30 minutes (90 seconds)
        break;
    }
    _remainingTime = _timeoutSeconds;
  }

  void _initStars() {
    _stars.clear();
    for (int i = 0; i < 60; i++) {
      _stars.add(_Star(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble(),
          speed: 0.0008 + _rnd.nextDouble() * 0.0025,
          size: 1.0 + _rnd.nextDouble() * 3.0));
    }
  }

  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnCount = 0;
    _spawnTimer =
        Timer.periodic(Duration(milliseconds: _spawnIntervalMs), (Timer timer) {
      if (!mounted || _gameEnded) return;
      _spawnCount++;
      _spawnObjects();
    });
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || _gameEnded) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _remainingTime--;
      });
      
      if (_remainingTime <= 0) {
        timer.cancel();
        _endGameOnTimeout();
      }
    });
  }

  void _endGameOnTimeout() {
    if (_gameEnded) return;
    _gameEnded = true;
    
    _spawnTimer?.cancel();
    _gameLoopTimer?.cancel();
    _timeoutTimer?.cancel();
    _saveScores();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Time\'s Up!', style: TextStyle(color: Colors.orangeAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Time ran out!',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            Text('Final Score: $_score',
                style: const TextStyle(color: Colors.yellow, fontSize: 18)),
            Text('High Score: $_highScore',
                style: TextStyle(
                    color: _score >= _highScore ? Colors.green : Colors.orange,
                    fontSize: 16)),
            if (_score >= _highScore)
              const Text('New High Score!',
                  style: TextStyle(color: Colors.green, fontSize: 14)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _gameEnded = false;
      _targetWord = _wordBank[_rnd.nextInt(_wordBank.length)];
      _progressIndex = 0;
      _letters.clear();
      _bombs.clear();
      _bullets.clear();
      _score = 0;
      _remainingTime = _timeoutSeconds;
    });
    _startSpawnTimer();
    _startGameLoop();
    _startTimeoutTimer();
  }

  void _spawnObjects() {
    if (_rnd.nextInt(_bombSpawnChance) == 0) {
      final double x = 0.05 + _rnd.nextDouble() * 0.9;
      _bombs.add(_Bomb(x: x, y: 0.0, speed: _letterFallSpeedNorm * 1.1));
    } else {
      final bool shouldSpawnCorrect =
          (_spawnCount % 3 == 0) && (_progressIndex < _targetWord.length);
      String char;
      if (shouldSpawnCorrect) {
        char = _targetWord[_progressIndex];
      } else {
        char = String.fromCharCode(65 + _rnd.nextInt(26));
      }
      final double x = 0.05 + _rnd.nextDouble() * 0.9;
      _letters.add(_FallingLetter(
        char: char,
        x: x,
        y: 0.0,
        speed: _letterFallSpeedNorm,
        color: Color.fromARGB(
          255,
          100 + _rnd.nextInt(156),
          100 + _rnd.nextInt(156),
          100 + _rnd.nextInt(156),
        ),
      ));
    }
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: _loopMs), (Timer timer) {
      _update();
    });
  }

  void _update() {
    if (!mounted || _gameEnded) return;

    // Update stars
    for (var s in _stars) {
      s.y += s.speed * (_loopMs);
      if (s.y > 1.0) {
        s.y = 0.0;
        s.x = _rnd.nextDouble();
      }
    }

    // Update letters
    for (var l in _letters) {
      l.y += l.speed * (_loopMs / 16);
    }

    // Update bombs
    for (var b in _bombs) {
      b.y += b.speed * (_loopMs / 16);
    }

    // Update bullets
    for (var b in _bullets) {
      b.y -= _bulletSpeedNorm * (_loopMs / 16);
    }

    // Remove off-screen
    _letters.removeWhere((_FallingLetter l) => l.y > 1.05);
    _bombs.removeWhere((_Bomb b) => b.y > 1.05);
    _bullets.removeWhere((_Bullet b) => b.y < -0.05);

    // Check bullet-letter collisions
    final List<_FallingLetter> lettersToRemove = [];
    final List<_Bullet> bulletsToRemove = [];

    for (var b in List<_Bullet>.from(_bullets)) {
      for (var l in List<_FallingLetter>.from(_letters)) {
        final double dx = (b.x - l.x).abs();
        final double dy = (b.y - l.y).abs();
        const double horizThreshold = 0.06;
        const double vertThreshold = 0.06;
        if (dx < horizThreshold && dy < vertThreshold) {
          bulletsToRemove.add(b);
          lettersToRemove.add(l);
          if (_progressIndex < _targetWord.length &&
              l.char == _targetWord[_progressIndex]) {
            _progressIndex++;
            if (_progressIndex >= _targetWord.length) {
              _score++;
              _saveScores();
              _onWordCompleted();
            }
          }
          break;
        }
      }
    }

    // Check bullet-bomb collisions
    for (var b in List<_Bullet>.from(_bullets)) {
      for (var bomb in List<_Bomb>.from(_bombs)) {
        final double dx = (b.x - bomb.x).abs();
        final double dy = (b.y - bomb.y).abs();
        const double bombHitThreshold = 0.06;
        if (dx < bombHitThreshold && dy < bombHitThreshold) {
          bulletsToRemove.add(b);
          _endGameOnBombHit();
          break;
        }
      }
    }

    _letters.removeWhere((_FallingLetter l) => lettersToRemove.contains(l));
    _bullets.removeWhere((_Bullet b) => bulletsToRemove.contains(b));

    setState(() {});
  }

  void _onWordCompleted() {
    if (_gameEnded) return;
    
    _spawnTimer?.cancel();
    _gameLoopTimer?.cancel();
    _timeoutTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Word Completed!',
            style: TextStyle(color: Colors.greenAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_targetWord,
                style: const TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 10),
            Text('Score: $_score',
                style: const TextStyle(color: Colors.yellow, fontSize: 18)),
            Text('High Score: $_highScore',
                style: const TextStyle(color: Colors.orange, fontSize: 16)),
            Text('Time remaining: ${_remainingTime}s',
                style: const TextStyle(color: Colors.cyan, fontSize: 14)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _targetWord = _wordBank[_rnd.nextInt(_wordBank.length)];
              _progressIndex = 0;
              _letters.clear();
              _bombs.clear();
              _bullets.clear();
              _startSpawnTimer();
              _startGameLoop();
              _startTimeoutTimer();
            },
            child: const Text('Next Word'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  void _endGameOnBombHit() {
    if (_gameEnded) return;
    _gameEnded = true;
    
    _spawnTimer?.cancel();
    _gameLoopTimer?.cancel();
    _timeoutTimer?.cancel();
    _saveScores();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.black87,
        title:
            const Text('Game Over!', style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You hit a bomb!',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            Text('Final Score: $_score',
                style: const TextStyle(color: Colors.yellow, fontSize: 18)),
            Text('High Score: $_highScore',
                style: TextStyle(
                    color: _score >= _highScore ? Colors.green : Colors.orange,
                    fontSize: 16)),
            if (_score >= _highScore)
              const Text('New High Score!',
                  style: TextStyle(color: Colors.green, fontSize: 14)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Restart'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  void _moveGunTo(double dxNorm) {
    setState(() {
      _gunX = dxNorm.clamp(0.0, 1.0);
    });
  }

  void _fireBullet() {
    final double bulletX = _gunX;
    final double bulletY = 1.0 - (_gunHeightPx / screenH) - 0.02;
    _bullets.add(_Bullet(x: bulletX, y: bulletY));
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _moveGunTo((_gunX - 0.04).clamp(0.0, 1.0));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _moveGunTo((_gunX + 0.04).clamp(0.0, 1.0));
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _fireBullet();
      }
    }
  }

  Color _getTimerColor() {
    if (_remainingTime > 20) return Colors.white70;
    if (_remainingTime > 10) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameLoopTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenW = MediaQuery.of(context).size.width;
    screenH = MediaQuery.of(context).size.height;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _spawnTimer?.cancel();
              _gameLoopTimer?.cancel();
              _timeoutTimer?.cancel();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          title: const Text('Word War', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                _spawnTimer?.cancel();
                _gameLoopTimer?.cancel();
                _timeoutTimer?.cancel();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              final double newX = (_gunX * screenW + details.delta.dx) / screenW;
              _moveGunTo(newX);
            },
            onTapDown: (TapDownDetails details) {
              _fireBullet();
            },
            child: Stack(
              children: <Widget>[
                // Stars background
                ..._stars.map<Widget>((_Star s) {
                  return Positioned(
                    left: s.x * screenW,
                    top: s.y * screenH,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(color: Colors.white),
                    ),
                  );
                }),

                // Target word and progress
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: 'Target: ',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                        TextSpan(
                            text: _targetWord,
                            style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  top: 56,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _buildProgressString(),
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          letterSpacing: 2),
                    ),
                  ),
                ),

                // Scores and Timer
                Positioned(
                  top: 10,
                  left: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Score: $_score',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 18),
                      ),
                      Text(
                        'High Score: $_highScore',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTimerColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getTimerColor()),
                        ),
                        child: Text(
                          'Time: ${_remainingTime}s',
                          style: TextStyle(
                            color: _getTimerColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Player name display
                Positioned(
                  top: 100,
                  left: 12,
                  child: FutureBuilder<String>(
                    future: _getPlayerName(),
                    builder: (context, snapshot) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Player: ${snapshot.data ?? "Player"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Falling letters
                ..._letters.map<Widget>((_FallingLetter letter) {
                  const double fontSize = 30;
                  return Positioned(
                    left: letter.x * screenW,
                    top: letter.y * screenH,
                    child: Text(
                      letter.char,
                      style: const TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  );
                }),

                // Bombs
                ..._bombs.map<Widget>((_Bomb bomb) {
                  const double bombSize = 30.0;
                  Color bombColor;
                  switch (widget.difficulty) {
                    case Difficulty.easy:
                      bombColor = Colors.redAccent;
                      break;
                    case Difficulty.medium:
                      bombColor = Colors.orangeAccent;
                      break;
                    case Difficulty.hard:
                      bombColor = Colors.purpleAccent;
                      break;
                  }
                  return Positioned(
                    left: bomb.x * screenW,
                    top: bomb.y * screenH,
                    child: Icon(
                      Icons.brightness_7,
                      color: bombColor,
                      size: bombSize,
                    ),
                  );
                }),

                // Bullets
                ..._bullets.map<Widget>((_Bullet bullet) {
                  const double bulletSize = 8.0;
                  return Positioned(
                    left: bullet.x * screenW - bulletSize / 2,
                    top: bullet.y * screenH,
                    child: Container(
                      width: bulletSize,
                      height: bulletSize,
                      decoration: const BoxDecoration(
                        color: Colors.cyanAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),

                // Gun
                Positioned(
                  bottom: 20,
                  left: (_gunX * screenW) - (_gunWidthNorm * screenW / 2),
                  child: Container(
                    width: _gunWidthNorm * screenW,
                    height: _gunHeightPx,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Colors.blue,
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Center(
                        child: Text(
                      'GUN',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildProgressString() {
    String progress = '';
    for (int i = 0; i < _targetWord.length; i++) {
      if (i < _progressIndex) {
        progress += _targetWord[i];
      } else {
        progress += '_';
      }
      progress += ' ';
    }
    return progress.trim();
  }
}

// Supporting classes for game objects
class _Bomb {
  double x;
  double y;
  double speed;

  _Bomb({required this.x, required this.y, required this.speed});
}

class _Bullet {
  double x;
  double y;

  _Bullet({required this.x, required this.y});
}

class _Star {
  double x;
  double y;
  double speed;
  double size;

  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

// -------------
// 4. Profile Screen with saving functionality
// -------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _currentName = '';
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentName = prefs.getString('currentPlayerName') ?? 'Player';
        _nameController.text = _currentName;
        _highScore = prefs.getInt('highScore') ?? 0;
      });
    }
  }

  Future<void> _saveName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('username', _nameController.text.trim());
    await prefs.setString('currentPlayerName', _nameController.text.trim());
    
    if (mounted) {
      setState(() {
        _currentName = _nameController.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Current player info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person, size: 50, color: Colors.blue),
                  const SizedBox(height: 10),
                  Text(
                    'Current Player: $_currentName',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'High Score: $_highScore',
                    style: const TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Name input
            const Text(
              'Change Player Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              maxLength: 15,
            ),
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _saveName,
              icon: const Icon(Icons.save),
              label: const Text('Save Name'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            if (_currentName.isNotEmpty)
              Text(
                'Hello, $_currentName! Keep playing to beat your high score of $_highScore!',
                style: const TextStyle(fontSize: 16, color: Colors.cyan),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// -------------
// 5. Leaderboard Screen
// -------------

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _highScore = 0;
  String _playerName = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _highScore = prefs.getInt('highScore') ?? 0;
        _playerName = prefs.getString('currentPlayerName') ?? 'Player';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.shade100,
              Colors.orange.shade200,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              
              const Text(
                'LEADERBOARD',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 30),
              
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'CHAMPION',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _playerName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'High Score: $_highScore',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              if (_highScore == 0) ...[
                const Text(
                  'Play the game to set your first high score!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/difficulty');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Playing'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// -------------
// 6. Settings Screen
// -------------

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundOn = true;

  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
  }

  Future<void> _loadSoundSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _soundOn = prefs.getBool('soundOn') ?? true;
      });
    }
  }

  Future<void> _toggleSound(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _soundOn = value;
      });
    }
    await prefs.setBool('soundOn', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: _soundOn,
            onChanged: _toggleSound,
            secondary: Icon(_soundOn ? Icons.volume_up : Icons.volume_off),
          ),
        ],
      ),
    );
  }
}

// -------------
// 7. About Screen
// -------------

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Word War\n',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Developed in Flutter.\n\n'
              'How to Play:\n'
              '• Shoot falling letters to form target words\n'
              '• Complete words in the correct sequence\n'
              '• Avoid hitting bombs!\n'
              '• Each completed word increases your score\n'
              '• Beat the timer for each difficulty level\n\n'
              'Controls:\n'
              '• Drag horizontally to move the gun\n'
              '• Tap to shoot\n'
              '• Use arrow keys or A/D keys on desktop\n'
              '• Press spacebar to shoot on desktop\n\n'
              'Difficulty Levels:\n'
              '• Easy: 3 minutes, fewer bombs\n'
              '• Medium: 2 minutes, more bombs\n'
              '• Hard: 1:30 minutes, many bombs\n\n'
              'Good luck and have fun!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}