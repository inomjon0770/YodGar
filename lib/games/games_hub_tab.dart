import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'flashcard_game.dart';
import 'word_match_game.dart';
import 'spelling_bee_game.dart';
import 'speed_quiz_game.dart';
import 'listening_game.dart';
import 'fill_blanks_game.dart';
import 'memory_pairs_game.dart';
import 'sentence_builder_game.dart';
import 'true_false_game.dart';
import 'hangman_game.dart';

class GamesHubTab extends StatelessWidget {
  const GamesHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> games = [
      {
        'title': '1. Flashcards (Kartochkalar)',
        'desc': '3D aylanuvchi kartalar orqali so\'z va misollarni yod oling',
        'icon': '🗂️',
        'coins': 3,
        'color': AppColors.primaryBlue,
        'widget': const FlashcardGameScreen(),
      },
      {
        'title': '2. Word Match (Juftlash)',
        'desc': 'Ingliz/Rus so\'zlarini o\'zbekcha tarjimalari bilan bog\'lang',
        'icon': '🧩',
        'coins': 4,
        'color': AppColors.primaryGreen,
        'widget': const WordMatchGameScreen(),
      },
      {
        'title': '3. Spelling Bee (Harflarni ter)',
        'desc': 'Aralashgan harflardan to\'g\'ri so\'zni terib chiqing',
        'icon': '🐝',
        'coins': 5,
        'color': Colors.amber.shade800,
        'widget': const SpellingBeeScreen(),
      },
      {
        'title': '4. Speed Quiz (Tezkor viktorina)',
        'desc': 'Vaqt tugamasdan 4 ta variantdan to\'g\'risini tanlang',
        'icon': '⚡',
        'coins': 6,
        'color': Colors.deepOrange,
        'widget': const SpeedQuizScreen(),
      },
      {
        'title': '5. Audio / Pronunciation (Eshitib top)',
        'desc': 'Talaffuz va fonetika bo\'yicha to\'g\'ri so\'zni toping',
        'icon': '🎧',
        'coins': 5,
        'color': Colors.purple,
        'widget': const ListeningAudioScreen(),
      },
      {
        'title': '6. Fill in Blanks (Bo\'shliqni to\'ldir)',
        'desc': 'Gapdagi tushirib qoldirilgan kalit so\'zni aniqlang',
        'icon': '📝',
        'coins': 5,
        'color': Colors.teal,
        'widget': const FillBlanksScreen(),
      },
      {
        'title': '7. Memory Pairs (Xotira o\'yini)',
        'desc': 'Yopiq kartochkalar ichidan juft so\'zlarni topib oching',
        'icon': '🧠',
        'coins': 6,
        'color': Colors.indigo,
        'widget': const MemoryPairsScreen(),
      },
      {
        'title': '8. Sentence Builder (Gap tuzish)',
        'desc': 'Aralash so\'zlarni ketma-ket joylab to\'g\'ri gap hosil qiling',
        'icon': '🏗️',
        'coins': 6,
        'color': Colors.brown,
        'widget': const SentenceBuilderScreen(),
      },
      {
        'title': '9. True or False (To\'g\'ri/Noto\'g\'ri)',
        'desc': 'Tarjima to\'g\'ri berilganmi? Tezkor Ha yoki Yo\'q',
        'icon': '✅',
        'coins': 4,
        'color': Colors.cyan.shade700,
        'widget': const TrueFalseScreen(),
      },
      {
        'title': '10. Hangman (So\'zni top)',
        'desc': 'Klassik so\'z topish: harflarni taxmin qilib g\'olib bo\'ling',
        'icon': '🎯',
        'coins': 8,
        'color': Colors.pink,
        'widget': const HangmanScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 10 ta So\'z O\'yini'),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final color = game['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => game['widget'] as Widget),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(game['icon'] as String, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                game['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+${game['coins']} 🪙',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game['desc'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
