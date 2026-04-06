import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../theme/bloodlink_theme.dart';

class ChooseRoleScreen extends StatefulWidget {
  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  final UserService userService = UserService();
  final AuthService auth = AuthService();

  String? _selectedRole;

  Future<void> selectRole(BuildContext context, String role) async {
    setState(() => _selectedRole = role);

    var user = auth.getCurrentUser();

    if (user != null) {
      await userService.updateRole(user.uid, role);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose role'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'How will you use BloodLink?',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick the option that fits you. You can update this later if your project supports it.',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              _RoleOptionCard(
                title: 'Donor',
                subtitle: 'Offer blood donations and help patients in need.',
                emoji: '❤️',
                icon: Icons.volunteer_activism_rounded,
                selected: _selectedRole == 'donor',
                onTap: () => selectRole(context, 'donor'),
              ),
              const SizedBox(height: 20),
              _RoleOptionCard(
                title: 'Receiver',
                subtitle: 'Request blood or manage needs for care.',
                emoji: '🏥',
                icon: Icons.local_hospital_rounded,
                selected: _selectedRole == 'receiver',
                onTap: () => selectRole(context, 'receiver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: selected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BloodlinkTheme.radiusLg),
          color: Colors.white,
          border: Border.all(
            color: selected ? scheme.primary : Colors.grey.shade200,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  ...BloodlinkTheme.cardShadow(context),
                ]
              : BloodlinkTheme.cardShadow(context),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(BloodlinkTheme.radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary.withValues(alpha: 0.12)
                          : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: selected ? scheme.primary : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: selected ? scheme.primary : scheme.onSurface,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: scheme.primary,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
