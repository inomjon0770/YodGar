import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';
import '../models/app_models.dart';

class FillBlanksScreen extends StatefulWidget {
  const FillBlanksScreen({super.key});

  @override
  State<FillBlanksScreen> createState() => _FillBlanksScreenState();
}

class _FillBlanksScreenState extends State<FillBlanksScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answered = false;

  late VocabularyWord _currentWord;
  List<String> _options = [];
  String _sentenceWithBlank = '';

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;

    _currentWord = state.words[_currentIndex % state.words.length];

    _sentenceWithBlank = _currentWord.exampleSentence.replaceAll(
      RegExp(_currentWord.english, caseSensitive: false),
      '________',
    );

    final wrongWords = state.words
        .where((w) => w.english.toLowerCase() != _currentWord.english.toLowerCase())
        .toList()
      ..shuffle();

    final wrongOptions = wrongWords.take(3).map((w) => w.english).toList();
    _options = [_currentWord.english, ...wrongOptions]..shuffle();

    _selectedOption = null;
    _answered = false;
  }

  void _checkAnswer(String chosen) {
    if (_answered) return;

    final state = Provider.of<AppState>(context, listen: false);
    final isCorrect = chosen.toLowerCase() == _currentWord.english.toLowerCase();

    setState(() {
      _answered = true;
      _selectedOption = chosen;
      if (isCorrect) {
        _score++;
        state.addCoins(5, 'Fill in the blanks g\'alabasi (+5 🪙)');
        state.markWordLearned(_currentWord);
      }
    });

    HapticFeedback.mediumImpact();

    if (isCorrect) {
      // Speak the full correct sentence!
      TtsService.speakEnglish(_currentWord.exampleSentence);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Ajoyib! Gap to\'ldirildi: "${_currentWord.english}" (+5 Coin)'),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Noto\'g\'ri so\'z tanlandi! To\'g\'ri javob: "${_currentWord.english}"'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_currentIndex < 4) {
        setState(() {
          _currentIndex++;
          _loadQuestion();
        });
      } else {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('📝 Bo\'shliqni To\'ldirish Yakunlandi!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
              child: const Text('🏆', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 12),
            Text('Natijangiz: $_score / 5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 6),
            Text('Ishlangan coin: +${_score * 5} 🪙', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _loadQuestion();
              });
            },
            child: const Text('Yana o\'ynash'),
          ),
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
        title: const Text('📝 Bo\'shliqni to\'ldir'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentIndex + 1}/5',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Gapdagi bo\'sh joyga mos keladigan so\'zni tanlang:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Sentence Card
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kontekstli gap:', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                        onPressed: () => TtsService.speakEnglish(_currentWord.exampleSentence),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _sentenceWithBlank,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const Divider(height: 26),
                  Text(
                    'Tarjimasi: "${_currentWord.exampleTranslation}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Bo\'shliqqa mos so\'zni tanlang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 12),

            // Options list
            ..._options.map((opt) {
              final isChosen = _selectedOption == opt;
              final isCorrect = opt.toLowerCase() == _currentWord.english.toLowerCase();

              Color bgColor = Colors.white;
              Color textColor = Colors.black87;
              BorderSide border = BorderSide(color: Colors.grey.shade300);

              if (_answered) {
                if (isCorrect) {
                  bgColor = AppColors.primaryGreen;
                  textColor = Colors.white;
                  border = const BorderSide(color: AppColors.primaryGreen, width: 2);
                } else if (isChosen) {
                  bgColor = Colors.redAccent;
                  textColor = Colors.white;
                  border = const BorderSide(color: Colors.redAccent, width: 2);
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: border,
                    ),
                  ),
                  onPressed: _answered ? null : () => _checkAnswer(opt),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                      if (_answered && isCorrect)
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22)
                      else if (_answered && isChosen)
                        const Icon(Icons.cancel_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
