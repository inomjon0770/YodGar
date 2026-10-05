import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/state/app_state.dart';
import 'package:my_flutter_app/services/translation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TranslationService Tests', () {
    test('translates common greetings and vocabulary offline accurately', () async {
      final res1 = await TranslationService.translate(
        text: 'hello',
        fromLanguage: 'Inglizcha',
        toLanguage: 'O\'zbekcha',
      );
      expect(res1.toLowerCase(), contains('salom'));

      final res2 = await TranslationService.translate(
        text: 'kitob',
        fromLanguage: 'O\'zbekcha',
        toLanguage: 'Inglizcha',
      );
      expect(res2.toLowerCase(), equals('book'));

      final res3 = await TranslationService.translate(
        text: 'спасибо',
        fromLanguage: 'Ruscha',
        toLanguage: 'O\'zbekcha',
      );
      expect(res3.toLowerCase(), contains('rahmat'));

      final res4 = await TranslationService.translate(
        text: 'good morning',
        fromLanguage: 'Inglizcha',
        toLanguage: 'O\'zbekcha',
      );
      expect(res4.toLowerCase(), contains('xayrli tong'));
    });
  });

  group('Admin Security & Role Isolation Tests', () {
    test('Admin account cannot be registered through registerUser', () {
      final state = AppState();
      expect(
        () => state.registerUser(
          name: 'Fake Admin',
          email: 'admin@yodgar.uz',
        ),
        throwsException,
      );
    });

    test('loginWithFirebaseUser strictly creates user role', () {
      final state = AppState();
      final acc = state.loginWithFirebaseUser(
        uid: 'test_uid_123',
        name: 'Tester',
        email: 'admin@yodgar.uz', // Even if email attempts to impersonate admin
      );
      expect(acc.role, equals('user'));
    });

    test('Single valid way to admin is email & password login', () {
      final state = AppState();

      // Wrong password fails
      final failedLogin = state.login(email: 'admin@yodgar.uz', password: 'wrongpassword');
      expect(failedLogin, isFalse);

      // Correct password succeeds
      final successLogin = state.login(email: 'admin@yodgar.uz', password: 'admin');
      expect(successLogin, isTrue);
      expect(state.isAdmin, isTrue);
    });

    test('Regular user cannot switch to admin account via switcher', () {
      final state = AppState();
      // Register a regular user
      final user = state.registerUser(name: 'Ali Valiyev', email: 'ali@gmail.com');
      expect(state.isAdmin, isFalse);
      expect(state.currentAccount.id, equals(user.id));

      // Attempt to switch to admin_master without password
      state.switchAccount('admin_master');
      expect(state.isAdmin, isFalse);
      expect(state.currentAccount.id, equals(user.id));

      // switchableAccounts for non-admin excludes admin_master
      expect(state.switchableAccounts.any((a) => a.role == 'admin'), isFalse);
    });

    test('Deleting all user accounts logs out and drops to login screen without landing in admin', () {
      final state = AppState();
      final user = state.registerUser(name: 'Only User', email: 'only@user.uz');
      expect(state.isAuthenticated, isTrue);
      expect(state.isAdmin, isFalse);

      // User deletes their only account
      state.deleteUser(user.id);

      // System must completely log out to auth screen, NOT expose Admin panel!
      expect(state.isAuthenticated, isFalse);
      expect(state.isAdmin, isFalse);
      expect(state.isAdminLoggedIn, isFalse);
    });

    test('Logging out resets isAuthenticated and isAdmin', () {
      final state = AppState();
      state.login(email: 'admin@yodgar.uz', password: 'admin');
      expect(state.isAdmin, isTrue);
      expect(state.isAuthenticated, isTrue);

      state.logout();
      expect(state.isAdmin, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.isAdminLoggedIn, isFalse);
    });

    test('Coins and streak mutations persist to state', () {
      final state = AppState();
      state.registerUser(name: 'Sardor', email: 'sardor@mail.uz');
      final initialCoins = state.currentAccount.coins;
      expect(initialCoins, equals(50)); // 50 welcome bonus

      state.addCoins(25, 'Test bonus');
      expect(state.currentAccount.coins, equals(75));

      final spent = state.spendCoins(30);
      expect(spent, isTrue);
      expect(state.currentAccount.coins, equals(45));
    });

    test('dailyGoalCompleted returns true when dailyWordsLearned reaches 5', () {
      final state = AppState();
      state.currentAccount.dailyWordsLearned = 3;
      expect(state.currentAccount.dailyGoalCompleted, isFalse);

      state.currentAccount.dailyWordsLearned = 5;
      expect(state.currentAccount.dailyGoalCompleted, isTrue);
    });

    test('Weekly streak progressive rewards verification (Max 10 coins)', () {
      final state = AppState();
      expect(AppState.weeklyStreakRewards[1], equals(2));
      expect(AppState.weeklyStreakRewards[7], equals(10));
    });

    test('Coin spending perks purchase reduces coins and activates perks', () {
      final state = AppState();
      final user = state.registerUser(name: 'Coin Spender', email: 'spend@test.uz');
      expect(user.hasNoAds, isFalse);
      expect(user.streakFreezes, equals(0));

      final noAdsPerk = state.shopPerks.firstWhere((p) => p.id == 'no_ads');
      final boughtNoAds = state.buyPerk(noAdsPerk);
      expect(boughtNoAds, isTrue);
      expect(state.currentAccount.hasNoAds, isTrue);
      expect(state.currentAccount.coins, equals(20)); // 50 - 30 = 20

      final freezePerk = state.shopPerks.firstWhere((p) => p.id == 'streak_freeze');
      final boughtFreeze = state.buyPerk(freezePerk);
      expect(boughtFreeze, isTrue);
      expect(state.currentAccount.streakFreezes, equals(1));
      expect(state.currentAccount.coins, equals(0)); // 20 - 20 = 0

      // Cannot buy without enough coins
      final doubleCoinsPerk = state.shopPerks.firstWhere((p) => p.id == 'double_coins');
      final boughtFail = state.buyPerk(doubleCoinsPerk);
      expect(boughtFail, isFalse);
    });

    test('Leaderboard strictly contains NO mock or fake users by default', () {
      final state = AppState();
      // Only master admin initially, so leaderboard is empty (admin not shown in user leaderboard)
      expect(state.leaderboard.isEmpty, isTrue);

      // Register real user
      final user = state.registerUser(name: 'Inomjon Dev', email: 'inomjon@real.uz');
      expect(state.leaderboard.length, equals(1));
      expect(state.leaderboard.first.name, contains('Inomjon Dev'));
    });

    test('Mutual follow and Direct messaging between real learners', () {
      final state = AppState();
      final me = state.registerUser(name: 'Learner Me', email: 'me@learn.uz');
      final peer = state.registerUser(name: 'Learner Peer', email: 'peer@learn.uz');

      expect(state.isMutualFollow(peer.id), isFalse);

      // Follow peer (with peer reciprocity)
      state.toggleFollow(peer.id);
      expect(state.isMutualFollow(peer.id), isTrue);

      // Send direct message
      state.sendDirectMessage(peer.id, 'Salom do\'stim!');
      final dms = state.getDirectMessagesWith(peer.id);
      expect(dms.isNotEmpty, isTrue);
      expect(dms.any((m) => m.text == 'Salom do\'stim!'), isTrue);
    });

    test('Direct messaging: NO AI auto-reply, checkmark unread (isRead=false) and read (isRead=true)', () {
      final state = AppState();
      final me = state.registerUser(name: 'Learner Me', email: 'me@learn.uz');
      final peer = state.registerUser(name: 'Learner Peer', email: 'peer@learn.uz');

      // Send message from Me to Peer
      state.sendDirectMessage(peer.id, 'Salom do\'stim!');

      // Verify NO AI reply was generated
      final dms = state.getDirectMessagesWith(peer.id);
      expect(dms.length, equals(1));
      expect(dms.first.isRead, isFalse); // 1 tick: unread (bitta pichichka)

      // Switch to Peer
      state.switchAccount(peer.id);
      expect(state.getUnreadCountFrom(me.id), equals(1));

      // Peer opens chat -> marks message as read
      state.markMessagesAsRead(me.id);
      expect(state.getUnreadCountFrom(me.id), equals(0));

      final peerDms = state.getDirectMessagesWith(me.id);
      expect(peerDms.first.isRead, isTrue); // 2 ticks: seen (ikkita pichichka)

      // Online status check
      expect(peer.isOnline(currentAccountId: peer.id), isTrue);
      expect(peer.getOnlineStatusText(currentAccountId: peer.id), contains('Onlayn'));
    });
  });
}
