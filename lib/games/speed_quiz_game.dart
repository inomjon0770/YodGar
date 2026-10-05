import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';
import '../models/app_models.dart';

class SpeedQuizScreen extends StatefulWidget {
  const SpeedQuizScreen({super.key});

  @override
  State<SpeedQuizScreen> createState() => _SpeedQuizScreenState();
}

class _SpeedQuizScreenState extends State<SpeedQuizScreen> {
  int _score = 0;
  int _questionIndex = 0;
  Timer? _timer;
  int _timeLeft = 10;
  String? _selectedOption;
  bool _answered = false;

  late VocabularyWord _currentWord;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadQuestion() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;

    final pool = List.from(state.words)..shuffle();
    _currentWord = pool.first;

    final wrongOptions = pool.skip(1).take(3).map((w) => w.uzbek as String).toList();
    _options = [_currentWord.uzbek, ...wrongOptions]..shuffle();

    _timeLeft = 10;
    _answered = false;
    _selectedOption = null;

    // Pronounce the word
    TtsService.speakEnglish(_currentWord.english);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _handleAnswer('');
      }
    });
  }

  void _handleAnswer(String option) {
    if (_answered) return;
    _timer?.cancel();

    final isCorrect = option == _currentWord.uzbek;
    HapticFeedback.mediumImpact();

    setState(() {
      _answered = true;
      _selectedOption = option;
      if (isCorrect) {
        _score++;
        final state = Provider.of<AppState>(context, listen: false);
        state.addCoins(6, 'Speed Quiz g\'alabasi (+6 🪙)');
        state.markWordLearned(_currentWord);
      }
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      if (_questionIndex < 4) {
        setState(() {
          _questionIndex++;
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
        title: const Text('⚡ Tezkor Viktorina Yakunlandi!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.deepOrange.shade50, shape: BoxShape.circle),
              child: const Text('🏆', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 12),
            Text('Natijangiz: $_score / 5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 6),
            Text('Ishlangan coin: +${_score * 6} 🪙', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _score = 0;
                _questionIndex = 0;
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
        title: const Text('⚡ Speed Quiz (Tezkor viktorina)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_questionIndex + 1}/5',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer Bar
            LinearProgressIndicator(
              value: _timeLeft / 10.0,
              backgroundColor: Colors.grey.shade200,
              color: _timeLeft > 3 ? Colors.deepOrange : Colors.red,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qolgan vaqt: $_timeLeft soniya', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                  onPressed: () => TtsService.speakEnglish(_currentWord.english),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question Card
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Text('Ushbu so\'zning to\'g\'ri tarjimasini tanlang:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  Text(
                    _currentWord.english,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentWord.phonetic,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ..._options.map((opt) {
              final isChosen = _selectedOption == opt;
              final isCorrect = opt == _currentWord.uzbek;

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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: border,
                    ),
                  ),
                  onPressed: _answered ? null : () => _handleAnswer(opt),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(opt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
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
