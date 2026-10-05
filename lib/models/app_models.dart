class UserAccount {
  final String id;
  String name;
  String email;
  String? phoneNumber;
  String avatar;
  String role; // 'user' or 'admin'
  int coins;
  int streak;
  int weeklyStreak;
  List<int> claimedWeeklyRewards;
  DateTime lastActiveDate;
  int learnedWordsCount;
  int dailyLimit;
  int dailyWordsLearned;
  bool isPremium;
  String targetLanguage; // 'en' or 'ru'
  List<String> followingUserIds;
  List<String> followersUserIds;
  List<String> favoriteWordIds;
  String referralCode;
  bool hasNoAds;
  int streakFreezes;
  String activeFrame;
  bool hasDoubleCoins;
  List<String> unlockedAvatars;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatar = '👨‍🎓',
    this.role = 'user',
    this.coins = 15, // Balanced welcome bonus (1-10 range)
    this.streak = 1,
    this.weeklyStreak = 1,
    List<int>? claimedWeeklyRewards,
    DateTime? lastActiveDate,
    this.learnedWordsCount = 0,
    this.dailyLimit = 20,
    this.dailyWordsLearned = 0,
    this.isPremium = false,
    this.targetLanguage = 'en',
    List<String>? followingUserIds,
    List<String>? followersUserIds,
    List<String>? favoriteWordIds,
    String? referralCode,
    this.hasNoAds = false,
    this.streakFreezes = 0,
    this.activeFrame = 'none',
    this.hasDoubleCoins = false,
    List<String>? unlockedAvatars,
  })  : lastActiveDate = lastActiveDate ?? DateTime.now(),
        claimedWeeklyRewards = claimedWeeklyRewards ?? [],
        followingUserIds = followingUserIds ?? [],
        followersUserIds = followersUserIds ?? [],
        favoriteWordIds = favoriteWordIds ?? [],
        unlockedAvatars = unlockedAvatars ?? ['👨‍🎓'],
        referralCode = referralCode ?? 'YODGAR-${DateTime.now().millisecondsSinceEpoch % 100000}';

  bool get dailyGoalCompleted => dailyWordsLearned >= 5;

  String get rank {
    if (learnedWordsCount < 50) return 'Bronze I';
    if (learnedWordsCount < 120) return 'Bronze II';
    if (learnedWordsCount < 200) return 'Bronze III';
    if (learnedWordsCount < 350) return 'Silver I';
    if (learnedWordsCount < 550) return 'Silver II';
    if (learnedWordsCount < 800) return 'Silver III';
    if (learnedWordsCount < 1200) return 'Gold I';
    if (learnedWordsCount < 1800) return 'Gold II';
    if (learnedWordsCount < 2500) return 'Gold III';
    if (learnedWordsCount < 3500) return 'Platinum';
    return 'Diamond';
  }

  double get rankProgress {
    if (learnedWordsCount < 50) return learnedWordsCount / 50.0;
    if (learnedWordsCount < 120) return (learnedWordsCount - 50) / 70.0;
    if (learnedWordsCount < 200) return (learnedWordsCount - 120) / 80.0;
    if (learnedWordsCount < 350) return (learnedWordsCount - 200) / 150.0;
    if (learnedWordsCount < 550) return (learnedWordsCount - 350) / 200.0;
    if (learnedWordsCount < 800) return (learnedWordsCount - 550) / 250.0;
    if (learnedWordsCount < 1200) return (learnedWordsCount - 800) / 400.0;
    if (learnedWordsCount < 1800) return (learnedWordsCount - 1200) / 600.0;
    if (learnedWordsCount < 2500) return (learnedWordsCount - 1800) / 700.0;
    return 1.0;
  }

  bool isOnline({String? currentAccountId}) {
    if (currentAccountId != null && id == currentAccountId) return true;
    return DateTime.now().difference(lastActiveDate).inMinutes < 3;
  }

  String getOnlineStatusText({String? currentAccountId}) {
    if (isOnline(currentAccountId: currentAccountId)) {
      return 'Onlayn 🟢';
    }
    final now = DateTime.now();
    final last = lastActiveDate;
    final timeStr = '${last.hour.toString().padLeft(2, '0')}:${last.minute.toString().padLeft(2, '0')}';
    final isToday = now.year == last.year && now.month == last.month && now.day == last.day;
    final isYesterday = now.difference(last).inDays == 1 || (now.day - last.day == 1 && now.month == last.month && now.year == last.year);

    if (isToday) {
      return 'Oxirgi marta: bugun $timeStr da';
    } else if (isYesterday) {
      return 'Oxirgi marta: kecha $timeStr da';
    } else {
      final dateStr = '${last.day.toString().padLeft(2, '0')}.${last.month.toString().padLeft(2, '0')}';
      return 'Oxirgi marta: $dateStr, $timeStr da';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatar': avatar,
        'role': role,
        'coins': coins,
        'streak': streak,
        'weeklyStreak': weeklyStreak,
        'claimedWeeklyRewards': claimedWeeklyRewards,
        'lastActiveDate': lastActiveDate.toIso8601String(),
        'learnedWordsCount': learnedWordsCount,
        'dailyLimit': dailyLimit,
        'dailyWordsLearned': dailyWordsLearned,
        'isPremium': isPremium,
        'targetLanguage': targetLanguage,
        'followingUserIds': followingUserIds,
        'followersUserIds': followersUserIds,
        'favoriteWordIds': favoriteWordIds,
        'referralCode': referralCode,
        'hasNoAds': hasNoAds,
        'streakFreezes': streakFreezes,
        'activeFrame': activeFrame,
        'hasDoubleCoins': hasDoubleCoins,
        'unlockedAvatars': unlockedAvatars,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Foydalanuvchi',
        email: json['email'] ?? '',
        phoneNumber: json['phoneNumber'],
        avatar: json['avatar'] ?? '👨‍🎓',
        role: json['role'] ?? 'user',
        coins: json['coins'] ?? 15,
        streak: json['streak'] ?? 1,
        weeklyStreak: json['weeklyStreak'] ?? 1,
        claimedWeeklyRewards: List<int>.from(json['claimedWeeklyRewards'] ?? []),
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.tryParse(json['lastActiveDate']) ?? DateTime.now()
            : DateTime.now(),
        learnedWordsCount: json['learnedWordsCount'] ?? 0,
        dailyLimit: json['dailyLimit'] ?? 20,
        dailyWordsLearned: json['dailyWordsLearned'] ?? 0,
        isPremium: json['isPremium'] ?? false,
        targetLanguage: json['targetLanguage'] ?? 'en',
        followingUserIds: List<String>.from(json['followingUserIds'] ?? []),
        followersUserIds: List<String>.from(json['followersUserIds'] ?? []),
        favoriteWordIds: List<String>.from(json['favoriteWordIds'] ?? []),
        referralCode: json['referralCode'],
        hasNoAds: json['hasNoAds'] ?? false,
        streakFreezes: json['streakFreezes'] ?? 0,
        activeFrame: json['activeFrame'] ?? 'none',
        hasDoubleCoins: json['hasDoubleCoins'] ?? false,
        unlockedAvatars: List<String>.from(json['unlockedAvatars'] ?? ['👨‍🎓']),
      );
}

