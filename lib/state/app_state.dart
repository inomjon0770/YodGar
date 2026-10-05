import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../data/vocabulary_data.dart';
import '../services/translation_service.dart';

class AppState extends ChangeNotifier {
  // Storage Keys for complete persistence
  static const String _kAccounts = 'yodgar_user_accounts_v2';
  static const String _kCurrentAccountId = 'yodgar_current_account_id_v2';
  static const String _kIsAuthenticated = 'yodgar_is_authenticated_v2';
  static const String _kCompletedOnboarding = 'yodgar_completed_onboarding_v2';
  static const String _kIsDayMode = 'yodgar_is_day_mode_v2';
  static const String _kSoundEnabled = 'yodgar_sound_enabled_v2';
  static const String _kNotificationsEnabled = 'yodgar_notifications_enabled_v2';
  static const String _kLanguage = 'yodgar_language_v2';
  static const String _kWords = 'yodgar_words_v2';
  static const String _kStories = 'yodgar_stories_v2';
  static const String _kSobirChat = 'yodgar_sobir_chat_v2';
  static const String _kSupportChat = 'yodgar_support_chat_v2';
  static const String _kDirectMessages = 'yodgar_direct_messages_v2';

  // Fallback keys for seamless migration across updates
  static const String _kAccountsFallback = 'yodgar_user_accounts';
  static const List<String> _kAllAccountKeys = [
    'yodgar_user_accounts_v2',
    'yodgar_user_accounts',
    'yodgar_user_accounts_v1',
    'yodgar_accounts',
    'yodgar_users',
  ];

  // Mock user IDs that must be completely removed from the leaderboard and accounts
  static const Set<String> _kMockUserIds = {
    'user_madina',
    'user_jasur',
    'user_dilnoza',
    'user_shoxrux',
  };

  static UserAccount _createMasterAdmin() {
    return UserAccount(
      id: 'admin_master',
      name: 'YODGAR Admin',
      email: 'admin@yodgar.uz',
      avatar: '👑',
      role: 'admin',
      coins: 9999,
      streak: 30,
      learnedWordsCount: 500,
      dailyWordsLearned: 20,
      dailyLimit: 50,
      isPremium: true,
      activeFrame: 'gold',
    );
  }

  // Accounts list: Starts strictly with Master Admin. No fake/mock users!
  final List<UserAccount> _accounts = [
    _createMasterAdmin(),
  ];

  late UserAccount _currentAccount;

  // Initialization flag to prevent race conditions during startup
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // Authentication status
  bool _isAuthenticated = false;
  bool _completedOnboarding = false;

  // Admin explicit login state (Admin panelga faqat login-parol bilan kirish mumkin)
  bool _isAdminLoggedIn = false;
  bool get isAdminLoggedIn => _isAdminLoggedIn;

  // Day/Night theme
  bool _isDayMode = true;

  // Preferences
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  // App UI Language: 'uz', 'ru', 'en'
  String _currentLanguage = 'uz';

  // Words list
  List<VocabularyWord> _words = [];

  // Stories
  final List<StoryItem> _stories = [
    StoryItem(
      id: 's1',
      title: 'YODGAR 2.0',
      subtitle: 'Rasmiy yangilanish!',
      icon: '🎉',
      date: 'Bugun',
      content: 'Yodgar ilovasiga 10 ta interaktiv so\'z o\'yinlari, kuchaytirilgan AI Sobir va yangi onlayn tarjimon to\'liq ulandi!',
    ),
    StoryItem(
      id: 's2',
      title: 'Kun maslahati',
      subtitle: 'So\'z yodlash siri',
      icon: '💡',
      date: 'Kecha',
      content: 'So\'zlarni tezroq eslab qolish uchun har kuni 15 daqiqadan kam bo\'lmagan vaqtda "Word Match" va "Spelling Bee" o\'yinlarini o\'ynang.',
    ),
    StoryItem(
      id: 's3',
      title: 'Streak Musobaqasi',
      subtitle: '+500 Coin yuting!',
      icon: '🔥',
      date: '2 kun oldin',
      content: 'Ketma-ket 7 kun davomida kunlik limitni bajargan barcha o\'quvchilarga bepul 500 coin va Oltin nishon taqdim etiladi!',
    ),
  ];

