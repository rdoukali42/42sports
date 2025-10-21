import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'utils/theme.dart';
import 'utils/web_utils.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const SportsApp());
}

class SportsApp extends StatelessWidget {
  const SportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '42Sports',
      theme: AppTheme.theme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  final _authService = AuthService();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _pendingUri;
  static const platform = MethodChannel('com.example.sports42/deeplink');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    _setupMethodChannel();
    _handleInitialAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _setupMethodChannel() {
    if (!kIsWeb) {
      platform.setMethodCallHandler((call) async {
        if (call.method == 'handleDeepLink') {
          final url = call.arguments as String;
          print('Method channel received deep link: $url');
          final uri = Uri.parse(url);
          await _handleDeepLink(uri);
        }
      });
      print('Method channel setup complete');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle changed to: $state');
    if (state == AppLifecycleState.resumed) {
      // Check for deep link when app resumes from background
      if (_pendingUri != null) {
        print('Processing pending URI: $_pendingUri');
        _handleDeepLink(_pendingUri!);
        _pendingUri = null;
      }
    }
  }

  void _initDeepLinks() {
    if (!kIsWeb) {
      _appLinks = AppLinks();
      
      // Handle links when app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          print('Stream received URI: $uri');
          _pendingUri = uri;
          // If app is currently active, process immediately
          if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
            _handleDeepLink(uri);
            _pendingUri = null;
          }
        },
        onError: (err) {
          print('Error in link stream: $err');
        },
      );
      
      print('Deep link listener initialized');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    print('Deep link received: $uri');
    final code = uri.queryParameters['code'];
    print('Extracted code: $code');
    
    if (code != null) {
      print('Calling handleCallback...');
      final success = await _authService.handleCallback(code);
      print('Callback result: $success');
      if (success) {
        print('Widget mounted: $mounted');
        print('Navigating to HomeScreen using global navigator...');
        // Use global navigator key instead of context
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        print('Callback failed');
      }
    } else {
      print('No code found in URI');
    }
  }

  Future<void> _handleInitialAuth() async {
    // Check if app was opened from a deep link
    if (!kIsWeb) {
      try {
        print('Checking for initial link...');
        final initialUri = await _appLinks.getInitialLink();
        print('Initial link: $initialUri');
        if (initialUri != null) {
          await _handleDeepLink(initialUri);
          return;
        }
      } catch (e) {
        print('Failed to get initial link: $e');
      }
    }
    
    // Check if we're returning from OAuth (web only)
    if (kIsWeb) {
      final uri = Uri.parse(WebUtils.getCurrentUrl());
      final code = uri.queryParameters['code'];
      
      if (code != null) {
        // Handle OAuth callback
        final success = await _authService.handleCallback(code);
        if (success) {
          // Clean URL and navigate to home
          WebUtils.replaceUrl('/');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          return;
        }
      }
    }
    
    // Normal auth check
    await _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    final isAuthenticated = await _authService.isAuthenticated();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              isAuthenticated ? const HomeScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
