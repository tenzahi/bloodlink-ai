import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

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
      setState(() { _user = newUser; _loading = false; });
    } else {
      setState(() { _user = user; _loading = false; });
    }
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
      await _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Merci pour votre don ! Repos de 3 mois.'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // Calcul jours restants avant prochain don
  int _daysRemaining() {
    if (_user?.lastDonationDate == null) return 0;
    final next = _user!.lastDonationDate!.add(const Duration(days: 90));
    final remaining = next.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  String _nextDonationDate() {
    if (_user?.lastDonationDate == null) return '—';
    final next = _user!.lastDonationDate!.add(const Duration(days: 90));
    return '${next.day.toString().padLeft(2, '0')}/${next.month.toString().padLeft(2, '0')}/${next.year}';
  }

  double _availabilityProgress() {
    if (_user?.lastDonationDate == null) return 1.0;
    final daysSince =
        DateTime.now().difference(_user!.lastDonationDate!).inDays;
    return (daysSince / 90).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.red)));
    }

    final isDonor   = _user!.role == 'donor';
    final available = _user!.isAvailable;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade800, Colors.red.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour 👋',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _user!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _user!.name.isNotEmpty
                              ? _user!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    children: [
                      _HeaderBadge(
                        icon: Icons.bloodtype,
                        label: _user!.bloodType,
                      ),
                      const SizedBox(width: 8),
                      _HeaderBadge(
                        icon: isDonor ? Icons.favorite : Icons.local_hospital,
                        label: isDonor ? 'Donneur' : 'Receveur',
                      ),
                      const SizedBox(width: 8),
                      _HeaderBadge(
                        icon: available ? Icons.check_circle : Icons.timer,
                        label: available ? 'Disponible' : 'Indisponible',
                        color: available
                            ? Colors.green.shade300
                            : Colors.orange.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Carte statut donneur ──────────────────────────────
                if (isDonor) ...[
                  _SectionTitle(title: 'Mon statut de donneur'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              available
                                  ? Icons.check_circle_rounded
                                  : Icons.timer_rounded,
                              color:
                              available ? Colors.green : Colors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              available
                                  ? 'Vous pouvez donner votre sang'
                                  : 'Période de repos en cours',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: available
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),

                        // Barre de progression
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
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                'Prochain don possible : ${_nextDonationDate()}',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],

                        // Bouton J'ai donné
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

                // ── Actions rapides ──────────────────────────────────
                _SectionTitle(title: 'Actions rapides'),
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
                      onTap: () {},
                    ),
                    _QuickCard(
                      icon: Icons.document_scanner_rounded,
                      label: 'Scanner document',
                      subtitle: 'OCR + Traduction',
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    _QuickCard(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Changer de rôle',
                      subtitle: isDonor ? 'Devenir receveur' : 'Devenir donneur',
                      color: Colors.purple,
                      onTap: () =>
                          Navigator.pushNamed(context, '/choose-role'),
                    ),
                    _QuickCard(
                      icon: Icons.person_rounded,
                      label: 'Mon profil',
                      subtitle: 'Voir mes infos',
                      color: Colors.blue,
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Info card ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade50,
                        Colors.pink.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.red.shade400, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Le saviez-vous ?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Un don de sang peut sauver jusqu\'à 3 vies. Le délai entre deux dons est de 90 jours.',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets locaux ────────────────────────────────────────────────────────────

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _HeaderBadge({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    required this.icon, required this.label,
    required this.subtitle, required this.color, required this.onTap,
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
              blurRadius: 10, offset: const Offset(0, 3),
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