import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _phoneController    = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedRole      = 'receiver'; // ← par défaut receiver
  bool _isLoading       = false;
  bool _obscurePassword = true;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (userCredential != null) {
        final user = UserModel(
          id:               userCredential.uid,
          name:             _nameController.text.trim(),
          email:            _emailController.text.trim(),
          phone:            _phoneController.text.trim(),
          bloodType:        _selectedBloodType,
          role:             _selectedRole,                    // ✅ corrigé
          isAvailable:      _selectedRole == 'donor',        // ✅ corrigé
          lastDonationDate: null,
        );

        await _userService.saveUser(user);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/choose-role');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Retour ──────────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: Colors.black87),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Titre ───────────────────────────────────────────
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rejoignez BloodLink AI et sauvez des vies.',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 32),

                // ── Nom complet ─────────────────────────────────────
                _buildLabel('Nom complet'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Votre nom complet',
                  icon: Icons.person_outline,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Champ requis' : null,
                ),

                const SizedBox(height: 16),

                // ── Email ───────────────────────────────────────────
                _buildLabel('Email'),
                _buildTextField(
                  controller: _emailController,
                  hint: 'exemple@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Champ requis';
                    if (!val.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Numéro WhatsApp ─────────────────────────────────
                _buildLabel('Numéro WhatsApp'),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+216 XXX XXX XXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Champ requis' : null,
                ),

                const SizedBox(height: 16),

                // ── Mot de passe ────────────────────────────────────
                _buildLabel('Mot de passe'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 caractères',
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Colors.grey.shade400, size: 20),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.red.shade400, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Champ requis';
                    if (val.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Groupe sanguin ──────────────────────────────────
                _buildLabel('Groupe sanguin'),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBloodType,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400),
                      items: _bloodTypes
                          .map((bt) => DropdownMenuItem(
                        value: bt,
                        child: Row(
                          children: [
                            Icon(Icons.bloodtype,
                                color: Colors.red.shade300,
                                size: 18),
                            const SizedBox(width: 10),
                            Text(bt,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedBloodType = val!),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Bouton S'inscrire ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
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
                      "S'inscrire",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Lien connexion ──────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Déjà un compte ? ',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      validator: validator,
    );
  }
}