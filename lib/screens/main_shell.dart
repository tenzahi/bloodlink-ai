import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state.dart';           // ← importe ici
import '../services/auth_service.dart';
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

  final List<Widget> _pages = [
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(t('deconnecter'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(t('deconnecter_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('annuler')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
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

    return ValueListenableBuilder<String>(
      valueListenable: langNotifier,
      builder: (_, lang, __) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.red.shade700,
          title: const Row(
            children: [
              Icon(Icons.bloodtype, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'BloodLink AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              onSelected: (v) {
                if (v == 'profile')
                  Navigator.pushNamed(context, '/profile');
                if (v == 'settings')
                  Navigator.pushNamed(context, '/settings');
                if (v == 'role')
                  Navigator.pushNamed(context, '/choose-role');
                if (v == 'logout') _showLogoutDialog();
              },
              itemBuilder: (_) => [
                _popupItem(Icons.person_outline,    t('profil'),        'profile',  Colors.blue),
                _popupItem(Icons.settings_outlined,  t('parametres'),   'settings', Colors.grey),
                _popupItem(Icons.swap_horiz,         t('changer_role'), 'role',     Colors.purple),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.logout,
                            color: Colors.red.shade600, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        t('deconnexion'),
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        body: IndexedStack(index: _currentIndex, children: _pages),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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

  PopupMenuItem<String> _popupItem(
      IconData icon, String label, String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}