class VocabularyWord {
  final String id;
  final String english;
  final String russian;
  final String uzbek;
  final String phonetic;
  final String partOfSpeech; // noun, verb, adj, adv
  final String definitionUz;
  final String definitionRu;
  final String exampleSentence;
  final String exampleTranslation;
  final String category; // A1, A2, B1, B2, C1, IELTS, IT, Biznes
  bool isLearned;
  final bool isCustom;
  bool approvedByAdmin;

  VocabularyWord({
    required this.id,
    required this.english,
    required this.russian,
    required this.uzbek,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definitionUz,
    required this.definitionRu,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.category = 'A1',
    this.isLearned = false,
    this.isCustom = false,
    this.approvedByAdmin = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'english': english,
        'russian': russian,
        'uzbek': uzbek,
        'phonetic': phonetic,
        'partOfSpeech': partOfSpeech,
        'definitionUz': definitionUz,
        'definitionRu': definitionRu,
        'exampleSentence': exampleSentence,
        'exampleTranslation': exampleTranslation,
        'category': category,
        'isLearned': isLearned,
        'isCustom': isCustom,
        'approvedByAdmin': approvedByAdmin,
      };

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => VocabularyWord(
        id: json['id'] ?? '',
        english: json['english'] ?? '',
        russian: json['russian'] ?? '',
        uzbek: json['uzbek'] ?? '',
        phonetic: json['phonetic'] ?? '',
        partOfSpeech: json['partOfSpeech'] ?? '',
        definitionUz: json['definitionUz'] ?? '',
        definitionRu: json['definitionRu'] ?? '',
        exampleSentence: json['exampleSentence'] ?? '',
        exampleTranslation: json['exampleTranslation'] ?? '',
        category: json['category'] ?? 'A1',
        isLearned: json['isLearned'] ?? false,
        isCustom: json['isCustom'] ?? false,
        approvedByAdmin: json['approvedByAdmin'] ?? true,
      );
}

class StoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String date;
  final String content;
  bool isRead;

  StoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.date,
    required this.content,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'icon': icon,
        'date': date,
        'content': content,
        'isRead': isRead,
      };

  factory StoryItem.fromJson(Map<String, dynamic> json) => StoryItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        icon: json['icon'] ?? '📢',
        date: json['date'] ?? '',
        content: json['content'] ?? '',
        isRead: json['isRead'] ?? false,
      );
}

class LeaderboardEntry {
  final String id;
  final String name;
  final String avatar;
  final int coins;
  final int streak;
  final String rank;
  final int wordsLearned;
  bool isFollowing;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatar,
    required this.coins,
    required this.streak,
    required this.rank,
    required this.wordsLearned,
    this.isFollowing = false,
  });
}

class CommunityComment {
  final String id;
  final String authorName;
  final String text;
  final String timeAgo;

  CommunityComment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.timeAgo,
  });
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String content;
  int likesCount;
  bool isLiked;
  final List<CommunityComment> comments;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.content,
    required this.likesCount,
    this.isLiked = false,
    List<CommunityComment>? comments,
  }) : comments = comments ?? [];
}

class ChatMessage {
  final String id;
  final String senderName;
  final bool isMe;
  final bool isAiSobir;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.isMe,
    this.isAiSobir = false,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderName': senderName,
        'isMe': isMe,
        'isAiSobir': isAiSobir,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        senderName: json['senderName'] ?? '',
        isMe: json['isMe'] ?? false,
        isAiSobir: json['isAiSobir'] ?? false,
        text: json['text'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class CoinPackage {
  final String id;
  final String title;
  final int coins;
  final int priceUzs;
  final String bonus;
  final bool isPopular;

  CoinPackage({
    required this.id,
    required this.title,
    required this.coins,
    required this.priceUzs,
    required this.bonus,
    this.isPopular = false,
  });
}

class ShopPerk {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int coinPrice;
  final String category; // 'utility', 'cosmetic', 'booster'

  const ShopPerk({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.coinPrice,
    required this.category,
  });
}

class DirectMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  bool isRead;

  DirectMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.text,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory DirectMessage.fromJson(Map<String, dynamic> json) => DirectMessage(
        id: json['id'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        receiverId: json['receiverId'] ?? '',
        text: json['text'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
        isRead: json['isRead'] ?? false,
      );
}
