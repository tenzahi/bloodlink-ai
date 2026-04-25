import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode      = false;
  bool _notifications = true;
  String _lang        = 'fr';

  final Map<String, String> _langLabels = {
    'fr': '🇫🇷  Français',
    'en': '🇬🇧  English',
    'ar': '🇩🇿  العربية',
  };

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
    _lang     = langNotifier.value;
  }

  Future<void> _toggleDark(bool val) async {
    setState(() => _darkMode = val);
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', val);
  }

  Future<void> _setLang(String lang) async {
    setState(() => _lang = lang);
    langNotifier.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    Navigator.pop(context);
  }

  Future<void> _toggleNotif(bool val) async {
    setState(() => _notifications = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Apparence ────────────────────────────────────────────
          _SectionHeader(title: 'Apparence'),

          _SettingsCard(children: [
            _ToggleTile(
              icon: Icons.dark_mode_rounded,
              iconColor: Colors.indigo,
              title: 'Mode sombre',
              subtitle: 'Thème sombre pour les yeux',
              value: _darkMode,
              onChanged: _toggleDark,
            ),
          ]),

          const SizedBox(height: 16),

          // ── Langue ───────────────────────────────────────────────
          _SectionHeader(title: 'Langue'),

          _SettingsCard(children: [
            ListTile(
              leading: _IconBox(
                  icon: Icons.language_rounded, color: Colors.teal),
              title: const Text('Langue de l\'app',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(_langLabels[_lang] ?? 'Français'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: _showLangSheet,
            ),
          ]),

          const SizedBox(height: 16),

          // ── Notifications ─────────────────────────────────────────
          _SectionHeader(title: 'Notifications'),

          _SettingsCard(children: [
            _ToggleTile(
              icon: Icons.notifications_rounded,
              iconColor: Colors.orange,
              title: 'Notifications',
              subtitle: 'Rappels de disponibilité',
              value: _notifications,
              onChanged: _toggleNotif,
            ),
          ]),

          const SizedBox(height: 16),

          // ── À propos ──────────────────────────────────────────────
          _SectionHeader(title: 'À propos'),

          _SettingsCard(children: [
            ListTile(
              leading: _IconBox(
                  icon: Icons.bloodtype_rounded, color: Colors.red),
              title: const Text('BloodLink AI',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Version 1.0.0'),
            ),
            Divider(height: 1, indent: 56, color: Colors.grey.shade200),
            ListTile(
              leading: _IconBox(
                  icon: Icons.shield_outlined, color: Colors.green),
              title: const Text('Politique de confidentialité',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing:
              const Icon(Icons.chevron_right, size: 20),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showLangSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Choisir une langue',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._langLabels.entries.map((e) => ListTile(
              title: Text(e.value,
                  style: const TextStyle(fontSize: 15)),
              trailing: _lang == e.key
                  ? Icon(Icons.check_circle_rounded,
                  color: Colors.red.shade600)
                  : null,
              onTap: () => _setLang(e.key),
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  const _ToggleTile({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: _IconBox(icon: icon, color: iconColor),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      value: value,
      activeColor: Colors.red.shade600,
      onChanged: onChanged,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}