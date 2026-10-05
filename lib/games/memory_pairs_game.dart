import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/tts_service.dart';

class MemoryPairsScreen extends StatefulWidget {
  const MemoryPairsScreen({super.key});

  @override
  State<MemoryPairsScreen> createState() => _MemoryPairsScreenState();
}

class _MemoryCard {
  final String id;
  final String text;
  final String pairId;
  bool isFaceUp;
  bool isMatched;

  _MemoryCard({
    required this.id,
    required this.text,
    required this.pairId,
  })  : isFaceUp = false,
        isMatched = false;
}

class _MemoryPairsScreenState extends State<MemoryPairsScreen> {
  List<_MemoryCard> _cards = [];
  int? _firstSelectedIndex;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final state = Provider.of<AppState>(context, listen: false);
    final pool = List.from(state.words)..shuffle();
    final chosen = pool.take(4).toList();

    List<_MemoryCard> list = [];
    for (var i = 0; i < chosen.length; i++) {
      final w = chosen[i];
      list.add(_MemoryCard(id: '${i}_en', text: w.english, pairId: 'pair_$i'));
      list.add(_MemoryCard(id: '${i}_uz', text: w.uzbek, pairId: 'pair_$i'));
    }
    list.shuffle();

    _cards = list;
    _firstSelectedIndex = null;
    _busy = false;
  }

  void _onCardTap(int index) {
    if (_busy) return;
    final card = _cards[index];
    if (card.isFaceUp || card.isMatched) return;

    setState(() {
      card.isFaceUp = true;
    });

    if (card.id.endsWith('_en')) {
      TtsService.speakEnglish(card.text);
    }

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      final firstCard = _cards[_firstSelectedIndex!];
      if (firstCard.pairId == card.pairId) {
        // Matched!
        final enText = card.id.endsWith('_en') ? card.text : firstCard.text;
        TtsService.speakEnglish(enText);

        setState(() {
          firstCard.isMatched = true;
          card.isMatched = true;
          _firstSelectedIndex = null;
        });

        // Check if all matched
        if (_cards.every((c) => c.isMatched)) {
          final state = Provider.of<AppState>(context, listen: false);
          state.addCoins(6, 'Memory Pairs g\'alabasi (+6 🪙)');
          _showWinDialog();
        }
      } else {
        // Not matched -> flip back after 700ms
        _busy = true;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            firstCard.isFaceUp = false;
            card.isFaceUp = false;
            _firstSelectedIndex = null;
            _busy = false;
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
        title: const Text('🧠 Xotira Chempioni!', textAlign: TextAlign.center),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪙 +6 Coin hisobingizga qo\'shildi!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Barcha juftliklarni to\'g\'ri ochdingiz.'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _initGame());
            },
            child: const Text('Yana o\'ynash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Memory Pairs (Xotira)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Yopiq kartochkalardan juft so\'zlarni toping:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];

                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: card.isMatched
                            ? AppColors.primaryGreen.withValues(alpha: 0.8)
                            : card.isFaceUp
                                ? AppColors.primaryBlue
                                : Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: card.isMatched
                              ? AppColors.primaryGreen
                              : card.isFaceUp
                                  ? Colors.white
                                  : Colors.black12,
                          width: 1.5,
                        ),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      child: card.isFaceUp || card.isMatched
                          ? Text(
                              card.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          : const Icon(Icons.help_outline_rounded, color: Colors.grey, size: 28),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
