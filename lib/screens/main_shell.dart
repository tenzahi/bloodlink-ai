import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'Scanner_screen.dart';

Map<String, Map<String, String>> appTexts = {
  'fr': {
    'accueil': 'Accueil', 'recherche': 'Recherche', 'scanner': 'Scanner',
    'profil': 'Mon profil', 'parametres': 'Paramètres',
    'changer_role': 'Changer de rôle', 'deconnexion': 'Déconnexion',
    'deconnecter': 'Se déconnecter ?',
    'deconnecter_msg': 'Voulez-vous vraiment vous déconnecter ?',
    'annuler': 'Annuler', 'confirmer': 'Confirmer',
  },
  'en': {
    'accueil': 'Home', 'recherche': 'Search', 'scanner': 'Scanner',
    'profil': 'My profile', 'parametres': 'Settings',
    'changer_role': 'Switch role', 'deconnexion': 'Logout',
    'deconnecter': 'Log out ?',
    'deconnecter_msg': 'Are you sure you want to log out?',
    'annuler': 'Cancel', 'confirmer': 'Confirm',
  },
  'ar': {
    'accueil': 'الرئيسية', 'recherche': 'بحث', 'scanner': 'مسح',
    'profil': 'ملفي', 'parametres': 'الإعدادات',
    'changer_role': 'تغيير الدور', 'deconnexion': 'تسجيل الخروج',
    'deconnecter': 'تسجيل الخروج ؟',
    'deconnecter_msg': 'هل تريد تسجيل الخروج؟',
    'annuler': 'إلغاء', 'confirmer': 'تأكيد',
  },
};

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await _userService.getUser(uid);
    if (mounted) setState(() => _user = user);
  }

  final List<Widget> _pages =  [
    HomeScreen(),
    SearchScreen(),
    ScannerScreen(),
  ];

  String get _lang => langNotifier.value;
  String t(String key) => appTexts[_lang]?[key] ?? key;

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t('deconnecter'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(t('deconnecter_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('annuler')),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(t('confirmer')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = (_user?.name.isNotEmpty == true)
        ? _user!.name[0].toUpperCase()
        : '?';

    return ValueListenableBuilder<String>(
      valueListenable: langNotifier,
      builder: (_, lang, __) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F9FA),

        // ── DRAWER ──────────────────────────────────────────────
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade800, Colors.red.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text(_user?.name ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(_user?.email ?? '',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.person_outline,
                label: t('profil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: t('parametres'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              _DrawerItem(
                icon: Icons.swap_horiz_rounded,
                label: t('changer_role'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/choose-role');
                },
              ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(t('deconnexion'),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── APPBAR (même style que HomeScreen) ───────────────────
        appBar: AppBar(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Row(
            children: [
              Icon(Icons.water_drop, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('BloodLink AI',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),

        // ── BODY ────────────────────────────────────────────────
        body: IndexedStack(index: _currentIndex, children: _pages),

        // ── BOTTOM NAV ──────────────────────────────────────────
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.red.shade700,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home_rounded),
                label: t('accueil'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search_outlined),
                activeIcon: const Icon(Icons.search),
                label: t('recherche'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.document_scanner_outlined),
                activeIcon: const Icon(Icons.document_scanner),
                label: t('scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600, size: 22),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}