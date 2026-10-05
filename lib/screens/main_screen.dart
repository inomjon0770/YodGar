import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/day_night_header.dart';
import '../widgets/stories_bar.dart';
import '../widgets/coin_shop_dialog.dart';
import '../games/games_hub_tab.dart';
import 'admin_panel_screen.dart';
import 'community_screen.dart';
import 'support_chat_screen.dart';
import '../models/app_models.dart';
import '../services/tts_service.dart';
import '../widgets/duolingo_home_widget_dialog.dart';
import '../widgets/user_profile_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTabIndex = 0;

  // Home search & filter
  String _searchQuery = '';
  String _selectedCategory = 'Barchasi';

  // Translator controllers
  final TextEditingController _translateInput = TextEditingController();
  String _fromLang = 'Inglizcha';
  String _toLang = 'O\'zbekcha';
  String _translatedResult = '';
  bool _isTranslating = false;

  // AI Sobir chat controller
  final TextEditingController _sobirInput = TextEditingController();

  // Add custom word modal controllers
  final TextEditingController _cwEn = TextEditingController();
  final TextEditingController _cwRu = TextEditingController();
  final TextEditingController _cwUz = TextEditingController();
  final TextEditingController _cwDef = TextEditingController();
  final TextEditingController _cwEx = TextEditingController();

  @override
  void dispose() {
    _translateInput.dispose();
    _sobirInput.dispose();
    _cwEn.dispose();
    _cwRu.dispose();
    _cwUz.dispose();
    _cwDef.dispose();
    _cwEx.dispose();
    super.dispose();
  }

  void _openCoinShop() {
    showDialog(
      context: context,
      builder: (context) => const CoinShopDialog(),
    );
  }

  void _openPromoCodeDialog(AppState state) {
    final promoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🎁', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Do\'st taklif kodi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Do\'stingizdan olgan taklif kodini yoki maxsus promo-kodni kiriting (masalan: INOMJON2026) va darhol +100 Coin oling!',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: promoCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'YODGAR-XXXXX yoki INOMJON2026',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              final code = promoCtrl.text.trim();
              if (code.isEmpty) return;
              final ok = state.applyReferralCode(code);
              Navigator.of(ctx).pop();
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Promo-kod muvaffaqiyatli qo\'llandi! Hisobingizga +100 Coin qo\'shildi! 🪙'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Noto\'g\'ri promo-kod yoki o\'zingizning kodingiz!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Tasdiqlash (+100 🪙)'),
          ),
        ],
      ),
    );
  }

  void _openAddWordDialog(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('➕ Yangi So\'z Qo\'shish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lug\'at boyligini oshirish uchun o\'zingiz bilgan yangi so\'zni qo\'shing. Tizim uni tekshirib lug\'atga kiritadi va sizga +25 Coin beradi!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(controller: _cwEn, decoration: const InputDecoration(labelText: 'Inglizcha so\'z*')),
              TextField(controller: _cwRu, decoration: const InputDecoration(labelText: 'Ruscha tarjimasi')),
              TextField(controller: _cwUz, decoration: const InputDecoration(labelText: 'O\'zbekcha ma\'nosi*')),
              TextField(controller: _cwDef, decoration: const InputDecoration(labelText: 'Ta\'rifi / Izohi')),
              TextField(controller: _cwEx, decoration: const InputDecoration(labelText: 'Misol gap')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              if (_cwEn.text.trim().isEmpty || _cwUz.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Iltimos, kamida Inglizcha va O\'zbekcha so\'zni kiriting!')),
                );
                return;
              }
              final success = state.addCustomWord(
                english: _cwEn.text.trim(),
                russian: _cwRu.text.trim(),
                uzbek: _cwUz.text.trim(),
                definitionUz: _cwDef.text.trim().isEmpty ? 'Foydalanuvchi so\'zi' : _cwDef.text.trim(),
                exampleSentence: _cwEx.text.trim().isEmpty ? 'Good luck with learning.' : _cwEx.text.trim(),
                category: 'B1',
              );

              Navigator.of(ctx).pop();
              if (success) {
                _cwEn.clear();
                _cwRu.clear();
                _cwUz.clear();
                _cwDef.clear();
                _cwEx.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 So\'z muvaffaqiyatli tekshirildi va qo\'shildi! +25 Coin berildi.'), backgroundColor: AppColors.primaryGreen),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ushbu so\'z allaqachon lug\'atda mavjud.'), backgroundColor: Colors.orange),
                );
              }
            },
            child: const Text('Qo\'shish (+25 🪙)'),
          ),
        ],
      ),
    );
  }

  // Real-time Translator execution
  Future<void> _performTranslation() async {
    final text = _translateInput.text.trim();
    if (text.isEmpty) return;

    final state = Provider.of<AppState>(context, listen: false);
    setState(() => _isTranslating = true);

    try {
      final res = await state.translateText(
        text: text,
        fromLanguage: _fromLang,
        toLanguage: _toLang,
      );
      if (mounted) {
        setState(() {
          _translatedResult = res.isNotEmpty ? res : 'Tarjima topilmadi';
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _translatedResult = 'Tarjima xatoligi. Qayta urinib ko\'ring: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeTab(state),
          const GamesHubTab(),
          _buildLeaderboardTab(state),
          _buildAiAndTranslatorTab(state),
          _buildProfileTab(state),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.primaryBlue), label: 'Bosh sahifa'),
          NavigationDestination(icon: Icon(Icons.videogame_asset_outlined), selectedIcon: Icon(Icons.videogame_asset, color: AppColors.primaryGreen), label: 'O\'yinlar'),
          NavigationDestination(icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard, color: AppColors.gold), label: 'Reyting'),
          NavigationDestination(icon: Icon(Icons.translate_outlined), selectedIcon: Icon(Icons.translate, color: Colors.purple), label: 'AI & Tarjima'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.primaryBlue), label: 'Profil'),
        ],
      ),
    );
  }

  // 1. HOME TAB
  Widget _buildHomeTab(AppState state) {
    final filteredWords = state.words.where((w) {
      final matchesSearch = w.english.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            w.russian.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            w.uzbek.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'Barchasi' || w.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Dynamic Sun / Moon Header
          SliverToBoxAdapter(
            child: DayNightHeader(
              isDay: state.isDayMode,
              onToggle: () => state.toggleDayNight(),
              greeting: state.isDayMode ? 'Xayrli kun! ☀️' : 'Xayrli oqshom! 🌙',
              userName: state.currentAccount.name,
              streak: state.currentAccount.streak,
              coins: state.currentAccount.coins,
              onCoinsTap: _openCoinShop,
            ),
          ),
          // Collapsible Instagram Stories Bar
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Yangiliklar & E\'lonlar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (state.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Admin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                StoriesBar(
                  stories: state.stories,
                  isAdmin: state.isAdmin,
                  onAddStory: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const AdminPanelScreen()),
                  ),
                ),
                const Divider(height: 12),
              ],
            ),
          ),
        ];
      },
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        children: [
          // Daily Goals & Streak Card
          GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        const Text('Kunlik reja:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Text(
                      '${state.currentAccount.dailyWordsLearned} / ${state.currentAccount.dailyLimit} ta so\'z',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (state.currentAccount.dailyWordsLearned / state.currentAccount.dailyLimit).clamp(0.0, 1.0),
                  backgroundColor: Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(6),
                  minHeight: 8,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Liga: ${state.currentAccount.rank} 🏆',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 13),
                    ),
                    InkWell(
                      onTap: () => setState(() => _currentTabIndex = 1),
                      child: const Text('O\'yinlarni boshlash ➔', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Weekly Streak & Progressive Coin Rewards Card
          _buildWeeklyStreakCard(state),
          const SizedBox(height: 16),

          // Duolingo Phone Home Screen Widget Generator
          _buildDuolingoWidgetBanner(state),
          const SizedBox(height: 16),

          // 2. Kun so'zi (Word of the Day) Spotlight Card
          _buildWordOfTheDayCard(state),
          const SizedBox(height: 16),

          // Community Activity Banner
          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CommunityScreen()),
              );
            },
            child: Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jamoa & Do\'stlar Chati', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Yutuqlaringizni ulashing va do\'stlarga yurak tashlang ❤️', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Vocabulary Search & Filter Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lug\'at boyligi (${filteredWords.length} ta)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('So\'z qo\'shish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => _openAddWordDialog(state),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Box
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'So\'zlarni qidirish (Inglizcha, Ruscha, O\'zbekcha)...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Barchasi', 'A1', 'A2', 'B1', 'B2', 'C1', 'IELTS'].map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSel,
                    selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Vocabulary list items with Audio Pronunciation & Favorite Bookmark
          ...filteredWords.map((word) {
            final isFav = state.isFavoriteWord(word.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(word.english, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              const SizedBox(width: 8),
                              Text(word.phonetic, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Talaffuzi',
                              onPressed: () => _playPronunciation(word.english),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isFav ? Colors.amber : Colors.grey,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Sevimlilar',
                              onPressed: () => state.toggleFavoriteWord(word.id),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(word.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('🇷🇺 ${word.russian}', style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    const SizedBox(height: 6),
                    Text('🇺🇿 ${word.uzbek}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    const SizedBox(height: 6),
                    Text(word.definitionUz, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• "${word.exampleSentence}"',
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!word.isLearned)
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                            icon: const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primaryGreen),
                            label: const Text('Yodladim (+10 🪙)', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              state.markWordLearned(word);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 "${word.english}" so\'zi yodlandi! +10 Coin berildi.'),
                                  backgroundColor: AppColors.primaryGreen,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- AUDIO PRONUNCIATION REAL TTS ---
  void _playPronunciation(String word, {String lang = 'en'}) {
    HapticFeedback.lightImpact();
    TtsService.speak(word, language: lang);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('🔊 "$word" talaffuz qilinmoqda...', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // --- WEEKLY STREAK & PROGRESSIVE REWARDS CARD ---
  Widget _buildWeeklyStreakCard(AppState state) {
    final acc = state.currentAccount;
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🔥', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text('Haftalik Streak & Sovrinlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangeFlame.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${acc.weeklyStreak}/7 kun',
                  style: const TextStyle(color: AppColors.orangeFlame, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 7-day row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (idx) {
                final day = idx + 1;
                final reward = AppState.weeklyStreakRewards[day] ?? 10;
                final isClaimed = state.isWeeklyRewardClaimed(day);
                final canClaim = state.canClaimWeeklyReward(day);
                final isCurrent = day == acc.weeklyStreak;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 74,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: isCurrent
                        ? AppColors.goldRewardGradient
                        : (isClaimed
                            ? const LinearGradient(colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)])
                            : null),
                    color: isCurrent || isClaimed
                        ? null
                        : (canClaim ? Colors.amber.shade100 : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.gold
                          : (canClaim ? AppColors.gold : Colors.black12),
                      width: isCurrent || canClaim ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$day-kun',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black87 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day == 7 ? '👑' : (isClaimed ? '✓' : (canClaim ? '🎁' : '🪙')),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+$reward',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black87 : AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isClaimed) ...[
                        const Text(
                          'Olingan',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ] else if (canClaim) ...[
                        InkWell(
                          onTap: () {
                            final ok = state.claimWeeklyReward(day);
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 Tabriklaymiz! $day-kunlik mukofot: +$reward Coin berildi! 🪙'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Olish',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.lock_rounded, size: 12, color: Colors.grey),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- DUOLINGO PHONE HOME SCREEN WIDGET GENERATOR BANNER ---
  Widget _buildDuolingoWidgetBanner(AppState state) {
    final acc = state.currentAccount;
    final isDanger = acc.weeklyStreak > 0 && !acc.dailyGoalCompleted;

    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () {
        DuolingoWidgetDialog.show(context, state, () {
          setState(() => _currentTabIndex = 1);
        });
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDanger
                    ? [const Color(0xFFFF5252), const Color(0xFFFF7A00)]
                    : [const Color(0xFFFF9600), const Color(0xFFFFC800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (isDanger ? const Color(0xFFFF5252) : const Color(0xFFFF9600)).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(isDanger ? '🔥' : '👑', style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Duolingo Vidjet Shablonlari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('YANGI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Bosh ekranga qadash: Streak (${acc.weeklyStreak} kun), Coin (${acc.coins} 🪙) va liga holati',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // --- KUN SO'ZI (WORD OF THE DAY) SPOTLIGHT CARD ---
  Widget _buildWordOfTheDayCard(AppState state) {
    final word = state.wordOfTheDay;
    final isFav = state.isFavoriteWord(word.id);

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('✨', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kun so\'zi (Word of the Day)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFav ? Colors.amber : Colors.grey,
                    ),
                    tooltip: 'Sevimlilar',
                    onPressed: () => state.toggleFavoriteWord(word.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                    tooltip: 'Talaffuzi',
                    onPressed: () => _playPronunciation(word.english),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                word.english,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 10),
              Text(
                word.phonetic,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word.category,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('🇺🇿 ${word.uzbek}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Text('🇷🇺 ${word.russian}', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• "${word.exampleSentence}"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 2),
                Text(
                  '  ${word.exampleTranslation}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!word.isLearned)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Yodladim (+10 🪙)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    state.markWordLearned(word);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 "${word.english}" so\'zi yodlandi! +10 Coin berildi.'),
                        backgroundColor: AppColors.primaryGreen,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                )
              else
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 18),
                    SizedBox(width: 4),
                    Text('Yodlangan', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. REYTING / LEADERBOARD TAB
  Widget _buildLeaderboardTab(AppState state) {
    final list = List.from(state.leaderboard);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Foydalanuvchilar Reytingi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // If only 1 user or empty
          if (list.length == 1) ...[
            // Single User Champion Card
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              onTap: () {
                final target = state.accounts.firstWhere((a) => a.id == list[0].id, orElse: () => state.currentAccount);
                UserProfileDialog.show(context, target);
              },
              child: Column(
                children: [
                  const Text('🥇', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(
                    '${list[0].name} — Reyting Peshqadami!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🔥 ${list[0].streak} kun streak', style: const TextStyle(color: AppColors.orangeFlame, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 14),
                      Text('🪙 ${list[0].coins} Coin', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Motivational Invite Banner
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🚀', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 10),
                      Text('Do\'stlaringizni taklif qiling!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Do\'stlaringiz bilan birgalikda o\'rganing va musobaqalashing! Har bir taklif qilgan do\'stingiz uchun +100 Coin bonus olasiz.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Do\'stlarga ulashish (+100 🪙)', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'YODGAR ilovasida so\'z yodlash bo\'yicha do\'stlik kodim: ${state.currentAccount.referralCode}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ulashish xabari nusxalandi! 📋'), duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ] else if (list.length >= 2) ...[
            // Podium Top 2 or 3
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPodiumUser(list[1], 2, Colors.blueGrey.shade400, 110, state),
                  _buildPodiumUser(list[0], 1, AppColors.gold, 140, state),
                  if (list.length > 2) _buildPodiumUser(list[2], 3, AppColors.bronze, 90, state),
                ],
              ),
            ),
          ] else ...[
            // Empty state
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Hozircha faol foydalanuvchilar mavjud emas.', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
          const SizedBox(height: 20),

          const Text('Barcha ishtirokchilar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          // User entries
          ...list.asMap().entries.map((entry) {
            final idx = entry.key;
            final user = entry.value;
            final isMe = user.id == state.currentAccount.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isMe ? AppColors.primaryBlue.withValues(alpha: 0.15) : null,
                border: isMe ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
                onTap: () {
                  final target = state.accounts.firstWhere((a) => a.id == user.id, orElse: () => state.currentAccount);
                  UserProfileDialog.show(context, target);
                },
                child: Row(
                  children: [
                    Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                    const SizedBox(width: 14),
                    CircleAvatar(child: Text(user.avatar, style: const TextStyle(fontSize: 20))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isMe ? AppColors.primaryBlue : null)),
                          Row(
                            children: [
                              Text('🔥 ${user.streak} kun', style: const TextStyle(fontSize: 12, color: AppColors.orangeFlame, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              Text('🪙 ${user.coins}', style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isMe)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user.isFollowing ? Colors.grey.shade400 : AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => state.toggleFollow(user.id),
                        child: Text(user.isFollowing ? 'Kuzatilmoqda' : 'Kuzatish', style: const TextStyle(fontSize: 11)),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(LeaderboardEntry user, int rank, Color color, double height, AppState state) {
    return InkWell(
      onTap: () {
        final target = state.accounts.firstWhere((a) => a.id == user.id, orElse: () => state.currentAccount);
        UserProfileDialog.show(context, target);
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.3),
            child: Text(user.avatar, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 6),
          Text(user.name.split(' ').first, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('🪙 ${user.coins}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            width: 74,
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  // 3. AI SOBIR & REAL TRANSLATOR TAB
  Widget _buildAiAndTranslatorTab(AppState state) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🤖 AI Sobir & Tarjimon'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sobir AI Chati'),
              Tab(text: 'Onlayn Tarjimon'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Sobir AI Chat
            Column(
              children: [
                // Quick suggested query prompts
                Container(
                  height: 44,
                  margin: const EdgeInsets.only(top: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildAiPromptChip('Present Simple qoidasi', state),
                      _buildAiPromptChip('Achievement so\'zi tahlili', state),
                      _buildAiPromptChip('Coin ishlash yo\'llari', state),
                      _buildAiPromptChip('Streak nima?', state),
                    ],
                  ),
                ),

                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.sobirChat.length,
                    itemBuilder: (context, index) {
                      final msg = state.sobirChat[index];
                      return Align(
                        alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          decoration: BoxDecoration(
                            color: msg.isMe ? AppColors.primaryBlue : Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: msg.isMe ? Colors.white70 : AppColors.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.text,
                                style: TextStyle(color: msg.isMe ? Colors.white : null, fontSize: 14, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // AI Chat Input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sobirInput,
                          decoration: InputDecoration(
                            hintText: 'Sobirdan so\'rang (masalan: "Knowledge so\'zi tahlili")...',
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.04),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                        icon: const Icon(Icons.send_rounded),
                        onPressed: () {
                          state.askSobir(_sobirInput.text);
                          _sobirInput.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // REAL ONLINE TRANSLATOR TAB
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Language swap row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLangDropdown(_fromLang, (val) => setState(() => _fromLang = val!)),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBlue, size: 28),
                            onPressed: () {
                              setState(() {
                                final tmp = _fromLang;
                                _fromLang = _toLang;
                                _toLang = tmp;
                              });
                            },
                          ),
                          _buildLangDropdown(_toLang, (val) => setState(() => _toLang = val!)),
                        ],
                      ),
                      const Divider(height: 24),

                      // Input Box with clear button
                      TextField(
                        controller: _translateInput,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tarjima qilmoqchi bo\'lgan so\'z yoki matnni kiriting...',
                          border: InputBorder.none,
                          suffixIcon: _translateInput.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () => setState(() => _translateInput.clear()),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isTranslating ? null : _performTranslation,
                          child: _isTranslating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('Tarjima Qilish 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Real Translated Result Card
                if (_translatedResult.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_toLang tarjimasi:',
                              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.primaryBlue),
                                  tooltip: 'Talaffuzini tinglash',
                                  onPressed: () {
                                    final langCode = _toLang == 'Inglizcha'
                                        ? 'en'
                                        : (_toLang == 'Ruscha' ? 'ru' : 'uz');
                                    TtsService.speak(_translatedResult, language: langCode);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primaryBlue),
                                  tooltip: 'Nusxa olish',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _translatedResult));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Nusxa olindi! 📋'), duration: Duration(milliseconds: 700)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _translatedResult,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiPromptChip(String prompt, AppState state) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
        side: const BorderSide(color: Colors.black12),
        label: Text(prompt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        onPressed: () => state.askSobir(prompt),
      ),
    );
  }

  Widget _buildLangDropdown(String current, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: current,
      underline: const SizedBox(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
      items: ['Inglizcha', 'Ruscha', 'O\'zbekcha'].map((l) {
        return DropdownMenuItem<String>(value: l, child: Text(l));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // 4. PROFIL TAB
  Widget _buildProfileTab(AppState state) {
    final acc = state.currentAccount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Sozlamalar',
            onPressed: () => _openSettingsDialog(state),
          ),
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            tooltip: 'Texnik Yordam',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SupportChatScreen()),
              );
            },
          ),
          if (state.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Admin VIP Banner (if Admin)
            if (state.isAdmin) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFFFE082), Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Text('👑', style: TextStyle(fontSize: 24)),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '👑 Admin Boshqaruv Markazi',
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Foydalanuvchilar, lug\'at, coinlar va xabarlar nazorati',
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.black87, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Telegram-style Profile Header Card
            GlassContainer(
              borderRadius: 28,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                    child: Text(acc.avatar, style: const TextStyle(fontSize: 44)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(acc.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      if (acc.role == 'admin') ...[
                        const SizedBox(width: 6),
                        const Text('👑', style: TextStyle(fontSize: 18)),
                      ],
                    ],
                  ),
                  Text(acc.email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),

                  // Rank Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'Daraja: ${acc.rank}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: acc.rankProgress,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keyingi ligagacha progress: ${(acc.rankProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Grid
            Row(
              children: [
                _buildStatBox('🔥 Streak', '${acc.streak} kun', AppColors.orangeFlame),
                const SizedBox(width: 12),
                _buildStatBox('🪙 Coinlar', '${acc.coins}', AppColors.gold, onTap: _openCoinShop),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatBox(
                  '📖 Yodlangan',
                  '${acc.learnedWordsCount} ta',
                  AppColors.primaryBlue,
                  onTap: () => _openLearnedWordsModal(state),
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  '🎯 Kunlik maqsad',
                  '${acc.dailyWordsLearned}/${acc.dailyLimit}',
                  AppColors.primaryGreen,
                  onTap: () => _openSettingsDialog(state),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Referral Program Card
            GlassContainer(
              borderRadius: 22,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('🎁', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Text('Do\'stlarni taklif qilish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('+100 COIN', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sizning maxsus taklif kodingiz. Do\'stlaringizga yuboring va har bir do\'stingiz uchun +100 Coin oling:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          acc.referralCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5, color: AppColors.primaryBlue),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: const Text('Nusxa olish', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: acc.referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Taklif kodi nusxalandi! 📋'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Enter friend's promo code
                  TextButton.icon(
                    icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                    label: const Text('Do\'stingizning kodi bormi? Kiriting (+100 🪙)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _openPromoCodeDialog(state),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Multi-account switcher on the same device
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Qurilmadagi Akkauntlar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                        label: const Text('Qo\'shish', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        onPressed: () => _openAddAccountDialog(state),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...state.switchableAccounts.map((a) {
                    final isCurrent = a.id == acc.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primaryBlue.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? AppColors.primaryBlue.withValues(alpha: 0.35) : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                            child: Text(a.avatar, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      a.name,
                                      style: TextStyle(
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (a.role == 'admin') ...[
                                      const SizedBox(width: 4),
                                      const Text('👑', style: TextStyle(fontSize: 12)),
                                    ],
                                  ],
                                ),
                                Text(a.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 14),
                                  SizedBox(width: 4),
                                  Text('Faol', style: TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(50, 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => state.switchAccount(a.id),
                              child: const Text('O\'tish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          if (a.role != 'admin') ...[
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(60, 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.delete_outline_rounded, size: 15),
                              label: const Text('Olib tashlash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _confirmRemoveAccount(state, a),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
                    title: const Text('Sozlamalar (Rejim, Ovoz, Til, Maqsad)'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _openSettingsDialog(state),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen),
                    title: const Text('Mening Yodlagan So\'zlarim'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _openLearnedWordsModal(state),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.gold),
                    title: const Text('Coin Do\'koni va Reklama'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: _openCoinShop,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: AppColors.primaryBlue),
                    title: const Text('Texnik Yordam (Tex Padeshka)'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SupportChatScreen()),
                      );
                    },
                  ),
                  if (state.isAdmin) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber),
                      title: const Text('👑 Admin Boshqaruv Markazi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                        );
                      },
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                    title: const Text('Ilova haqida'),
                    subtitle: const Text('Bosh Dasturchi: Inomjon • Versiya 2.0.0', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: _openAboutAppDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.red),
                    title: const Text('Chiqish (Tizimdan chiqish)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.red),
                    onTap: () => _handleLogout(state),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YODGAR v2.0 • Bosh Dasturchi: Inomjon 🚀',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- ABOUT APP DIALOG (DASTURCHI: INOMJON) ---
  void _openAboutAppDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.menu_book_rounded, size: 36, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YODGAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Versiya 2.0 (Rasmiy)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Text('👨‍💻', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bosh Dasturchi & Muallif:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Inomjon 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'YODGAR — bu Ingliz va Rus tillaridagi so\'zlarni tez va qiziqarli yodlash uchun yaratilgan mukammal ta\'lim ilovasi.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text(
              '• 10 ta interaktiv o\'yin\n• Sun\'iy intellekt "Sobir AI"\n• Real-time onlayn tarjimon\n• Tangalar (Coin) va reyting tizimi',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '© 2026 Inomjon. Barcha huquqlar himoyalangan.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  // --- SETTINGS DIALOG ---
  void _openSettingsDialog(AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.settings, color: AppColors.primaryBlue),
                        SizedBox(width: 8),
                        Text('⚙️ Ilova Sozlamalari', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ),
                const SizedBox(height: 16),

                // Day / Night Switch
                SwitchListTile(
                  title: const Text('Tungi / Kunduzgi rejim'),
                  subtitle: Text(state.isDayMode ? 'Kunduzgi yorug\' rejim' : 'Tungi qorong\'i rejim'),
                  secondary: Icon(state.isDayMode ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: state.isDayMode ? Colors.orange : Colors.purple),
                  value: !state.isDayMode,
                  onChanged: (val) {
                    state.toggleDayNight();
                    setModalState(() {});
                  },
                ),

                // Sound effects
                SwitchListTile(
                  title: const Text('Ovoz effektlari'),
                  subtitle: const Text('O\'yinlar va yutuqlar paytida ovozlar'),
                  secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primaryGreen),
                  value: state.soundEnabled,
                  onChanged: (val) {
                    state.toggleSound();
                    setModalState(() {});
                  },
                ),

                // Notifications
                SwitchListTile(
                  title: const Text('Bildirishnomalar'),
                  subtitle: const Text('Kunlik so\'z eslatmasi va streakni saqlash'),
                  secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primaryBlue),
                  value: state.notificationsEnabled,
                  onChanged: (val) {
                    state.toggleNotifications();
                    setModalState(() {});
                  },
                ),

                const Divider(),
                const SizedBox(height: 8),

                // Language
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ilova tili:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    DropdownButton<String>(
                      value: state.currentLanguage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'uz', child: Text('🇺🇿 O\'zbekcha')),
                        DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
                        DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          state.setLanguage(lang);
                          setModalState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Daily Limit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kunlik o\'rganish maqsadi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    DropdownButton<int>(
                      value: state.currentAccount.dailyLimit,
                      underline: const SizedBox(),
                      items: [5, 10, 20, 30, 50].map((lim) {
                        return DropdownMenuItem(value: lim, child: Text('$lim ta so\'z'));
                      }).toList(),
                      onChanged: (lim) {
                        if (lim != null) {
                          state.setDailyLimit(lim);
                          setModalState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                  title: const Text('Ilova haqida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Bosh Dasturchi: Inomjon • Versiya 2.0.0', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openAboutAppDialog();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- ADD ACCOUNT DIALOG ---
  void _openAddAccountDialog(AppState state) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedAv = '👩‍🎓';
    final avatars = ['👨‍🎓', '👩‍🎓', '🚀', '🦁', '🦅', '⚡', '🌟', '🎯'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('➕ Yangi Akkaunt Qo\'shish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ushbu qurilmaga boshqa o\'quvchi yoki o\'zingizning yangi akkauntingizni qo\'shing:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ism*')),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Elektron pochta*')),
                const SizedBox(height: 14),
                const Text('Avatar tanlang:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: avatars.map((av) {
                    final isSel = selectedAv == av;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedAv = av),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryBlue.withValues(alpha: 0.2) : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: isSel ? AppColors.primaryBlue : Colors.transparent, width: 2),
                        ),
                        child: Text(av, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Bekor qilish')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                state.registerUser(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  avatar: selectedAv,
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Yangi hisob "${nameCtrl.text.trim()}" qo\'shildi va faollashtirildi!'), backgroundColor: AppColors.primaryGreen),
                );
              },
              child: const Text('Qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveAccount(AppState state, UserAccount targetAcc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Akkauntni olib tashlash', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Haqiqatan ham "${targetAcc.name}" (${targetAcc.email}) hisobini ushbu qurilmadan olib tashlamoqchimisiz?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              state.deleteUser(targetAcc.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ "${targetAcc.name}" akkaunti qurilmadan olib tashlandi!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Olib tashlash', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LEARNED WORDS MODAL ---
  void _openLearnedWordsModal(AppState state) {
    final learned = state.learnedWords;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text('📖 Yodlangan so\'zlar (${learned.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 12),
              if (learned.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('Hozircha yodlangan so\'zlar yo\'q.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text(
                          '10 ta o\'yindan birini o\'ynab yoki lug\'atdan so\'zlarni o\'rganishni boshlang!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() => _currentTabIndex = 1); // Switch to games
                          },
                          child: const Text('O\'yinlar bo\'limiga o\'tish'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: learned.length,
                    itemBuilder: (context, idx) {
                      final w = learned[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                            child: const Icon(Icons.check, color: AppColors.primaryGreen, size: 20),
                          ),
                          title: Text('${w.english} — ${w.uzbek}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('🇷🇺 ${w.russian} • ${w.phonetic}\n"${w.exampleSentence}"'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGOUT DIALOG ---
  void _handleLogout(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Chiqish', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Haqiqatan ham hisobingizdan chiqmoqchimisiz? Qayta kirish uchun elektron pochta va parolingiz kerak bo\'ladi.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              state.logout();
            },
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
