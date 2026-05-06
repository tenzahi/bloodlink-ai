import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await _userService.checkAndUpdateAvailability(_uid);
    final user = await _userService.getUser(_uid);
    if (!mounted) return;
    if (user == null) {
      final fu = FirebaseAuth.instance.currentUser!;
      final newUser = UserModel(
        id: _uid,
        name: fu.displayName ?? fu.email!.split('@')[0],
        email: fu.email!,
        phone: '',
        bloodType: 'A+',
        role: 'receiver',
        isAvailable: false,
        lastDonationDate: null,
      );
      await _userService.saveUser(newUser);
      if (!mounted) return;
      setState(() { _user = newUser; _loading = false; });
    } else {
      setState(() { _user = user; _loading = false; });
      // Sauvegarde token FCM
      await NotificationService.saveToken(_uid);
    }
  }

  Future<void> _toggleAvailability() async {
    if (_user == null || _user!.role != 'donor') return;
    await _userService.updateAvailability(_uid, !_user!.isAvailable);
    if (!mounted) return;
    await _loadUser();
  }

  Future<void> _markDonated() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer le don',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Vous confirmez avoir donné votre sang ?\nVous serez indisponible pendant 3 mois.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.markAsDonated(_uid);

      // ── Notifie les receveurs compatibles ──────────────────
      await NotificationService.notifyReceivers(
        bloodType: _user!.bloodType,
        donorName: _user!.name,
      );

      if (!mounted) return;
      await _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.favorite, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Merci pour votre don ! Repos de 3 mois.'),
            ]),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  int _daysRemaining() {
    if (_user?.lastDonationDate == null) return 0;
    final next = _user!.lastDonationDate!.add(const Duration(days: 90));
    final r = next.difference(DateTime.now()).inDays;
    return r < 0 ? 0 : r;
  }

  String _nextDonationDate() {
    if (_user?.lastDonationDate == null) return '—';
    final next = _user!.lastDonationDate!.add(const Duration(days: 90));
    return '${next.day.toString().padLeft(2, '0')}/'
        '${next.month.toString().padLeft(2, '0')}/${next.year}';
  }

  double _availabilityProgress() {
    if (_user?.lastDonationDate == null) return 1.0;
    final d = DateTime.now().difference(_user!.lastDonationDate!).inDays;
    return (d / 90).clamp(0.0, 1.0);
  }

  List<String> _compatibleGroups() {
    const map = {
      'A+':  ['A+', 'A-', 'O+', 'O-'],
      'A-':  ['A-', 'O-'],
      'B+':  ['B+', 'B-', 'O+', 'O-'],
      'B-':  ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+':  ['O+', 'O-'],
      'O-':  ['O-'],
    };
    return map[_user?.bloodType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.red));
    }

    final isDonor   = _user!.role == 'donor';
    final available = _user!.isAvailable;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: Colors.red,
      onRefresh: _loadUser,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade800, Colors.red.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour 👋',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_user!.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _Badge(
                        icon: Icons.bloodtype,
                        label: _user!.bloodType),
                    const SizedBox(width: 8),
                    _Badge(
                      icon: isDonor
                          ? Icons.favorite
                          : Icons.local_hospital,
                      label: isDonor ? 'Donneur' : 'Receveur',
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      icon: available
                          ? Icons.check_circle
                          : Icons.timer,
                      label: available ? 'Disponible' : 'Indisponible',
                      color: available
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Toggle disponibilité (donneur) ─────────────────
            if (isDonor) ...[
              const _Title('Ma disponibilité'),
              const SizedBox(height: 10),
              _Card(
                isDark: isDark,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (available ? Colors.green : Colors.grey)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      available
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_rounded,
                      color: available ? Colors.green : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Je suis disponible',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87)),
                        Text(
                          available
                              ? 'Visible pour les receveurs'
                              : 'Masqué des recherches',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: available,
                    activeColor: Colors.red.shade600,
                    onChanged: (_) => _toggleAvailability(),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            // ── Statut donneur ─────────────────────────────────
            if (isDonor) ...[
              const _Title('Mon statut de donneur'),
              const SizedBox(height: 10),
              _Card(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(
                        available
                            ? Icons.check_circle_rounded
                            : Icons.timer_rounded,
                        color:
                        available ? Colors.green : Colors.orange,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          available
                              ? 'Vous pouvez donner votre sang'
                              : 'Période de repos en cours',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: available
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700),
                        ),
                      ),
                    ]),

                    if (!available) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Récupération',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500)),
                          Text('${_daysRemaining()} jours restants',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _availabilityProgress(),
                          minHeight: 8,
                          backgroundColor: Colors.orange.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange.shade400),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Icon(Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          'Prochain don : ${_nextDonationDate()}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600),
                        ),
                      ]),
                    ],

                    if (available) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _markDonated,
                          icon: const Icon(Icons.favorite, size: 18),
                          label: const Text("J'ai donné mon sang"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Groupes compatibles ────────────────────────────
            const _Title('Groupes compatibles avec moi'),
            const SizedBox(height: 10),
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mon groupe : ${_user!.bloodType}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _compatibleGroups()
                        .map((g) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.red.shade200),
                      ),
                      child: Text(g,
                          style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Actions rapides ────────────────────────────────
            // ── Actions rapides ────────────────────────────────────────
            const _Title('Actions rapides'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _QuickCard(
                  icon: Icons.search_rounded,
                  label: 'Chercher un donneur',
                  subtitle: 'Trouver par groupe',
                  color: Colors.red,
                  onTap: () {
                    // Navigue vers l'onglet Recherche (index 1)
                    final shell = context
                        .findAncestorStateOfType<MainShellState>();
                    shell?.setIndex(1);
                  },
                ),
                _QuickCard(
                  icon: Icons.document_scanner_rounded,
                  label: 'Scanner document',
                  subtitle: 'OCR + Traduction',
                  color: Colors.orange,
                  onTap: () {
                    // Navigue vers l'onglet Scanner (index 2)
                    final shell = context
                        .findAncestorStateOfType<MainShellState>();
                    shell?.setIndex(2);
                  },
                ),
                _QuickCard(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Changer de rôle',
                  subtitle: isDonor ? 'Devenir receveur' : 'Devenir donneur',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/choose-role'),
                ),
                _QuickCard(
                  icon: Icons.person_rounded,
                  label: 'Mon profil',
                  subtitle: 'Voir mes infos',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Le saviez-vous ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(children: [
                Icon(Icons.info_outline,
                    color: Colors.red.shade400, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Le saviez-vous ?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                              fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        'Un don de sang peut sauver jusqu\'à 3 vies. '
                            'Le délai entre deux dons est de 90 jours.',
                        style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Widgets locaux ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  const _Title(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style:
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _Badge({required this.icon, required this.label, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color ?? Colors.white, size: 13),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}