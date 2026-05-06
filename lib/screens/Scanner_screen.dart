import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'dart:io';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  File? _image;
  String _extractedText = '';
  String _translatedText = '';
  String _selectedLanguage = 'fr';
  bool _isProcessing = false;
  bool _isTranslating = false;
  OnDeviceTranslator? _translator;

  final Map<String, String> _languages = {
    'fr': 'Français',
    'en': 'Anglais',
    'ar': 'Arabe',
  };

  final Map<String, TranslateLanguage> _mlkitLanguages = {
    'fr': TranslateLanguage.french,
    'en': TranslateLanguage.english,
    'ar': TranslateLanguage.arabic,
  };

  @override
  void dispose() {
    _textRecognizer.close();
    _translator?.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked == null) return;

      setState(() {
        _image = File(picked.path);
        _extractedText = '';
        _translatedText = '';
        _isProcessing = true;
      });

      await _extractText(_image!);
    } catch (e) {
      if (mounted) _showError('Erreur lors de la sélection de l\'image');
    }
  }

  Future<void> _extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await _textRecognizer.processImage(inputImage);
      if (!mounted) return;
      setState(() {
        _extractedText = recognized.text.isEmpty
            ? 'Aucun texte détecté dans ce document.'
            : recognized.text;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _extractedText = 'Erreur lors de la reconnaissance du texte.';
        _isProcessing = false;
      });
    }
  }

  Future<void> _translate() async {
    if (_extractedText.isEmpty ||
        _extractedText == 'Aucun texte détecté dans ce document.') return;

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      final targetLang = _mlkitLanguages[_selectedLanguage]!;

      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.french,
        targetLanguage: targetLang,
      );

      // ✅ Fix: utiliser .bcpCode pour convertir en String
      final modelManager = OnDeviceTranslatorModelManager();
      final downloaded =
      await modelManager.isModelDownloaded(targetLang.bcpCode);

      if (!downloaded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Téléchargement du modèle...'),
              ]),
              backgroundColor: Colors.blue.shade700,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        // ✅ Fix: utiliser .bcpCode ici aussi
        await modelManager.downloadModel(targetLang.bcpCode);
      }

      final result = await _translator!.translateText(_extractedText);

      if (!mounted) return;
      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _translatedText = 'Erreur lors de la traduction.';
        _isTranslating = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _reset() {
    setState(() {
      _image = null;
      _extractedText = '';
      _translatedText = '';
    });
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choisir une source',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Caméra',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galerie',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── 1. Header ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(height: 10),
                const Text('Scanner un document',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Extrayez et traduisez le texte de vos documents médicaux',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 2. Zone image ─────────────────────────────────────
          GestureDetector(
            onTap: _showSourceDialog,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _image != null
                      ? Colors.orange.shade300
                      : Colors.grey.shade300,
                  width: _image != null ? 2 : 1,
                ),
              ),
              child: _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('Appuyez pour scanner un document',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Caméra ou Galerie',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12)),
                ],
              ),
            ),
          ),

          if (_image != null) ...[
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Nouvelle image'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600),
              ),
            ]),
          ],

          const SizedBox(height: 20),

          // ── 3. Résultat OCR ───────────────────────────────────
          if (_isProcessing)
            _LoadingCard(
              message: 'Extraction du texte en cours...',
              color: Colors.orange,
            )
          else if (_extractedText.isNotEmpty) ...[
            _SectionTitle(
                title: 'Texte extrait', icon: Icons.text_fields),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: SelectableText(
                _extractedText,
                style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ),

            const SizedBox(height: 20),

            // ── 4. Traduction ─────────────────────────────────
            _SectionTitle(
                title: 'Traduire en',
                icon: Icons.translate_rounded),
            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400),
                  items: _languages.entries
                      .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(children: [
                      Icon(Icons.language,
                          color: Colors.orange.shade400,
                          size: 18),
                      const SizedBox(width: 10),
                      Text(e.value,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                    ]),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedLanguage = val!;
                      _translatedText = '';
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translate,
                icon: _isTranslating
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.translate_rounded, size: 18),
                label: Text(_isTranslating
                    ? 'Traduction...'
                    : 'Traduire le texte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),

            if (_isTranslating)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _LoadingCard(
                  message: 'Traduction en cours...',
                  color: Colors.blue,
                ),
              )
            else if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionTitle(
                  title:
                  'Texte traduit (${_languages[_selectedLanguage]})',
                  icon: Icons.check_circle_outline),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: SelectableText(
                  _translatedText,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.blue.shade900),
                ),
              ),
            ],
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Widgets locaux ────────────────────────────────────────────────────

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String message;
  final Color color;
  const _LoadingCard({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(color: color, strokeWidth: 2),
        ),
        const SizedBox(width: 14),
        Text(message,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold)),
    ]);
  }
}