  // Community posts
  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'p1',
      authorName: 'Madina Karimova',
      authorAvatar: '👩‍🎓',
      timeAgo: '15 daqiqa oldin',
      content: 'Bugun 20 ta yangi so\'zni "Flashcards" orqali yodladim! Streak 14 kunga yetdi! 🔥🏆',
      likesCount: 18,
      isLiked: false,
      comments: [
        CommunityComment(id: 'c1', authorName: 'Jasur Bek', text: 'Barakalla, zo\'r natija!', timeAgo: '10 daqiqa oldin'),
      ],
    ),
  ];

  // AI Sobir Chat Messages
  final List<ChatMessage> _sobirChat = [
    ChatMessage(
      id: 'm1',
      senderName: 'Sobir AI',
      isMe: false,
      isAiSobir: true,
      text: 'Assalomu alaykum! Men sizning aqlli yordamchingiz Sobirman. 🤖✨\nIngliz yoki Rus tilidagi so\'zlarning to\'liq ma\'nosi, talaffuzi, sinonimlari, grammatik qoidalar yoki YODGAR ilovasi bo\'yicha istalgan savolingizni bering!',
    ),
  ];

  // Support Chat Messages
  final List<ChatMessage> _supportChat = [
    ChatMessage(
      id: 's_m1',
      senderName: 'Yodgar Texnik Qo\'llab-quvvatlash',
      isMe: false,
      text: 'Assalomu alaykum! YODGAR texnik yordam markaziga xush kelibsiz. Qanday savol yoki taklifingiz bor?',
    ),
  ];

  // Coin packages (Keep buying as requested: "sotib olish oshanday turorsin")
  final List<CoinPackage> coinPackages = [
    CoinPackage(id: 'cp1', title: 'Boshlang\'ich', coins: 250, priceUzs: 10000, bonus: '+0%'),
    CoinPackage(id: 'cp2', title: 'Mashhur', coins: 750, priceUzs: 25000, bonus: '+20%', isPopular: true),
    CoinPackage(id: 'cp3', title: 'Chempion', coins: 2000, priceUzs: 60000, bonus: '+45%'),
    CoinPackage(id: 'cp4', title: 'VIP Cheksiz', coins: 5000, priceUzs: 120000, bonus: '+70%'),
  ];

  // Shop Perks for Spending Coins (Coin sarflash imtiyozlari)
  final List<ShopPerk> shopPerks = [
    const ShopPerk(
      id: 'no_ads',
      title: 'Reklamasiz Rejim (7 kun)',
      description: 'Barcha reklamalarni butunlay o\'chiradi va darslarni to\'xtovsiz o\'rganish imkonini beradi.',
      icon: '🚫',
      coinPrice: 30,
      category: 'utility',
    ),
    const ShopPerk(
      id: 'streak_freeze',
      title: 'Streak Muzlatgich (1 dona)',
      description: 'Agar 1 kun dars qilishga ulgurmay qolsangiz, streakingiz o\'chib ketishdan himoyalanadi.',
      icon: '🧊',
      coinPrice: 20,
      category: 'utility',
    ),
    const ShopPerk(
      id: 'double_coins',
      title: '2x Tanga Ko\'paytirgich',
      description: 'Keyingi barcha o\'yinlar va darslardan 2 barobar ko\'proq tanga (coin) olasiz.',
      icon: '⚡',
      coinPrice: 15,
      category: 'booster',
    ),
    const ShopPerk(
      id: 'frame_gold',
      title: 'VIP Oltin Profil Ramkasi',
      description: 'Profilingiz va reyting jadvalida ismingiz atrofida yaltiroq oltin VIP ramka paydo bo\'ladi.',
      icon: '👑',
      coinPrice: 35,
      category: 'cosmetic',
    ),
    const ShopPerk(
      id: 'avatar_duo',
      title: 'Duolingo Boyqush Avatari',
      description: 'Profilingiz uchun afsonaviy boyqush (🦉) maxsus avatari ochiladi.',
      icon: '🦉',
      coinPrice: 25,
      category: 'cosmetic',
    ),
    const ShopPerk(
      id: 'sobir_pro',
      title: 'AI Sobir Cheksiz Maslahat',
      description: 'Sobir AI bilan cheksiz grammatik va IELTS darslarini bevosita o\'tkazing.',
      icon: '🤖',
      coinPrice: 10,
      category: 'utility',
    ),
  ];

  // Direct Messages for Mutual Follower Chats
  final List<DirectMessage> _directMessages = [];

  AppState() {
    _currentAccount = _accounts.first;
    _words = List.from(initialVocabulary);
    _initDayNight();
    _loadFromPrefs();
  }

  void _initDayNight() {
    final hour = DateTime.now().hour;
    _isDayMode = (hour >= 6 && hour < 19);
  }

  // --- PERSISTENCE: LOAD FROM PREFERENCES (WITH MIGRATION AND ANTI-WIPE PROTECTION) ---
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Accounts: Check all historical storage keys so users never get lost across updates
      final List<UserAccount> loaded = [];
      for (final key in _kAllAccountKeys) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          try {
            final List decoded = jsonDecode(jsonStr);
            for (final item in decoded) {
              final acc = UserAccount.fromJson(item);
              // Strictly remove any legacy mock user accounts
              if (!_kMockUserIds.contains(acc.id)) {
                if (!loaded.any((existing) => existing.id == acc.id || (existing.email.isNotEmpty && existing.email.toLowerCase() == acc.email.toLowerCase()))) {
                  loaded.add(acc);
                }
              }
            }
          } catch (e) {
            debugPrint('Error parsing accounts from key $key: $e');
          }
        }
      }

      if (loaded.isNotEmpty) {
        // Merge loaded accounts safely without clearing freshly created in-memory accounts
        for (final acc in loaded) {
          final idx = _accounts.indexWhere((a) => a.id == acc.id || (a.email.isNotEmpty && a.email.toLowerCase() == acc.email.toLowerCase()));
          if (idx != -1) {
            // Update with persisted data if present
            _accounts[idx] = acc;
          } else {
            _accounts.add(acc);
          }
        }
      }

      // Always ensure master admin exists and is securely defined
      if (!_accounts.any((a) => a.id == 'admin_master' && a.role == 'admin')) {
        _accounts.insert(0, _createMasterAdmin());
      }

      // Clean up following/followers references to mock users across all accounts
      for (final acc in _accounts) {
        acc.followingUserIds.removeWhere((id) => _kMockUserIds.contains(id));
        acc.followersUserIds.removeWhere((id) => _kMockUserIds.contains(id));
      }

      // 2. Auth & Onboarding Status
      if (prefs.containsKey(_kIsAuthenticated)) {
        _isAuthenticated = prefs.getBool(_kIsAuthenticated) ?? false;
      } else if (prefs.containsKey('yodgar_is_authenticated')) {
        _isAuthenticated = prefs.getBool('yodgar_is_authenticated') ?? false;
      }

      if (prefs.containsKey(_kCompletedOnboarding)) {
        _completedOnboarding = prefs.getBool(_kCompletedOnboarding) ?? false;
      } else if (prefs.containsKey('yodgar_completed_onboarding')) {
        _completedOnboarding = prefs.getBool('yodgar_completed_onboarding') ?? false;
      }

      // 3. Current Account Selection
      final regularUsers = _accounts.where((a) => a.role == 'user').toList();
      if (regularUsers.isEmpty) {
        // If there are no regular user accounts on the device, never auto-authenticate to admin!
        _isAuthenticated = false;
        _isAdminLoggedIn = false;
        _currentAccount = _accounts.firstWhere((a) => a.id == 'admin_master', orElse: () => _createMasterAdmin());
      } else {
        final currId = prefs.getString(_kCurrentAccountId) ?? prefs.getString('yodgar_current_account_id');
        UserAccount? target;
        if (currId != null && !_kMockUserIds.contains(currId)) {
          target = _accounts.where((a) => a.id == currId).firstOrNull;
        }

        if (target != null && target.role == 'user') {
          _currentAccount = target;
        } else {
          // Fallback to the first regular user account and reset admin flag
          _currentAccount = regularUsers.first;
          _isAdminLoggedIn = false;
        }
      }

      if (prefs.containsKey(_kIsDayMode)) {
        _isDayMode = prefs.getBool(_kIsDayMode) ?? _isDayMode;
      }
      if (prefs.containsKey(_kSoundEnabled)) {
        _soundEnabled = prefs.getBool(_kSoundEnabled) ?? true;
      }
      if (prefs.containsKey(_kNotificationsEnabled)) {
        _notificationsEnabled = prefs.getBool(_kNotificationsEnabled) ?? true;
      }
      if (prefs.containsKey(_kLanguage)) {
        _currentLanguage = prefs.getString(_kLanguage) ?? 'uz';
      }

      // 4. Words (Learned words, Custom words added by user/admin)
      final wordsJson = prefs.getString(_kWords) ?? prefs.getString('yodgar_words');
      if (wordsJson != null && wordsJson.isNotEmpty) {
        final List decoded = jsonDecode(wordsJson);
        final loadedWords = decoded.map((e) => VocabularyWord.fromJson(e)).toList();
        if (loadedWords.isNotEmpty) {
          _words = loadedWords;
        }
      }

      // 5. Stories
      final storiesJson = prefs.getString(_kStories) ?? prefs.getString('yodgar_stories');
      if (storiesJson != null && storiesJson.isNotEmpty) {
        final List decoded = jsonDecode(storiesJson);
        final loadedStories = decoded.map((e) => StoryItem.fromJson(e)).toList();
        if (loadedStories.isNotEmpty) {
          _stories.clear();
          _stories.addAll(loadedStories);
        }
      }

      // 6. AI Sobir Chat
      final sobirJson = prefs.getString(_kSobirChat) ?? prefs.getString('yodgar_sobir_chat');
      if (sobirJson != null && sobirJson.isNotEmpty) {
        final List decoded = jsonDecode(sobirJson);
        final loadedChat = decoded.map((e) => ChatMessage.fromJson(e)).toList();
        if (loadedChat.isNotEmpty) {
          _sobirChat.clear();
          _sobirChat.addAll(loadedChat);
        }
      }

      // 7. Support Chat
      final supportJson = prefs.getString(_kSupportChat) ?? prefs.getString('yodgar_support_chat');
      if (supportJson != null && supportJson.isNotEmpty) {
        final List decoded = jsonDecode(supportJson);
        final loadedSupport = decoded.map((e) => ChatMessage.fromJson(e)).toList();
        if (loadedSupport.isNotEmpty) {
          _supportChat.clear();
          _supportChat.addAll(loadedSupport);
        }
      }

      // 8. Direct Messages (Strip any mock messages)
      final dmJson = prefs.getString(_kDirectMessages) ?? prefs.getString('yodgar_direct_messages');
      if (dmJson != null && dmJson.isNotEmpty) {
        final List decoded = jsonDecode(dmJson);
        final loadedDm = decoded.map((e) => DirectMessage.fromJson(e)).toList();
        loadedDm.removeWhere((m) => _kMockUserIds.contains(m.senderId) || _kMockUserIds.contains(m.receiverId));
        if (loadedDm.isNotEmpty) {
          _directMessages.clear();
          _directMessages.addAll(loadedDm);
        }
      }

      _isLoaded = true;
      notifyListeners();

      // Immediately write back sanitized & migrated data to both permanent keys
      if (_pendingSave) {
        _pendingSave = false;
      }
      _saveToPrefs();
    } catch (e) {
      debugPrint('SharedPreferences load error: $e');
      _isLoaded = true;
      notifyListeners();
      if (_pendingSave) {
        _pendingSave = false;
        _saveToPrefs();
      }
    }
  }

  bool _pendingSave = false;

  // --- PERSISTENCE: SAVE TO PREFERENCES ---
  Future<void> _saveToPrefs() async {
    // CRITICAL ANTI-WIPE GUARD: Never save before initial load has completed!
    if (!_isLoaded) {
      _pendingSave = true;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsData = jsonEncode(_accounts.map((a) => a.toJson()).toList());
      // Save to primary key and fallback key for complete reliability
      await prefs.setString(_kAccounts, accountsData);
      await prefs.setString(_kAccountsFallback, accountsData);

      await prefs.setString(_kCurrentAccountId, _currentAccount.id);
      await prefs.setBool(_kIsAuthenticated, _isAuthenticated);
      await prefs.setBool(_kCompletedOnboarding, _completedOnboarding);
      await prefs.setBool(_kIsDayMode, _isDayMode);
      await prefs.setBool(_kSoundEnabled, _soundEnabled);
      await prefs.setBool(_kNotificationsEnabled, _notificationsEnabled);
      await prefs.setString(_kLanguage, _currentLanguage);
      await prefs.setString(_kWords, jsonEncode(_words.map((w) => w.toJson()).toList()));
      await prefs.setString(_kStories, jsonEncode(_stories.map((s) => s.toJson()).toList()));
      await prefs.setString(_kSobirChat, jsonEncode(_sobirChat.map((m) => m.toJson()).toList()));
      await prefs.setString(_kSupportChat, jsonEncode(_supportChat.map((m) => m.toJson()).toList()));
      await prefs.setString(_kDirectMessages, jsonEncode(_directMessages.map((m) => m.toJson()).toList()));
    } catch (e) {
      debugPrint('SharedPreferences save error: $e');
    }
  }

  // Getters
  List<UserAccount> get accounts => _accounts;

  // Safe Switchable accounts: non-admins CANNOT see or switch to admin_master!
  List<UserAccount> get switchableAccounts {
    if (isAdmin) {
      return _accounts;
    }
    return _accounts.where((a) => a.role == 'user').toList();
  }

  UserAccount get currentAccount => _currentAccount;
  bool get isAuthenticated => _isAuthenticated;
  bool get completedOnboarding => _completedOnboarding;
  bool get isDayMode => _isDayMode;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get currentLanguage => _currentLanguage;
  List<VocabularyWord> get words => _words;
  List<StoryItem> get stories => _stories;
  List<CommunityPost> get posts => _posts;

  // Dynamically computed leaderboard: only real registered users, sorted by coins
  List<LeaderboardEntry> get leaderboard {
    final users = _accounts.where((a) => a.role == 'user').toList();
    users.sort((a, b) {
      final cmp = b.coins.compareTo(a.coins);
      if (cmp != 0) return cmp;
      return b.learnedWordsCount.compareTo(a.learnedWordsCount);
    });

    return users.map((u) {
      final isMe = u.id == _currentAccount.id;
      return LeaderboardEntry(
        id: u.id,
        name: isMe ? '${u.name} (Siz)' : u.name,
        avatar: u.avatar,
        coins: u.coins,
        streak: u.streak,
        rank: u.rank,
        wordsLearned: u.learnedWordsCount,
        isFollowing: _currentAccount.followingUserIds.contains(u.id),
      );
    }).toList();
  }

  // Word of the Day (Kun so'zi)
  VocabularyWord get wordOfTheDay {
    if (_words.isEmpty) {
      return VocabularyWord(
        id: 'w_fallback',
        english: 'Perseverance',
        russian: 'Настойчивость',
        uzbek: 'Matonat, sabr-toqat',
        phonetic: '/ˌpɜː.sɪˈvɪə.rəns/',
        partOfSpeech: 'noun',
        definitionUz: 'Qiyinchiliklarga qaramay maqsad sari intilish fazilati.',
        definitionRu: 'Упорство в достижении цели несмотря на трудности.',
        exampleSentence: 'Success requires patience and perseverance.',
        exampleTranslation: 'Muvaffaqiyat sabr va matonatni talab qiladi.',
        category: 'B2',
        isLearned: false,
      );
    }
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _words[dayOfYear.abs() % _words.length];
  }

  // Favorite / Bookmark words
  List<VocabularyWord> get favoriteWords =>
      _words.where((w) => _currentAccount.favoriteWordIds.contains(w.id)).toList();

  bool isFavoriteWord(String wordId) =>
      _currentAccount.favoriteWordIds.contains(wordId);

  void toggleFavoriteWord(String wordId) {
    if (_currentAccount.favoriteWordIds.contains(wordId)) {
      _currentAccount.favoriteWordIds.remove(wordId);
    } else {
      _currentAccount.favoriteWordIds.add(wordId);
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Weekly Streak Claim System (1 dan 10 gacha muvozanatli, Max 10 tanga)
  static const Map<int, int> weeklyStreakRewards = {
    1: 2,
    2: 3,
    3: 4,
    4: 5,
    5: 6,
    6: 8,
    7: 10,
  };

  bool canClaimWeeklyReward(int day) {
    return day <= _currentAccount.weeklyStreak &&
        !_currentAccount.claimedWeeklyRewards.contains(day);
  }

  bool isWeeklyRewardClaimed(int day) {
    return _currentAccount.claimedWeeklyRewards.contains(day);
  }

  bool claimWeeklyReward(int day) {
    if (!canClaimWeeklyReward(day)) return false;
    final reward = weeklyStreakRewards[day] ?? 10;
    _currentAccount.claimedWeeklyRewards.add(day);
    addCoins(reward, '$day-kunlik streak mukofoti (+$reward 🪙)');
    _saveToPrefs();
    return true;
  }

  // Referral code logic (+100 coin bonus)
  bool applyReferralCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty || clean == _currentAccount.referralCode.toUpperCase()) {
      return false;
    }
    final exists = _accounts.any((a) => a.referralCode.toUpperCase() == clean);
    if (exists || clean == 'INOMJON2026' || clean.startsWith('YODGAR')) {
      addCoins(100, 'Do\'st taklif qilish bonusi (+100 🪙)');
      _saveToPrefs();
      return true;
    }
    return false;
  }

  List<ChatMessage> get sobirChat => _sobirChat;
  List<ChatMessage> get supportChat => _supportChat;
  bool get isAdmin => _currentAccount.role == 'admin' && _isAdminLoggedIn;

  // Learned words for current user
  List<VocabularyWord> get learnedWords => _words.where((w) => w.isLearned).toList();

  void completeOnboarding() {
    _completedOnboarding = true;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleDayNight() {
    _isDayMode = !_isDayMode;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveToPrefs();
    notifyListeners();
  }

  void setLanguage(String lang) {
    _currentLanguage = lang;
    _saveToPrefs();
    notifyListeners();
  }

  void setDailyLimit(int limit) {
    _currentAccount.dailyLimit = limit;
    _saveToPrefs();
    notifyListeners();
  }

  // Account switching - Strictly prevents non-admins from switching to admin_master
  void switchAccount(String id) {
    final target = _accounts.firstWhere((a) => a.id == id, orElse: () => _accounts.first);
    if (target.role == 'admin' && !_isAdminLoggedIn) {
      // Security check: cannot switch into admin role without password login
      return;
    }
    if (target.role != 'admin') {
      _isAdminLoggedIn = false;
    }
    _currentAccount.lastActiveDate = DateTime.now();
    _currentAccount = target;
    _currentAccount.lastActiveDate = DateTime.now();
    _isAuthenticated = true;
    _saveToPrefs();
    notifyListeners();
  }

  // User Registration - Strictly creates 'user' role with 50 Welcome Coins bonus
  // Rejects any attempt to register as admin
  UserAccount registerUser({
    required String name,
    required String email,
    String? phoneNumber,
    String avatar = '👨‍🎓',
    String targetLanguage = 'en',
    int dailyLimit = 20,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail == 'admin@yodgar.uz' || cleanEmail == 'admin') {
      throw Exception('Admin hisobiga ro\'yxatdan o\'tish orqali kirib bo\'lmaydi! Faqat maxsus login va parol orqali kiring.');
    }

    final newAcc = UserAccount(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'Foydalanuvchi',
      email: cleanEmail,
      phoneNumber: phoneNumber,
      avatar: avatar,
      targetLanguage: targetLanguage,
      role: 'user', // STRICTLY USER ROLE
      coins: 50, // 50 Welcome Coins bonus!
      streak: 1,
      weeklyStreak: 1,
      claimedWeeklyRewards: [],
      learnedWordsCount: 0,
      dailyWordsLearned: 0,
      dailyLimit: dailyLimit,
    );

    _accounts.add(newAcc);
    _currentAccount = newAcc;
    _isAdminLoggedIn = false;
    _isAuthenticated = true;

    _saveToPrefs();
    notifyListeners();
    return newAcc;
  }

  // Login or Register via Firebase (Google Sign-In / Phone SMS)
  // Strictly enforces 'user' role. Admin CANNOT be accessed via Firebase/Google/SMS
  UserAccount loginWithFirebaseUser({
    required String uid,
    required String name,
    required String email,
    String? phoneNumber,
    String avatar = '👨‍🎓',
    String targetLanguage = 'en',
    int dailyLimit = 20,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    
    // Look for existing registered USER account (never match admin_master via Firebase)
    final existing = _accounts.where((a) =>
        a.role == 'user' && (
          (cleanEmail.isNotEmpty && a.email.toLowerCase() == cleanEmail) ||
          (phoneNumber != null && phoneNumber.isNotEmpty && a.phoneNumber == phoneNumber) ||
          a.id == uid
        )
    ).firstOrNull;

    if (existing != null) {
      _currentAccount = existing;
      _isAdminLoggedIn = false;
      _isAuthenticated = true;
      _saveToPrefs();
      notifyListeners();
      return existing;
    }

    final newAcc = UserAccount(
      id: uid.isNotEmpty ? uid : 'acc_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'Foydalanuvchi',
      email: cleanEmail,
      phoneNumber: phoneNumber,
      avatar: avatar,
      targetLanguage: targetLanguage,
      role: 'user', // STRICTLY USER ROLE
      coins: 50, // 50 Welcome Coins bonus!
      streak: 1,
      weeklyStreak: 1,
      claimedWeeklyRewards: [],
      learnedWordsCount: 0,
      dailyWordsLearned: 0,
      dailyLimit: dailyLimit,
    );

    _accounts.add(newAcc);
    _currentAccount = newAcc;
    _isAdminLoggedIn = false;
    _isAuthenticated = true;
    _saveToPrefs();
    notifyListeners();
    return newAcc;
  }

  // Login handler: The ONLY gate to Admin panel is email & password
  bool login({required String email, required String password}) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    // Check Single Master Admin Login (admin@yodgar.uz / admin or admin2026)
    if (cleanEmail == 'admin@yodgar.uz' && (cleanPass == 'admin' || cleanPass == 'admin2026')) {
      final adminAcc = _accounts.firstWhere(
        (a) => a.role == 'admin',
        orElse: () {
          final m = _createMasterAdmin();
          _accounts.insert(0, m);
          return m;
        },
      );
      _currentAccount = adminAcc;
      _isAdminLoggedIn = true;
      _isAuthenticated = true;
      _saveToPrefs();
      notifyListeners();
      return true;
    }

    // Check existing registered user
    final user = _accounts.where((a) => a.role == 'user').firstWhere(
      (a) => a.email.toLowerCase() == cleanEmail,
      orElse: () => UserAccount(id: '', name: '', email: ''),
    );

    if (user.id.isNotEmpty) {
      _currentAccount = user;
      _isAdminLoggedIn = false;
      _isAuthenticated = true;
      _saveToPrefs();
      notifyListeners();
      return true;
    }

    return false;
  }

  // Reset password simulation
  bool resetPassword(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final user = _accounts.where((a) => a.email.toLowerCase() == cleanEmail).firstOrNull;
    if (user != null || cleanEmail.contains('@')) {
      return true;
    }
    return false;
  }

  // Logout
  void logout() {
    _isAuthenticated = false;
    _isAdminLoggedIn = false;
    final remainingUsers = _accounts.where((a) => a.role == 'user').toList();
    if (remainingUsers.isNotEmpty) {
      _currentAccount = remainingUsers.first;
    } else {
      _currentAccount = _accounts.firstWhere((a) => a.id == 'admin_master', orElse: () => _createMasterAdmin());
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Quick Google Sign-in simulation (Strictly User Role)
  void loginWithGoogle() {
    _isAdminLoggedIn = false;
    final existing = _accounts.where((a) => a.email == 'google_user@gmail.com').firstOrNull;
    if (existing != null) {
      _currentAccount = existing;
      _isAuthenticated = true;
      _saveToPrefs();
      notifyListeners();
    } else {
      registerUser(
        name: 'Google Foydalanuvchisi',
        email: 'google_user@gmail.com',
        avatar: '🌐',
      );
    }
  }

  // Coins management
  void addCoins(int amount, String reason) {
    _currentAccount.coins += amount;
    _saveToPrefs();
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (_currentAccount.coins >= amount) {
      _currentAccount.coins -= amount;
      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Admin User Management
  void updateUserCoins(String userId, int delta) {
    final user = _accounts.firstWhere((a) => a.id == userId, orElse: () => _currentAccount);
    user.coins = (user.coins + delta).clamp(0, 999999);
    _saveToPrefs();
    notifyListeners();
  }

  void deleteUser(String userId) {
    if (userId == 'admin_master') return; // Cannot delete master admin
    _accounts.removeWhere((a) => a.id == userId);

    final remainingUsers = _accounts.where((a) => a.role == 'user').toList();
    if (remainingUsers.isEmpty) {
      // Barcha akkauntlar o'chirildi / qurilmadan chiqib ketildi:
      // Admin panelga emas, to'g'ridan-to'g'ri kirish / ro'yxatdan o'tish oynasiga tushadi!
      _isAuthenticated = false;
      _isAdminLoggedIn = false;
      _currentAccount = _accounts.firstWhere((a) => a.id == 'admin_master', orElse: () => _createMasterAdmin());
    } else if (_currentAccount.id == userId) {
      _currentAccount = remainingUsers.first;
      _isAdminLoggedIn = false;
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Simulated Ad Watch (Balanced to 5-10 coins max)
  Future<void> watchAdForCoins(Function(int earned) onComplete) async {
    await Future.delayed(const Duration(seconds: 3));
    final earned = _currentAccount.hasDoubleCoins ? 10 : 5;
    addCoins(earned, 'Reklama tomoshasi (+$earned 🪙)');
    onComplete(earned);
  }

  // Buy coin package (Keep buying options as requested: "sotib olish oshanday turorsin")
  void buyCoinPackage(CoinPackage package) {
    addCoins(package.coins, 'Coin paketi sotib olindi: ${package.title}');
  }

  // Buy perk with coins (Coin sarflash)
  bool buyPerk(ShopPerk perk) {
    if (!spendCoins(perk.coinPrice)) return false;

    switch (perk.id) {
      case 'no_ads':
        _currentAccount.hasNoAds = true;
        break;
      case 'streak_freeze':
        _currentAccount.streakFreezes += 1;
        break;
      case 'double_coins':
        _currentAccount.hasDoubleCoins = true;
        break;
      case 'frame_gold':
        _currentAccount.activeFrame = 'gold';
        break;
      case 'avatar_duo':
        if (!_currentAccount.unlockedAvatars.contains('🦉')) {
          _currentAccount.unlockedAvatars.add('🦉');
        }
        _currentAccount.avatar = '🦉';
        break;
      case 'sobir_pro':
        _currentAccount.isPremium = true;
        break;
    }
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  // Word learning & streak (Balanced: +2 coin, +4 if double coins active, max 10)
  void markWordLearned(VocabularyWord word) {
    if (!word.isLearned) {
      word.isLearned = true;
      _currentAccount.learnedWordsCount++;
      _currentAccount.dailyWordsLearned++;
      final earned = _currentAccount.hasDoubleCoins ? 4 : 2;
      addCoins(earned, 'So\'z o\'rganildi: ${word.english} (+$earned 🪙)');
      _saveToPrefs();
      notifyListeners();
    }
  }

  // User submits new word (Balanced: +5 coins)
  bool addCustomWord({
    required String english,
    required String russian,
    required String uzbek,
    required String definitionUz,
    required String exampleSentence,
    required String category,
  }) {
    if (english.trim().isEmpty || uzbek.trim().isEmpty) return false;

    final exists = _words.any((w) => w.english.toLowerCase() == english.trim().toLowerCase());
    if (exists) return false;

    final newWord = VocabularyWord(
      id: 'w_custom_${DateTime.now().millisecondsSinceEpoch}',
      english: english.trim(),
      russian: russian.trim().isEmpty ? english.trim() : russian.trim(),
      uzbek: uzbek.trim(),
      phonetic: '/${english.trim().toLowerCase()}/',
      partOfSpeech: 'noun',
      definitionUz: definitionUz.trim(),
      definitionRu: 'Пользовательское слово',
      exampleSentence: exampleSentence.trim(),
      exampleTranslation: 'Misol tarjimasi',
      category: category,
      isLearned: false,
      isCustom: true,
      approvedByAdmin: isAdmin,
    );

    _words.insert(0, newWord);
    addCoins(5, 'Yangi so\'z qo\'shildi (+5 🪙)');
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  void approveWord(String id) {
    final word = _words.firstWhere((w) => w.id == id);
    word.approvedByAdmin = true;
    _saveToPrefs();
    notifyListeners();
  }

  void updateWord(VocabularyWord updatedWord) {
    final idx = _words.indexWhere((w) => w.id == updatedWord.id);
    if (idx != -1) {
      _words[idx] = updatedWord;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteWord(String id) {
    _words.removeWhere((w) => w.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Add Story by Admin
  void addStory({required String title, required String subtitle, required String icon, required String content}) {
    _stories.insert(
      0,
      StoryItem(
        id: 's_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: subtitle,
        icon: icon,
        date: 'Hozirgina',
        content: content,
      ),
    );
    _saveToPrefs();
    notifyListeners();
  }

  void deleteStory(String id) {
    _stories.removeWhere((s) => s.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Follow / Unfollow with mutual follow reciprocity
  void toggleFollow(String userId) {
    final other = _accounts.where((a) => a.id == userId).firstOrNull;
    if (_currentAccount.followingUserIds.contains(userId)) {
      _currentAccount.followingUserIds.remove(userId);
      if (other != null) {
        other.followersUserIds.remove(_currentAccount.id);
      }
    } else {
      _currentAccount.followingUserIds.add(userId);
      if (other != null) {
        if (!other.followersUserIds.contains(_currentAccount.id)) {
          other.followersUserIds.add(_currentAccount.id);
        }
        // Reciprocal follow: When user follows a fellow peer learner, peer follows back so mutual chat unlocks!
        if (!other.followingUserIds.contains(_currentAccount.id)) {
          other.followingUserIds.add(_currentAccount.id);
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Check if two users follow each other
  bool isMutualFollow(String otherUserId) {
    final other = _accounts.where((a) => a.id == otherUserId).firstOrNull;
    if (other == null) return false;
    final iFollowThem = _currentAccount.followingUserIds.contains(otherUserId);
    final theyFollowMe = other.followingUserIds.contains(_currentAccount.id);
    return iFollowThem && theyFollowMe;
  }

  // Get direct messages with a specific user
  List<DirectMessage> getDirectMessagesWith(String otherUserId) {
    return _directMessages.where((m) =>
      (m.senderId == _currentAccount.id && m.receiverId == otherUserId) ||
      (m.senderId == otherUserId && m.receiverId == _currentAccount.id)
    ).toList();
  }

  // Send 1-on-1 direct message: STRICTLY only the real account owner speaks, NO AI!
  void sendDirectMessage(String toUserId, String text) {
    if (text.trim().isEmpty) return;
    _currentAccount.lastActiveDate = DateTime.now();

    final newMsg = DirectMessage(
      id: 'dm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentAccount.id,
      senderName: _currentAccount.name,
      receiverId: toUserId,
      text: text.trim(),
      isRead: false,
    );
    _directMessages.add(newMsg);
    _saveToPrefs();
    notifyListeners();
  }

  // Mark all unread messages received from a specific peer as read (✓✓ seen)
  void markMessagesAsRead(String peerUserId) {
    bool hasChanges = false;
    for (final m in _directMessages) {
      if (m.receiverId == _currentAccount.id && m.senderId == peerUserId && !m.isRead) {
        m.isRead = true;
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _saveToPrefs();
      notifyListeners();
    }
  }

  // Get unread messages count received from a specific peer
  int getUnreadCountFrom(String peerUserId) {
    return _directMessages.where((m) =>
      m.receiverId == _currentAccount.id && m.senderId == peerUserId && !m.isRead
    ).length;
  }

  // Mutual friends list
  List<UserAccount> get mutualFriends {
    return _accounts.where((a) => a.id != _currentAccount.id && a.role == 'user' && isMutualFollow(a.id)).toList();
  }

  // All discoverable fellow learners
  List<UserAccount> get allDiscoverUsers {
    return _accounts.where((a) => a.id != _currentAccount.id && a.role == 'user').toList();
  }

  // Like Community Post
  void toggleLikePost(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    post.isLiked = !post.isLiked;
    post.likesCount += post.isLiked ? 1 : -1;
    notifyListeners();
  }

  void addCommentToPost(String postId, String commentText) {
    final post = _posts.firstWhere((p) => p.id == postId);
    post.comments.add(
      CommunityComment(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        authorName: _currentAccount.name,
        text: commentText,
        timeAgo: 'Hozirgina',
      ),
    );
    notifyListeners();
  }

  // Real-time Translator method
  Future<String> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    return await TranslationService.translate(
      text: text,
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
    );
  }

  // Enhanced AI Sobir engine
  void askSobir(String query) {
    if (query.trim().isEmpty) return;

    _sobirChat.add(ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: _currentAccount.name,
      isMe: true,
      text: query,
    ));
    _saveToPrefs();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      final answer = _generateEnhancedSobirResponse(query);
      _sobirChat.add(ChatMessage(
        id: 'm_ai_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Sobir AI',
        isMe: false,
        isAiSobir: true,
        text: answer,
      ));
      _saveToPrefs();
      notifyListeners();
    });
  }

  String _generateEnhancedSobirResponse(String q) {
    final lower = q.toLowerCase().trim();

    for (final w in _words) {
      if (lower.contains(w.english.toLowerCase()) || lower.contains(w.uzbek.toLowerCase())) {
        return '''📖 "${w.english}" so'zi tahlili:

🔊 Talaffuzi: ${w.phonetic}
🇺🇿 O'zbekcha: ${w.uzbek}
🇷🇺 Ruscha: ${w.russian}
📚 So'z turkumi: ${w.partOfSpeech.toUpperCase()}
🏷️ Darajasi: ${w.category} (CEFR)

💡 Ta'rifi:
${w.definitionUz}

📝 Misol gap:
• "${w.exampleSentence}"
  Tarjimasi: ${w.exampleTranslation}

✨ Maslahat: Ushbu so'zni mustahkamlash uchun "Flashcards" yoki "Spelling Bee" o'yinida mashq qiling! 🚀''';
      }
    }

    if (lower.contains('salom') || lower.contains('qalaysan') || lower.contains('assalomu') || lower.contains('hello') || lower.contains('hi')) {
      return '''Assalomu alaykum! Men Sobirman — YODGAR sun'iy intellekt tili murabbiyingiz. 🤖🎓

Men quyidagilarda sizga yordam bera olaman:
1. Istalgan so'zning chuqur tahlili va tarjimasi (Ingliz, Rus, O'zbek).
2. Grammatika qoidalari va zamonlar tushuntirilishi.
3. IELTS va CEFR so'zlari bo'yicha maslahatlar.
4. YODGAR ilovasidagi 10 ta o'yin va tangalar (coin) tizimi.

Sizga qaysi so'z yoki mavzu bo'yicha yordam beray?''';
    }

    if (lower.contains('present simple') || lower.contains('oddiy hozirgi')) {
      return '''📘 Present Simple (Oddiy hozirgi zamon):

Qachon ishlatiladi?
• Har kuni takrorlanadigan odatiy ish-harakatlar.
• Umumiy haqiqatlar (masalan: "The sun rises in the east").

Formulasi:
• I / You / We / They + V1 (fe'l asosi): "I study English every day."
• He / She / It + V1 + s/es: "He studies Russian every day."

Inkor shakli: do not (don't) / does not (doesn't).
Savol shakli: Do / Does oldinga chiqadi.''';
    }

    if (lower.contains('past simple') || lower.contains('o\'tgan zamon')) {
      return '''📙 Past Simple (Oddiy o'tgan zamon):

Qachon ishlatiladi?
• O'tmishda sodir bo'lib tugagan ish-harakatlar uchun (yesterday, last week, in 2020).

Formulasi:
• To'g'ri fe'llarga "-ed" qo'shiladi: play ➔ played, work ➔ worked.
• Noto'g'ri fe'llar 2-shakli (V2) olinadi: go ➔ went, see ➔ saw, buy ➔ bought.
• Inkor: "did not (didn't) + V1": "I didn't see him yesterday."''';
    }

    if (lower.contains('present perfect')) {
      return '''📗 Present Perfect Tense:

Qachon ishlatiladi?
• O'tmishda bajarilgan, ammo natijasi hozirgi vaqtda ko'rinib turgan harakatlar uchun.
• Hayotiy tajriba haqida gapirganda (ever, never, already, yet).

Formulasi:
• Subject + have / has + V3 (Past Participle).
Misol: "I have learned 50 new words today!" (Men bugun 50 ta yangi so'z o'rgandim).''';
    }

    if (lower.contains('coin') || lower.contains('tanga') || lower.contains('pul') || lower.contains('qanday ishlash')) {
      return '''🪙 YODGAR ilovasida Coin ishlash yo'llari:

1. 🎮 10 ta o'yinni o'ynab yutish: har bir o'yindan +20 dan +50 gacha coin.
2. 📺 Bepul reklama tomosha qilish: do'kon bo'limidan +50 coin.
3. 🔥 Har kungi Streakni uzmaslik: har kuni +10 dan +100 gacha bonus.
4. ➕ O'zingiz yangi so'z kiritish: tasdiqlangan har bir so'z uchun +25 coin!
5. 💳 Do'kondan sotib olish (Click, Payme, Uzum orqali).''';
    }

    if (lower.contains('streak') || lower.contains('liga') || lower.contains('daraja') || lower.contains('rank')) {
      return '''🏆 YODGAR Ligalar va Streak tizimi:

🔥 Streak — bu sizning o'rganishni uzmagan kunlaringiz soni. 1 kun o'tkazib yuborsangiz, streak to'xtaydi.

Darajalar (Ligalar) pog'onasi:
• 🥉 Bronze I, II, III (0 — 200 so'z)
• 🥈 Silver I, II, III (200 — 800 so'z)
• 🥇 Gold I, II, III (800 — 2500 so'z)
• 💎 Platinum & Diamond (2500+ so'z)!''';
    }

    return '''Ajoyib savol! "$q" mavzusida ingliz va rus tillarida quyidagilarga e'tibor bering:

1. So'zni faqat yodlamasdan, kontekstda gap ichida qo'llang.
2. Talaffuziga e'tibor qiling va baland ovozda qaytaring.
3. Ilovamizdagi "Tarjimon" bo'limida ushbu jumlani tekshirib ko'ring yoki "Speed Quiz" o'yinida bilmingizni sinang!

Yana qanday savollaringiz bor? Men doim shu yerdaman! 😊👍''';
  }

  // Support message from user
  void sendSupportMessage(String text) {
    if (text.trim().isEmpty) return;

    _supportChat.add(ChatMessage(
      id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
      senderName: _currentAccount.name,
      isMe: true,
      text: text,
    ));
    _saveToPrefs();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 900), () {
      _supportChat.add(ChatMessage(
        id: 'sup_resp_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Yodgar Mutaxassisi',
        isMe: false,
        text: 'Murojaatingiz uchun tashakkur! Savolingiz mutaxassisga yo\'naltirildi. Tez orada javob beramiz.',
      ));
      _saveToPrefs();
      notifyListeners();
    });
  }

  // Admin reply directly into support chat
  void replySupportMessage(String replyText) {
    if (replyText.trim().isEmpty) return;

    _supportChat.add(ChatMessage(
      id: 'sup_admin_${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'Admin Javobi',
      isMe: false,
      text: replyText.trim(),
    ));
    _saveToPrefs();
    notifyListeners();
  }
}
