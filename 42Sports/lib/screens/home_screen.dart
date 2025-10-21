import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'events_screen.dart';
import 'create_event_screen.dart';
import 'tournaments_screen.dart';
import 'create_tournament_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _userService = UserService();
  User? _user;
  int _selectedIndex = 0;
  bool _hasCompletedQuiz = false;
  bool _showQuizBanner = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _checkQuizStatus();
  }

  Future<void> _loadUser() async {
    // First try to get user from local storage
    final localUser = await _userService.getUser();
    if (localUser != null) {
      setState(() => _user = localUser);
      print('User loaded from local storage: ${localUser.login} with ${localUser.tokens} tokens');
      return;
    }
    
    // If not in local storage, fetch from 42 API
    final user = await _authService.getCurrentUser();
    if (user != null) {
      await _userService.saveUser(user);
      setState(() => _user = user);
      print('User loaded from 42 API: ${user.login} with ${user.tokens} tokens');
    }
  }

  Future<void> _checkQuizStatus() async {
    final user = await _userService.getUser();
    if (user != null) {
      final completed = await _userService.hasCompletedQuiz(user.id);
      print('Quiz status - completed: $completed, tokens: ${user.tokens}');
      setState(() {
        _hasCompletedQuiz = completed;
        _showQuizBanner = !completed && user.tokens == 0;
      });
      print('Show quiz banner: $_showQuizBanner, hasCompleted: $_hasCompletedQuiz');
    }
  }

  Future<void> _navigateToQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
    
    print('Quiz result: $result');
    
    // Refresh user data and quiz status after quiz
    await _loadUser();
    await _checkQuizStatus();
    
    // Force rebuild to update UI
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (!_hasCompletedQuiz && index == 2) {
      // Quiz button tapped - navigate to quiz
      _navigateToQuiz();
    } else if (_hasCompletedQuiz && index == 2) {
      // Create button tapped (after quiz completed)
      setState(() => _selectedIndex = index);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  List<Widget> get _screens => [
        const EventsScreen(),
        const TournamentsScreen(),
        _hasCompletedQuiz ? const CreateEventScreen() : const QuizScreen(),
        const HistoryScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Safety check: reset to first screen if selectedIndex is out of range
    if (_selectedIndex >= _screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: Column(
        children: [
          // Quiz Banner
          if (_showQuizBanner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00BABC), const Color(0xFF00BABC).withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(Icons.quiz, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take the Quiz!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Earn 3 tokens by answering 2 questions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _navigateToQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00BABC),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          const NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Tournament',
          ),
          NavigationDestination(
            icon: Icon(_hasCompletedQuiz ? Icons.add_circle : Icons.quiz),
            label: _hasCompletedQuiz ? 'Create' : 'Quiz',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
