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
    'accueil': 'Accueil',
    'recherche': 'Recherche',
    'scanner': 'Scanner',
    'profil': 'Mon profil',
    'parametres': 'Paramètres',
    'changer_role': 'Changer de rôle',
    'deconnexion': 'Déconnexion',
    'deconnecter': 'Se déconnecter ?',
    'deconnecter_msg': 'Voulez-vous vraiment vous déconnecter ?',
    'annuler': 'Annuler',
    'confirmer': 'Confirmer',
    'donneur': 'Donneur',
    'receveur': 'Receveur',
    'disponible': 'Disponible',
    'indisponible': 'Indisponible',
    'bonjour': 'Bonjour',
    'statut': 'Mon statut de donneur',
    'disponibilite': 'Ma disponibilité',
    'visible': 'Visible pour les receveurs',
    'masque': 'Masqué des recherches',
    'peut_donner': 'Vous pouvez donner votre sang',
    'repos': 'Période de repos en cours',
    'recuperation': 'Récupération',
    'jours_restants': 'jours restants',
    'prochain_don': 'Prochain don possible',
    'jai_donne': "J'ai donné mon sang",
    'confirmer_don': 'Confirmer le don',
    'confirmer_don_msg': 'Vous confirmez avoir donné votre sang ?\nVous serez indisponible pendant 3 mois.',
    'merci_don': 'Merci pour votre don ! Repos de 3 mois.',
    'groupes_compatibles': 'Groupes compatibles avec moi',
    'mon_groupe': 'Mon groupe',
    'actions_rapides': 'Actions rapides',
    'chercher_donneur': 'Chercher un donneur',
    'trouver_groupe': 'Trouver par groupe',
    'scanner_doc': 'Scanner document',
    'ocr': 'OCR + Traduction',
    'changer_role_subtitle': 'Devenir receveur',
    'changer_role_subtitle2': 'Devenir donneur',
    'mon_profil': 'Mon profil',
    'voir_infos': 'Voir mes infos',
    'saviez_vous': 'Le saviez-vous ?',
    'saviez_vous_msg': 'Un don de sang peut sauver jusqu\'à 3 vies. Le délai entre deux dons est de 90 jours.',
    'je_suis_disponible': 'Je suis disponible',
    'trouver_donneur': 'Trouver un donneur',
    'selectionner_groupe': 'Sélectionnez votre groupe sanguin',
    'aucun_donneur': 'Aucun donneur disponible',
    'essayer_autre': 'Essayez un autre groupe sanguin',
    'contacter_whatsapp': 'Contacter sur WhatsApp',
    'infos_contact': 'Informations de contact',
    'nom': 'Nom',
    'groupe_sanguin': 'Groupe sanguin',
    'email': 'Email',
    'contact_msg': 'Contactez ce donneur par email pour organiser le don de sang.',
    'apparence': 'Apparence',
    'mode_sombre': 'Mode sombre',
    'mode_sombre_sub': 'Thème sombre pour les yeux',
    'langue': 'Langue',
    'langue_app': 'Langue de l\'app',
    'notifications': 'Notifications',
    'notif_sub': 'Alertes donneurs disponibles',
    'notif_info': 'Vous serez notifié quand un donneur compatible avec votre groupe sanguin est disponible.',
    'a_propos': 'À propos',
    'version': 'Version 1.0.0',
    'confidentialite': 'Politique de confidentialité',
    'choisir_langue': 'Choisir une langue',
    'notifications_active': 'Notifications activées',
    'notifications_desactive': 'Notifications désactivées',
    'notifications_sub': 'Alertes et notifications',
    'apropos': 'À propos',
    'pas_whatsapp': 'Numéro WhatsApp indisponible',
    'informations': 'Informations',
    'dernier_don': 'Dernier don',
    'jamais_donne': 'Jamais donné',
    'actions': 'Actions',
    'passer': 'Passer en',
    'role_change': 'Rôle changé',
    'role_update': 'Rôle mis à jour',
    'choisir_role': 'Choisir mon rôle',
    'quel_role': 'Quel est votre rôle ?',
    'changer_role_msg': 'Vous pouvez changer de rôle à tout moment depuis votre profil.',
    'donneur_sub': 'Je souhaite donner mon sang et aider des personnes dans le besoin.',
    'receveur_sub': 'Je cherche un donneur compatible avec mon groupe sanguin.',
    'actuel': 'actuel',
    'confirmer_role': 'Confirmer mon rôle',

    'erreur_image': 'Erreur lors de la sélection de l’image',
    'aucun_texte': 'Aucun texte détecté dans ce document',
    'erreur_ocr': 'Erreur lors de la reconnaissance du texte',
    'erreur_traduction': 'Erreur lors de la traduction',
    'scanner_sub': 'Extrayez et traduisez le texte de vos documents médicaux',
    'appuyer_scanner': 'Appuyez pour scanner un document',
    'camera_galerie': 'Caméra ou Galerie',
    'nouvelle_image': 'Nouvelle image',
    'ocr_loading': 'Extraction du texte en cours...',
    'texte_extrait': 'Texte extrait',
    'traduire_en': 'Traduire en',
    'traduction': 'Traduction...',
    'traduire': 'Traduire le texte',
    'texte_traduit': 'Texte traduit',
  },

  'en': {
    'accueil': 'Home',
    'recherche': 'Search',
    'scanner': 'Scanner',
    'profil': 'My profile',
    'parametres': 'Settings',
    'changer_role': 'Switch role',
    'deconnexion': 'Logout',
    'deconnecter': 'Log out?',
    'deconnecter_msg': 'Are you sure you want to log out?',
    'annuler': 'Cancel',
    'confirmer': 'Confirm',
    'donneur': 'Donor',
    'receveur': 'Receiver',
    'disponible': 'Available',
    'indisponible': 'Unavailable',
    'bonjour': 'Hello',
    'statut': 'My donor status',
    'disponibilite': 'My availability',
    'visible': 'Visible to receivers',
    'masque': 'Hidden from searches',
    'peut_donner': 'You can donate blood',
    'repos': 'Rest period in progress',
    'recuperation': 'Recovery',
    'jours_restants': 'days remaining',
    'prochain_don': 'Next possible donation',
    'jai_donne': 'I donated blood',
    'confirmer_don': 'Confirm donation',
    'confirmer_don_msg': 'You confirm you have donated blood?\nYou will be unavailable for 3 months.',
    'merci_don': 'Thank you for your donation! Rest for 3 months.',
    'groupes_compatibles': 'Compatible blood groups',
    'mon_groupe': 'My group',
    'actions_rapides': 'Quick actions',
    'chercher_donneur': 'Find a donor',
    'trouver_groupe': 'Search by group',
    'scanner_doc': 'Scan document',
    'ocr': 'OCR + Translation',
    'changer_role_subtitle': 'Become a receiver',
    'changer_role_subtitle2': 'Become a donor',
    'mon_profil': 'My profile',
    'voir_infos': 'View my info',
    'saviez_vous': 'Did you know?',
    'saviez_vous_msg': 'A blood donation can save up to 3 lives. The interval between donations is 90 days.',
    'je_suis_disponible': 'I am available',
    'trouver_donneur': 'Find a donor',
    'selectionner_groupe': 'Select your blood group',
    'aucun_donneur': 'No donor available',
    'essayer_autre': 'Try another blood group',
    'contacter_whatsapp': 'Contact on WhatsApp',
    'infos_contact': 'Contact information',
    'nom': 'Name',
    'notifications_active': 'Notifications enabled',
    'notifications_desactive': 'Notifications disabled',
    'notifications_sub': 'Alerts and notifications',
    'apropos': 'About',
    'pas_whatsapp': 'WhatsApp number unavailable',
    'informations': 'Information',
    'dernier_don': 'Last donation',
    'jamais_donne': 'Never donated',
    'actions': 'Actions',
    'passer': 'Switch to',
    'role_change': 'Role changed',
    'role_update': 'Role updated',
    'choisir_role': 'Choose my role',
    'quel_role': 'What is your role?',
    'changer_role_msg': 'You can change your role anytime from your profile.',
    'donneur_sub': 'I want to donate blood and help people in need.',
    'receveur_sub': 'I am looking for a compatible donor.',
    'actuel': 'current',
    'confirmer_role': 'Confirm my role',

    'erreur_image': 'Error selecting image',
    'aucun_texte': 'No text detected in this document',
    'erreur_ocr': 'Text recognition error',
    'erreur_traduction': 'Translation error',
    'scanner_sub': 'Extract and translate text from medical documents',
    'appuyer_scanner': 'Tap to scan a document',
    'camera_galerie': 'Camera or Gallery',
    'nouvelle_image': 'New image',
    'ocr_loading': 'Extracting text...',
    'texte_extrait': 'Extracted text',
    'traduire_en': 'Translate to',
    'traduction': 'Translating...',
    'traduire': 'Translate text',
    'texte_traduit': 'Translated text',
    'groupe_sanguin': 'Blood group',
    'email': 'Email',
    'contact_msg': 'Contact this donor to arrange the blood donation.',
    'apparence': 'Appearance',
    'mode_sombre': 'Dark mode',
    'mode_sombre_sub': 'Dark theme for your eyes',
    'langue': 'Language',
    'langue_app': 'App language',
    'notifications': 'Notifications',
    'notif_sub': 'Available donor alerts',
    'notif_info': 'You will be notified when a donor compatible with your blood group is available.',
    'a_propos': 'About',
    'version': 'Version 1.0.0',
    'confidentialite': 'Privacy policy',
    'choisir_langue': 'Choose a language',
  },

  'ar': {
    'accueil': 'الرئيسية',
    'recherche': 'بحث',
    'scanner': 'مسح ضوئي',
    'profil': 'ملفي الشخصي',
    'parametres': 'الإعدادات',
    'changer_role': 'تغيير الدور',
    'deconnexion': 'تسجيل الخروج',
    'deconnecter': 'تسجيل الخروج ؟',
    'deconnecter_msg': 'هل تريد تسجيل الخروج فعلاً ؟',
    'annuler': 'إلغاء',
    'confirmer': 'تأكيد',
    'donneur': 'متبرع',
    'receveur': 'مستقبل',
    'disponible': 'متاح',
    'indisponible': 'غير متاح',
    'bonjour': 'مرحباً',
    'statut': 'حالتي كمتبرع',
    'disponibilite': 'مدى توفري',
    'visible': 'مرئي للمستقبلين',
    'masque': 'مخفي عن نتائج البحث',
    'peut_donner': 'يمكنك التبرع بالدم الآن',
    'repos': 'فترة الراحة جارية',
    'recuperation': 'التعافي',
    'jours_restants': 'أيام متبقية',
    'prochain_don': 'التبرع القادم الممكن',
    'jai_donne': 'لقد تبرعت بالدم',
    'confirmer_don': 'تأكيد التبرع',
    'confirmer_don_msg': 'هل تؤكد أنك تبرعت بالدم ؟\nلن تكون متاحاً لمدة 3 أشهر.',
    'merci_don': 'شكراً على تبرعك ! راحة لمدة 3 أشهر.',
    'groupes_compatibles': 'فصائل الدم المتوافقة معي',
    'mon_groupe': 'فصيلتي',
    'actions_rapides': 'إجراءات سريعة',
    'chercher_donneur': 'البحث عن متبرع',
    'trouver_groupe': 'البحث حسب الفصيلة',
    'scanner_doc': 'مسح وثيقة',
    'ocr': 'استخراج نص + ترجمة',
    'notifications_active': 'تم تفعيل الإشعارات',
    'notifications_desactive': 'تم تعطيل الإشعارات',
    'notifications_sub': 'التنبيهات والإشعارات',
    'apropos': 'حول التطبيق',
    'pas_whatsapp': 'رقم الواتساب غير متوفر',
    'informations': 'المعلومات',
    'dernier_don': 'آخر تبرع',
    'jamais_donne': 'لم يتبرع أبداً',
    'actions': 'الإجراءات',
    'passer': 'التحويل إلى',
    'role_change': 'تم تغيير الدور',
    'role_update': 'تم تحديث الدور',
    'choisir_role': 'اختيار دوري',
    'quel_role': 'ما هو دورك ؟',
    'changer_role_msg': 'يمكنك تغيير دورك في أي وقت من ملفك الشخصي.',
    'donneur_sub': 'أرغب في التبرع بالدم ومساعدة المحتاجين.',
    'receveur_sub': 'أبحث عن متبرع متوافق مع فصيلة دمي.',
    'actuel': 'الحالي',
    'confirmer_role': 'تأكيد دوري',

    'erreur_image': 'خطأ أثناء اختيار الصورة',
    'aucun_texte': 'لم يتم العثور على نص',
    'erreur_ocr': 'خطأ أثناء استخراج النص',
    'erreur_traduction': 'خطأ أثناء الترجمة',
    'scanner_sub': 'استخراج وترجمة النص من المستندات الطبية',
    'appuyer_scanner': 'اضغط لمسح مستند',
    'camera_galerie': 'الكاميرا أو المعرض',
    'nouvelle_image': 'صورة جديدة',
    'ocr_loading': 'جاري استخراج النص...',
    'texte_extrait': 'النص المستخرج',
    'traduire_en': 'الترجمة إلى',
    'traduction': 'جاري الترجمة...',
    'traduire': 'ترجمة النص',
    'texte_traduit': 'النص المترجم',
    'changer_role_subtitle': 'أصبح مستقبلاً',
    'changer_role_subtitle2': 'أصبح متبرعاً',
    'mon_profil': 'ملفي الشخصي',
    'voir_infos': 'عرض معلوماتي',
    'saviez_vous': 'هل تعلم ؟',
    'saviez_vous_msg': 'يمكن لتبرع واحد بالدم إنقاذ 3 أرواح. الفترة بين تبرعين هي 90 يوماً.',
    'je_suis_disponible': 'أنا متاح',
    'trouver_donneur': 'البحث عن متبرع',
    'selectionner_groupe': 'اختر فصيلة دمك',
    'aucun_donneur': 'لا يوجد متبرع متاح',
    'essayer_autre': 'جرب فصيلة دم أخرى',
    'contacter_whatsapp': 'التواصل عبر واتساب',
    'infos_contact': 'معلومات الاتصال',
    'nom': 'الاسم',
    'groupe_sanguin': 'فصيلة الدم',
    'email': 'البريد الإلكتروني',
    'contact_msg': 'تواصل مع هذا المتبرع لترتيب عملية التبرع بالدم.',
    'apparence': 'المظهر',
    'mode_sombre': 'الوضع الداكن',
    'mode_sombre_sub': 'سمة داكنة لراحة العينين',
    'langue': 'اللغة',
    'langue_app': 'لغة التطبيق',
    'notifications': 'الإشعارات',
    'notif_sub': 'تنبيهات توفر المتبرعين',
    'notif_info': 'ستتلقى إشعاراً عندما يكون متبرع متوافق مع فصيلة دمك متاحاً.',
    'a_propos': 'حول التطبيق',
    'version': 'الإصدار 1.0.0',
    'confidentialite': 'سياسة الخصوصية',
    'choisir_langue': 'اختر اللغة',
  },
};

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
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

  // ← Méthode pour changer d'onglet depuis HomeScreen
  void setIndex(int index) {
    setState(() => _currentIndex = index);
  }

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
    final initial = (_user?.name.isNotEmpty == true)
        ? _user!.name[0].toUpperCase()
        : '?';

    return ValueListenableBuilder<String>(
      valueListenable: langNotifier,
      builder: (_, lang, __) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF8F9FA),

        // ── DRAWER ─────────────────────────────────────────────
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(20, 50, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade800,
                      Colors.red.shade500
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                      Colors.white.withOpacity(0.25),
                      child: Text(
                        initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _user?.name ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _user?.email ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    // Badge rôle
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _user?.role == 'donor'
                            ? '❤️ Donneur'
                            : '🏥 Receveur',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _DrawerItem(
                icon: Icons.person_outline,
                label: t('profil'),
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: t('parametres'),
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              _DrawerItem(
                icon: Icons.swap_horiz_rounded,
                label: t('changer_role'),
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/choose-role');
                },
              ),

              const Spacer(),
              Divider(height: 1, color: Colors.grey.shade200),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout,
                      color: Colors.red.shade600, size: 20),
                ),
                title: Text(
                  t('deconnexion'),
                  style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── APPBAR ─────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () =>
                _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Row(
            children: [
              Icon(Icons.water_drop, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'BloodLink AI',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── BODY ───────────────────────────────────────────────
        body: IndexedStack(
            index: _currentIndex, children: _pages),

        // ── BOTTOM NAV ─────────────────────────────────────────
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
            unselectedLabelStyle:
            const TextStyle(fontSize: 11),
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

// ── Widgets ────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}