import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/tts_service.dart';

class WordMatchGameScreen extends StatefulWidget {
  const WordMatchGameScreen({super.key});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  List<Map<String, String>> _leftWords = [];
  List<Map<String, String>> _rightWords = [];
  String? _selectedLeftId;
  String? _selectedRightId;
  final Set<String> _matchedIds = {};

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.words.isEmpty) return;

    final pool = List.from(state.words)..shuffle();
    final roundWords = pool.take(4).toList();

    _leftWords = roundWords.map((w) => {'id': w.id as String, 'text': w.english as String}).toList()..shuffle();
    _rightWords = roundWords.map((w) => {'id': w.id as String, 'text': w.uzbek as String}).toList()..shuffle();
    _selectedLeftId = null;
    _selectedRightId = null;
    _matchedIds.clear();
  }

  void _checkMatch() {
    if (_selectedLeftId != null && _selectedRightId != null) {
      if (_selectedLeftId == _selectedRightId) {
        final matchedId = _selectedLeftId!;
        final state = Provider.of<AppState>(context, listen: false);
        final matchedWord = state.words.firstWhere((w) => w.id == matchedId);

        HapticFeedback.mediumImpact();
        TtsService.speakEnglish(matchedWord.english);

        setState(() {
          _matchedIds.add(matchedId);
          _selectedLeftId = null;
          _selectedRightId = null;
        });

        if (_matchedIds.length == 4) {
          state.addCoins(4, 'Word Match g\'alabasi (+4 🪙)');
          _showWinDialog();
        }
      } else {
        HapticFeedback.lightImpact();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          setState(() {
            _selectedLeftId = null;
            _selectedRightId = null;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Ajoyib Natija!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Text('🧩', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 12),
            const Text('🪙 +4 Coin hisobingizga qo\'shildi!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
            const SizedBox(height: 6),
            const Text('Barcha so\'zlar to\'g\'ri juftlandi.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _startRound());
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
        title: const Text('🧩 Word Match (Juftlash)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Inglizcha so\'z va uning o\'zbekcha tarjimasini bosib juftlang:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Row(
                children: [
                  // Left side (English)
                  Expanded(
                    child: Column(
                      children: _leftWords.map((item) {
                        final id = item['id']!;
                        final isMatched = _matchedIds.contains(id);
                        final isSelected = _selectedLeftId == id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: isMatched
                                ? null
                                : () {
                                    setState(() => _selectedLeftId = id);
                                    _checkMatch();
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                    : (isSelected ? AppColors.primaryBlue : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isMatched
                                      ? AppColors.primaryGreen
                                      : (isSelected ? AppColors.primaryBlue : Colors.grey.shade300),
                                  width: isSelected || isMatched ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  item['text']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isMatched
                                        ? AppColors.primaryGreen
                                        : (isSelected ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Right side (Uzbek)
                  Expanded(
                    child: Column(
                      children: _rightWords.map((item) {
                        final id = item['id']!;
                        final isMatched = _matchedIds.contains(id);
                        final isSelected = _selectedRightId == id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: isMatched
                                ? null
                                : () {
                                    setState(() => _selectedRightId = id);
                                    _checkMatch();
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                    : (isSelected ? AppColors.primaryBlue : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isMatched
                                      ? AppColors.primaryGreen
                                      : (isSelected ? AppColors.primaryBlue : Colors.grey.shade300),
                                  width: isSelected || isMatched ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  item['text']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isMatched
                                        ? AppColors.primaryGreen
                                        : (isSelected ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
