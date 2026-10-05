import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';
import '../models/app_models.dart';

class HangmanScreen extends StatefulWidget {
  const HangmanScreen({super.key});

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  int _currentIndex = 0;
  final Set<String> _guessedLetters = {};
  int _mistakes = 0;
  final int _maxMistakes = 6;
  late VocabularyWord _currentWord;

  final String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;
    _currentWord = state.words[_currentIndex % state.words.length];
    _guessedLetters.clear();
    _mistakes = 0;
  }

  void _guessLetter(String letter) {
    if (_guessedLetters.contains(letter) || _mistakes >= _maxMistakes) return;

    HapticFeedback.selectionClick();
    final state = Provider.of<AppState>(context, listen: false);
    final targetUpper = _currentWord.english.toUpperCase();

    setState(() {
      _guessedLetters.add(letter);
      if (!targetUpper.contains(letter)) {
        _mistakes++;
      }
    });

    // Check Win: all letters A-Z in targetUpper must be in _guessedLetters (spaces and hyphens ignored!)
    final isWon = targetUpper.split('').every((char) => !RegExp(r'[A-Z]').hasMatch(char) || _guessedLetters.contains(char));
    if (isWon) {
      state.addCoins(8, 'Hangman g\'alabasi (+8 🪙)');
      state.markWordLearned(_currentWord);
      TtsService.speakEnglish(_currentWord.english);
      _showResultDialog(true);
      return;
    }

    // Check Loss
    if (_mistakes >= _maxMistakes) {
      TtsService.speakEnglish(_currentWord.english);
      _showResultDialog(false);
    }
  }

  void _giveHint() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.currentAccount.coins < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yordam olish uchun kamida 3 Coin kerak!')),
      );
      return;
    }

    final targetUpper = _currentWord.english.toUpperCase();
    final remainingLetters = targetUpper
        .split('')
        .where((c) => RegExp(r'[A-Z]').hasMatch(c) && !_guessedLetters.contains(c))
        .toList();

    if (remainingLetters.isNotEmpty) {
      state.spendCoins(3);
      final hintLetter = remainingLetters.first;
      _guessLetter(hintLetter);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('💡 Maslahat: "$hintLetter" harfi ochildi! (-3 Coin)')),
      );
    }
  }

  void _showResultDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(won ? '🎉 G\'alaba!' : '😢 Afsus, urinishlar tugadi!', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: won ? Colors.green.shade50 : Colors.red.shade50, shape: BoxShape.circle),
              child: Text(won ? '🏆' : '💀', style: const TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 12),
            if (won) ...[
              const Text('🪙 +8 Coin hisobingizga qo\'shildi!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
              const SizedBox(height: 10),
            ],
            Text('Yashiringan so\'z: ${_currentWord.english}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text('Tarjimasi: ${_currentWord.uzbek}', style: const TextStyle(color: Colors.black87, fontSize: 14)),
            Text('Ruscha: ${_currentWord.russian}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: won ? AppColors.primaryGreen : AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentIndex++;
                _startRound();
              });
            },
            child: const Text('Keyingi so\'z ➔'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetUpper = _currentWord.english.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Hangman (So\'zni top)'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
            label: const Text('Maslahat (10 🪙)', style: TextStyle(color: Colors.amber, fontSize: 12)),
            onPressed: _giveHint,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mistake progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Xatolar: $_mistakes / $_maxMistakes', style: TextStyle(fontWeight: FontWeight.bold, color: _mistakes > 4 ? Colors.red : Colors.grey.shade700)),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                  onPressed: () => TtsService.speakEnglish(_currentWord.english),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Word display area (dashes & revealed letters)
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Text(
                    'Ta\'rifi: "${_currentWord.definitionUz}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: targetUpper.split('').map((char) {
                      if (char == ' ') {
                        return const SizedBox(width: 16);
                      }
                      final revealed = !RegExp(r'[A-Z]').hasMatch(char) || _guessedLetters.contains(char);
                      return Container(
                        width: 38,
                        height: 44,
                        decoration: BoxDecoration(
                          color: revealed ? AppColors.primaryBlue.withValues(alpha: 0.12) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(bottom: BorderSide(color: revealed ? AppColors.primaryBlue : Colors.black45, width: 3)),
                        ),
                        child: Center(
                          child: Text(
                            revealed ? char : '',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Keyboard layout
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Harfni tanlang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _alphabet.split('').map((letter) {
                final isGuessed = _guessedLetters.contains(letter);
                final inTarget = targetUpper.contains(letter);

                Color btnColor = Colors.white;
                Color textColor = Colors.black87;

                if (isGuessed) {
                  btnColor = inTarget ? AppColors.primaryGreen.withValues(alpha: 0.3) : Colors.grey.shade300;
                  textColor = inTarget ? AppColors.primaryGreen : Colors.grey;
                }

                return SizedBox(
                  width: 44,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: btnColor,
                      foregroundColor: textColor,
                      elevation: isGuessed ? 0 : 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isGuessed ? null : () => _guessLetter(letter),
                    child: Text(letter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
