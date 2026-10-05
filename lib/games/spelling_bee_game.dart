import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';
import '../models/app_models.dart';

class SpellingBeeScreen extends StatefulWidget {
  const SpellingBeeScreen({super.key});

  @override
  State<SpellingBeeScreen> createState() => _SpellingBeeScreenState();
}

class _SpellingBeeScreenState extends State<SpellingBeeScreen> {
  int _currentIndex = 0;
  int _score = 0;
  List<String> _availableLetters = [];
  List<String> _selectedLetters = [];
  late VocabularyWord _currentWord;
  bool _isPlayingSound = false;

  @override
  void initState() {
    super.initState();
    _setupCurrentWord();
  }

  void _setupCurrentWord() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;

    _currentWord = state.words[_currentIndex % state.words.length];
    // Clean word: only A-Z characters for spelling
    final cleanWord = _currentWord.english.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final letters = cleanWord.split('')..shuffle();

    _availableLetters = letters;
    _selectedLetters = [];

    // Pronounce word when question loads
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _speakWord();
    });
  }

  Future<void> _speakWord() async {
    setState(() => _isPlayingSound = true);
    HapticFeedback.lightImpact();
    await TtsService.speakEnglish(_currentWord.english);
    if (mounted) setState(() => _isPlayingSound = false);
  }

  void _selectLetter(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLetters.add(_availableLetters[index]);
      _availableLetters.removeAt(index);
    });
  }

  void _unselectLetter(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _availableLetters.add(_selectedLetters[index]);
      _selectedLetters.removeAt(index);
    });
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _availableLetters.addAll(_selectedLetters);
      _selectedLetters.clear();
    });
  }

  void _checkAnswer() {
    final state = Provider.of<AppState>(context, listen: false);
    final cleanTarget = _currentWord.english.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final assembled = _selectedLetters.join('');

    if (assembled == cleanTarget) {
      _score++;
      state.addCoins(5, 'Spelling Bee g\'alabasi (+5 🪙)');
      state.markWordLearned(_currentWord);
      _speakWord();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 Barakalla, To\'g\'ri!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                child: const Text('🐝', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 12),
              const Text('🪙 +5 Coin hisobingizga qo\'shildi!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
              const SizedBox(height: 8),
              Text(
                '${_currentWord.english} = ${_currentWord.uzbek}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _currentIndex++;
                  _setupCurrentWord();
                });
              },
              child: const Text('Keyingi so\'z ➔'),
            ),
          ],
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Harflar tartibi noto\'g\'ri! Qaytadan urinib ko\'ring.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐝 Spelling Bee (Harflarni ter)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ball: $_score',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_currentIndex + 1}-so\'z',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Word card with translation and speech
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: _isPlayingSound ? AppColors.primaryGreen : AppColors.primaryBlue,
                        ),
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                        onPressed: _speakWord,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('O\'zbekcha: ${_currentWord.uzbek}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Ruscha: ${_currentWord.russian}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'Ta\'rifi: "${_currentWord.definitionUz}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Assembled Letters Area
            const Text('Siz tergan so\'z:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(minHeight: 64),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: _selectedLetters.isEmpty
                  ? const Center(
                      child: Text('Pastdagi harflarni bosib so\'zni yiging...', style: TextStyle(color: Colors.grey)),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_selectedLetters.length, (idx) {
                        return GestureDetector(
                          onTap: () => _unselectLetter(idx),
                          child: Container(
                            width: 44,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _selectedLetters[idx],
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 14),

            // Controls (Clear / Check)
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Tozalash'),
                  onPressed: _selectedLetters.isEmpty ? null : _clearAll,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text('Tekshirish ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: _selectedLetters.isEmpty ? null : _checkAnswer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Available Letter bank
            const Text('Mavjud harflar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(_availableLetters.length, (idx) {
                return GestureDetector(
                  onTap: () => _selectLetter(idx),
                  child: Container(
                    width: 50,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade700, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.amber.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _availableLetters[idx],
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
