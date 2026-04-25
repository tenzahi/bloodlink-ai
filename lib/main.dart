import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app_state.dart';              // ← importe ici

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/Profile_screen.dart';
import 'screens/Settings_screen.dart';
import 'screens/choose_role_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  final lang   = prefs.getString('lang') ?? 'fr';
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  langNotifier.value  = lang;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'BloodLink AI',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          home: AuthWrapper(),
          routes: {
            '/welcome':     (_) => WelcomeScreen(),
            '/login':       (_) => LoginScreen(),
            '/register':    (_) => RegisterScreen(),
            '/home':        (_) => MainShell(),
            '/profile':     (_) => ProfileScreen(),
            '/settings':    (_) => SettingsScreen(),
            '/choose-role': (_) => ChooseRoleScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: Colors.red)),
          );
        }
        if (snapshot.hasData) return MainShell();
        return WelcomeScreen();
      },
    );
  }
}