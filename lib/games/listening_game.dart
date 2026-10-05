import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../services/tts_service.dart';
import '../models/app_models.dart';

class ListeningAudioScreen extends StatefulWidget {
  const ListeningAudioScreen({super.key});

  @override
  State<ListeningAudioScreen> createState() => _ListeningAudioScreenState();
}

class _ListeningAudioScreenState extends State<ListeningAudioScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isPlaying = false;
  String? _selectedAnswer;
  bool _answered = false;

  late VocabularyWord _currentWord;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;

    _currentWord = state.words[_currentIndex % state.words.length];

    final wrongWords = state.words
        .where((w) => w.english.toLowerCase() != _currentWord.english.toLowerCase())
        .toList()
      ..shuffle();

    final wrongOptions = wrongWords.take(3).map((w) => w.english).toList();
    _options = [_currentWord.english, ...wrongOptions]..shuffle();

    _selectedAnswer = null;
    _answered = false;

    // Automatically speak the word when question loads
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _playSpeech(slow: false);
    });
  }

  Future<void> _playSpeech({bool slow = false}) async {
    setState(() => _isPlaying = true);
    HapticFeedback.lightImpact();
    await TtsService.speakEnglish(_currentWord.english, slow: slow);
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _checkAnswer(String chosen) {
    if (_answered) return;

    final state = Provider.of<AppState>(context, listen: false);
    final isCorrect = chosen.toLowerCase() == _currentWord.english.toLowerCase();

    setState(() {
      _answered = true;
      _selectedAnswer = chosen;
      if (isCorrect) {
        _score++;
        state.addCoins(5, 'Pronunciation g\'alabasi (+5 🪙)');
        state.markWordLearned(_currentWord);
      }
    });

    HapticFeedback.mediumImpact();

    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('To\'g\'ri! "${_currentWord.english}" = ${_currentWord.uzbek} (+5 Coin)'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Noto\'g\'ri! To\'g\'ri javob: "${_currentWord.english}"'),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
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
        title: const Text('🎧 Eshitib Topish Yakunlandi!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        title: const Text('🎧 Eshitib Topish (Listening)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentIndex + 1}/5',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
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
              'Haqiqiy inglizcha talaffuzni eshiting va to\'g\'ri so\'zni belgilang:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Animated Speaker & Sound wave card
            GlassContainer(
              borderRadius: 28,
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _playSpeech(slow: false),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isPlaying
                              ? [AppColors.primaryGreen, Colors.teal]
                              : [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isPlaying ? AppColors.primaryGreen : Colors.purple).withValues(alpha: 0.4),
                            blurRadius: _isPlaying ? 28 : 14,
                            spreadRadius: _isPlaying ? 6 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _isPlaying ? '🔊 Gapirmoqda...' : 'Eshitish uchun bosing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _isPlaying ? AppColors.primaryGreen : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Speed Control Buttons (Normal / Slow 0.5x)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.speed_rounded, size: 16),
                        label: const Text('Sekin (0.5x)', style: TextStyle(fontSize: 12)),
                        onPressed: () => _playSpeech(slow: true),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Qayta', style: TextStyle(fontSize: 12)),
                        onPressed: () => _playSpeech(slow: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Phonetic transcription hint
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Fonetika: ${_currentWord.phonetic}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ta\'rifi: "${_currentWord.definitionUz}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Qaysi so\'z talaffuz qilindi?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),

            // Options
            ..._options.map((opt) {
              final isChosen = _selectedAnswer == opt;
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
                    elevation: 2,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
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
