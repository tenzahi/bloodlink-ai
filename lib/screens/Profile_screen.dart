import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUser(_uid);
    setState(() => _user = user);
  }

  Future<void> _switchRole() async {
    final newRole = _user!.role == 'donor' ? 'receiver' : 'donor';
    await _userService.switchRole(_uid, newRole);
    await _loadUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Rôle changé en : ${newRole == 'donor' ? 'Donneur' : 'Receveur'}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête profil
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      _user!.name.isNotEmpty
                          ? _user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_user!.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_user!.email,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Badge(
                        label: _user!.bloodType,
                        color: Colors.red,
                        icon: Icons.bloodtype,
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        label: _user!.role == 'donor' ? 'Donneur' : 'Receveur',
                        color: Colors.blue,
                        icon: Icons.person,
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        label: _user!.isAvailable ? 'Disponible' : 'Indisponible',
                        color: _user!.isAvailable ? Colors.green : Colors.orange,
                        icon: _user!.isAvailable
                            ? Icons.check_circle
                            : Icons.timer,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Infos
            _Section(title: 'Informations', children: [
              _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Nom',
                  value: _user!.name),
              _InfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _user!.email),
              _InfoTile(
                  icon: Icons.bloodtype_outlined,
                  label: 'Groupe sanguin',
                  value: _user!.bloodType),
              _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Dernier don',
                  value: _user!.lastDonationDate != null
                      ? '${_user!.lastDonationDate!.day}/${_user!.lastDonationDate!.month}/${_user!.lastDonationDate!.year}'
                      : 'Jamais donné'),
            ]),

            const SizedBox(height: 16),

            // Actions
            _Section(title: 'Actions', children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.swap_horiz, color: Colors.purple.shade600),
                ),
                title: const Text('Changer de rôle'),
                subtitle: Text(
                    'Passer en ${_user!.role == 'donor' ? 'Receveur' : 'Donneur'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _switchRole,
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout, color: Colors.red.shade600),
                ),
                title: Text('Déconnexion',
                    style: TextStyle(color: Colors.red.shade700)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _logout,
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Badge(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade500, size: 22),
      title: Text(label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      subtitle: Text(value,
          style:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}