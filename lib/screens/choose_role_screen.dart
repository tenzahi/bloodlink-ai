import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});
  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  final UserService _userService = UserService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  String _selectedRole = 'donor';
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentRole();
  }

  Future<void> _loadCurrentRole() async {
    final user = await _userService.getUser(_uid);
    if (user != null) {
      setState(() {
        _currentUser = user;
        _selectedRole = user.role;
      });
    }
  }

  Future<void> _confirmRole() async {
    setState(() => _isLoading = true);

    await _userService.switchRole(_uid, _selectedRole);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rôle mis à jour : ${_selectedRole == 'donor' ? 'Donneur' : 'Receveur'}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Choisir mon rôle',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icône principale
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bloodtype,
                    size: 40, color: Colors.red.shade600),
              ),

              const SizedBox(height: 16),

              const Text(
                'Quel est votre rôle ?',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous pouvez changer de rôle à tout moment depuis votre profil.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),

              const SizedBox(height: 40),

              // Carte DONNEUR
              _RoleCard(
                selected: _selectedRole == 'donor',
                role: 'donor',
                icon: Icons.favorite,
                title: 'Donneur',
                subtitle: 'Je souhaite donner mon sang\net aider des personnes dans le besoin.',
                color: Colors.red,
                currentRole: _currentUser?.role,
                onTap: () => setState(() => _selectedRole = 'donor'),
              ),

              const SizedBox(height: 16),

              // Carte RECEVEUR
              _RoleCard(
                selected: _selectedRole == 'receiver',
                role: 'receiver',
                icon: Icons.local_hospital,
                title: 'Receveur',
                subtitle: 'Je cherche un donneur compatible\navec mon groupe sanguin.',
                color: Colors.blue,
                currentRole: _currentUser?.role,
                onTap: () => setState(() => _selectedRole = 'receiver'),
              ),

              const Spacer(),

              // Bouton confirmer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Confirmer mon rôle',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widget carte rôle ───────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final bool selected;
  final String role;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? currentRole;
  final VoidCallback onTap;

  const _RoleCard({
    required this.selected,
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.currentRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentRole = currentRole == role;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Icône
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? color : Colors.grey.shade400,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selected ? color : Colors.black87,
                        ),
                      ),
                      if (isCurrentRole) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'actuel',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : Colors.grey.shade300,
                  width: 2,
                ),
                color: selected ? color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}