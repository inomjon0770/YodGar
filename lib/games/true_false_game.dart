import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';

class TrueFalseScreen extends StatefulWidget {
  const TrueFalseScreen({super.key});

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  int _score = 0;
  int _round = 0;
  late dynamic _currentWord;
  late String _displayedTranslation;
  late bool _isActuallyCorrect;

  @override
  void initState() {
    super.initState();
    _loadNext();
  }

  void _loadNext() {
    final state = Provider.of<AppState>(context, listen: false);
    final pool = List.from(state.words)..shuffle();
    _currentWord = pool.first;

    final random = Random();
    _isActuallyCorrect = random.nextBool();

    if (_isActuallyCorrect) {
      _displayedTranslation = _currentWord.uzbek;
    } else {
      final otherWord = pool.skip(1).first;
      _displayedTranslation = otherWord.uzbek;
    }
    TtsService.speakEnglish(_currentWord.english);
  }

  void _answer(bool userChoice) {
    final isCorrect = (userChoice == _isActuallyCorrect);

    if (isCorrect) {
      _score++;
      final state = Provider.of<AppState>(context, listen: false);
      state.addCoins(1, 'True or False g\'alabasi (+1 🪙)');
      state.markWordLearned(_currentWord);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ To\'g\'ri topdingiz! (+1 Coin)'),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(milliseconds: 700),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Xato! Diqqatliroq bo\'ling.'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 700),
        ),
      );
    }

    if (_round < 4) {
      setState(() {
        _round++;
        _loadNext();
      });
    } else {
      _showGameOver();
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎯 O\'yin Yakunlandi!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Natija: $_score / 5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Jami ishlangan coin: ${_score * 1} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tugallash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ To\'g\'ri yoki Noto\'g\'ri?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bosqich: ${_round + 1} / 5', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Ball: $_score', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 30),

            // Card showing Word & Purported Translation
            GlassContainer(
              borderRadius: 28,
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              child: Column(
                children: [
                  const Text('So\'z:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentWord.english,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                        tooltip: 'Tinglash',
                        onPressed: () => TtsService.speakEnglish(_currentWord.english),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🇷🇺 ${_currentWord.russian}',
                    style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  const Divider(height: 36),
                  const Text('Keltirilgan tarjimasi:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(
                    _displayedTranslation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 14),
                  const Text('Tarjima to\'g\'rimi?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const Spacer(),

            // True / False Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    onPressed: () => _answer(false),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded, size: 24),
                        SizedBox(width: 8),
                        Text('NOTO\'G\'RI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    onPressed: () => _answer(true),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 24),
                        SizedBox(width: 8),
                        Text('TO\'G\'RI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
