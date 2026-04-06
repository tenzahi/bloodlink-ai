import 'package:flutter/material.dart';
import '../theme/bloodlink_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                _LogoBadge(scheme: scheme),
                const SizedBox(height: 36),
                Text(
                  'BloodLink AI',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                        letterSpacing: -0.5,
                      ) ??
                      TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect donors and receivers.\nDonate blood, save lives.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login_rounded, size: 22),
                  label: const Text('Login'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
                  label: const Text('Register'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: BloodlinkTheme.cardShadow(context),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 88,
            color: scheme.primary.withValues(alpha: 0.15),
          ),
          Icon(
            Icons.bloodtype_rounded,
            size: 64,
            color: scheme.primary,
          ),
        ],
      ),
    );
  }
}
