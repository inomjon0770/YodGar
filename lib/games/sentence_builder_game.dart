import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';
import '../models/app_models.dart';

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({super.key});

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  int _currentIndex = 0;
  List<String> _targetWords = [];
  List<String> _availableWords = [];
  List<String> _assembledWords = [];
  late VocabularyWord _currentWord;

  @override
  void initState() {
    super.initState();
    _loadSentence();
  }

  void _loadSentence() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;
    _currentWord = state.words[_currentIndex % state.words.length];

    _targetWords = _currentWord.exampleSentence
        .replaceAll(RegExp(r'''[.,!?'"():;]'''), '')
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    _availableWords = List.from(_targetWords)..shuffle();
    _assembledWords = [];
  }

  void _selectWord(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _assembledWords.add(_availableWords[index]);
      _availableWords.removeAt(index);
    });
  }

  void _unselectWord(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _availableWords.add(_assembledWords[index]);
      _assembledWords.removeAt(index);
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _availableWords.addAll(_assembledWords);
      _assembledWords.clear();
    });
  }

  void _checkSentence() {
    final state = Provider.of<AppState>(context, listen: false);

    final assembled = _assembledWords.join(' ').toLowerCase().trim();
    final target = _targetWords.join(' ').toLowerCase().trim();

    if (assembled == target) {
      state.addCoins(6, 'Sentence Builder g\'alabasi (+6 🪙)');
      state.markWordLearned(_currentWord);
      TtsService.speakEnglish(_currentWord.exampleSentence);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🏗️ Gap To\'g\'ri Tuzildi!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                child: const Text('🎉', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 12),
              const Text('🪙 +6 Coin hisobingizga qo\'shildi!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
              const SizedBox(height: 10),
              Text(
                _currentWord.exampleSentence,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                _currentWord.exampleTranslation,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                  _loadSentence();
                });
              },
              child: const Text('Keyingi gap ➔'),
            ),
          ],
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gap tartibi noto\'g\'ri. Qaytadan urinib ko\'ring.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏗️ Gap Tuzish (Sentence Builder)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
            onPressed: () => TtsService.speakEnglish(_currentWord.exampleSentence),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uzbek Translation Guide Card
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('O\'zbekcha tarjimasi:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    _currentWord.exampleTranslation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const Divider(height: 20),
                  Text(
                    'Kalit so\'z: "${_currentWord.english}" (${_currentWord.uzbek})',
                    style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Assembled Sentence Area
            const Text('Tuzilayotgan inglizcha gap:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(minHeight: 80),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: _assembledWords.isEmpty
                  ? const Center(
                      child: Text('Pastdagi so\'z bo\'laklarini bosib gapni yiging...', style: TextStyle(color: Colors.grey)),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_assembledWords.length, (idx) {
                        return GestureDetector(
                          onTap: () => _unselectWord(idx),
                          child: Chip(
                            backgroundColor: AppColors.primaryBlue,
                            label: Text(
                              _assembledWords[idx],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                            onDeleted: () => _unselectWord(idx),
                          ),
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 14),

            // Controls
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Qaytarish'),
                  onPressed: _assembledWords.isEmpty ? null : _reset,
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
                    onPressed: _availableWords.isNotEmpty ? null : _checkSentence,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Available Word chips
            const Text('Mavjud so\'zlar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_availableWords.length, (idx) {
                return ActionChip(
                  elevation: 2,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  label: Text(
                    _availableWords[idx],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                  ),
                  onPressed: () => _selectWord(idx),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
