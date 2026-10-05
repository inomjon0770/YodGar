import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../screens/direct_chat_screen.dart';

class UserProfileDialog extends StatelessWidget {
  final UserAccount user;

  const UserProfileDialog({super.key, required this.user});

  static void show(BuildContext context, UserAccount user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isMe = user.id == state.currentAccount.id;
    final isFollowing = state.currentAccount.followingUserIds.contains(user.id);
    final isMutual = state.isMutualFollow(user.id);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 25)],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Top Profile Card with Avatar & VIP Frame
            Stack(
              alignment: Alignment.center,
              children: [
                if (user.activeFrame == 'gold')
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF9600), Color(0xFFFFEA79), Color(0xFFFFD700)],
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2),
                      ],
                    ),
                  ),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(user.avatar, style: const TextStyle(fontSize: 44)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name & Rank
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (user.role == 'admin') ...[
                  const SizedBox(width: 6),
                  const Text('👑', style: TextStyle(fontSize: 18)),
                ],
                if (user.activeFrame == 'gold') ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('VIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Liga darajasi: ${user.rank} 🏆',
              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),

            // Online / Offline Status Badge with exact last seen time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.isOnline(currentAccountId: state.currentAccount.id)
                    ? AppColors.primaryGreen.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: user.isOnline(currentAccountId: state.currentAccount.id)
                          ? AppColors.primaryGreen
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.getOnlineStatusText(currentAccountId: state.currentAccount.id),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: user.isOnline(currentAccountId: state.currentAccount.id)
                          ? AppColors.primaryGreen
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Mutual & Follow status badge
            if (!isMe)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isMutual
                      ? AppColors.primaryGreen.withValues(alpha: 0.15)
                      : (isFollowing ? AppColors.primaryBlue.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isMutual ? '🤝 O\'zaro Do\'stlar (Chat ochiq)' : (isFollowing ? '✔️ Siz kuzatyapsiz' : '➕ Kuzatish mumkin'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMutual ? AppColors.primaryGreen : (isFollowing ? AppColors.primaryBlue : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // Action Buttons: Follow & Direct Chat
            if (!isMe) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.grey.shade200 : AppColors.primaryBlue,
                        foregroundColor: isFollowing ? Colors.black87 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: isFollowing ? 0 : 2,
                      ),
                      icon: Icon(isFollowing ? Icons.check_rounded : Icons.person_add_rounded, size: 18),
                      label: Text(
                        isFollowing ? 'Kuzatilyapti' : 'Obuna bo\'lish',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        state.toggleFollow(user.id);
                      },
                    ),
                  ),
                  if (isMutual) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text(
                          'Shaxsiy Chat 💬',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => DirectChatScreen(peerUser: user),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              if (!isMutual) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '🔒 Shaxsiy chat faqat ikkala foydalanuvchi bir-biriga obuna bo\'lganda ochiladi.',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
            ],

            // 4 Stats Grid: Words, Streak, Coins, Daily Limit
            Row(
              children: [
                _buildStatTile('📚 So\'zlar', '${user.learnedWordsCount} ta', 'Yodlangan', AppColors.primaryBlue),
                const SizedBox(width: 12),
                _buildStatTile('🔥 Streak', '${user.streak} kun', 'Davomiylik', AppColors.orangeFlame),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatTile('🪙 Coinlar', '${user.coins} 🪙', 'Tanga balansi', AppColors.gold),
                const SizedBox(width: 12),
                _buildStatTile('🎯 Kunlik reja', '${user.dailyLimit} ta', 'So\'z limiti', AppColors.primaryGreen),
              ],
            ),
            const SizedBox(height: 20),

            // Achievements & Badges Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🏅 ${user.name} ning Yutuqlari:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            _buildAchievementItem(
              icon: '🌱',
              title: 'Birinchi Qadam',
              desc: 'YODGAR ilovasida so\'z o\'rganishni boshladi',
              isUnlocked: user.learnedWordsCount >= 1,
            ),
            _buildAchievementItem(
              icon: '📚',
              title: 'Lug\'at Boyi (50+ so\'z)',
              desc: 'Lug\'at boyligiga 50 dan ortiq yangi so\'z qo\'shdi',
              isUnlocked: user.learnedWordsCount >= 50,
            ),
            _buildAchievementItem(
              icon: '🔥',
              title: 'Alanga Sohibi (7+ kun)',
              desc: 'Haftalik to\'xtovsiz o\'rganish streakiga ega',
              isUnlocked: user.streak >= 7,
            ),
            _buildAchievementItem(
              icon: '⚡',
              title: 'Tezkor Bilimdon',
              desc: '10 ta so\'z o\'yinlarida muntazam g\'olib',
              isUnlocked: user.coins >= 30,
            ),
            _buildAchievementItem(
              icon: '👑',
              title: 'Liga Peshqadami',
              desc: 'Reytingning yuqori darajasida faol ishtirokchi',
              isUnlocked: user.rank.contains('Gold') || user.rank.contains('Diamond') || user.rank.contains('Silver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String icon,
    required String title,
    required String desc,
    required bool isUnlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? Colors.amber.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: TextStyle(fontSize: 22, color: isUnlocked ? null : Colors.grey)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
            size: 18,
            color: isUnlocked ? AppColors.primaryGreen : Colors.grey,
          ),
        ],
      ),
    );
  }
}
