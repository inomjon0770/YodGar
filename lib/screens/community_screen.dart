import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../models/app_models.dart';
import '../widgets/user_profile_dialog.dart';
import 'direct_chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _newPostController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _peerChatController = TextEditingController();
  String _userSearchQuery = '';

  final List<ChatMessage> _groupChat = [
    ChatMessage(id: 'gc1', senderName: 'Dilnoza', isMe: false, text: 'Salom hammaga! Bugun kim IELTS lug\'atini o\'rganyapti?'),
    ChatMessage(id: 'gc2', senderName: 'Shoxrux', isMe: false, text: 'Salom! Men B2 darajadagi Sentence Builder o\'yinini tugatyapman.'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newPostController.dispose();
    _commentController.dispose();
    _peerChatController.dispose();
    super.dispose();
  }

  void _createPost(AppState state) {
    if (_newPostController.text.trim().isEmpty) return;
    state.posts.insert(
      0,
      CommunityPost(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        authorName: state.currentAccount.name,
        authorAvatar: state.currentAccount.avatar,
        timeAgo: 'Hozirgina',
        content: _newPostController.text.trim(),
        likesCount: 0,
      ),
    );
    _newPostController.clear();
    setState(() {});
  }

  void _sendGroupMessage(AppState state) {
    if (_peerChatController.text.trim().isEmpty) return;
    setState(() {
      _groupChat.add(ChatMessage(
        id: 'gc_${DateTime.now().millisecondsSinceEpoch}',
        senderName: state.currentAccount.name,
        isMe: true,
        text: _peerChatController.text.trim(),
      ));
      _peerChatController.clear();
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _groupChat.add(ChatMessage(
          id: 'gc_reply_${DateTime.now().millisecondsSinceEpoch}',
          senderName: 'Jasur Rustamov',
          isMe: false,
          text: 'Ajoyib fikr! YODGAR ilovasida so\'z yodlash judayam osonlashdi.',
        ));
      });
    });
  }

  void _showCommentSheet(BuildContext context, CommunityPost post, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Izohlar (${post.comments.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const Divider(),
              if (post.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Hozircha izohlar yo\'q. Birinchi bo\'lib izoh qoldiring!')),
                )
              else
                ...post.comments.map((c) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Text('💬')),
                      title: Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(c.text),
                      trailing: Text(c.timeAgo, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Izoh yozing...',
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        state.addCommentToPost(post.id, _commentController.text.trim());
                        _commentController.clear();
                        Navigator.of(ctx).pop();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final mutuals = state.mutualFriends;
    final discoverUsers = state.allDiscoverUsers.where((u) {
      if (_userSearchQuery.isEmpty) return true;
      return u.name.toLowerCase().contains(_userSearchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Jamoa & Do\'stlar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Faollik Tasmasi'),
            Tab(text: 'Do\'stlar & Chat'),
            Tab(text: 'Kuzatish'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. FEED TAB
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // New post input box
              GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text(state.currentAccount.avatar)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _newPostController,
                            decoration: const InputDecoration(
                              hintText: 'Yutuqlaringiz yoki fikringizni ulashing...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('💡 ', style: TextStyle(fontSize: 16)),
                            Text('Fikr qoldiring va do\'stlar orttiring', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _createPost(state),
                          child: const Text('Ulashish', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Posts feed
              ...state.posts.map((post) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: GlassContainer(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(child: Text(post.authorAvatar)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(post.timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                state.toggleLikePost(post.id);
                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: post.isLiked ? Colors.red : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${post.likesCount}', style: TextStyle(color: post.isLiked ? Colors.red : Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            InkWell(
                              onTap: () => _showCommentSheet(context, post, state),
                              child: Row(
                                children: [
                                  const Icon(Icons.mode_comment_outlined, color: Colors.grey, size: 20),
                                  const SizedBox(width: 6),
                                  Text('${post.comments.length} ta izoh', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
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

          // 2. DO'STLAR & SHAXSIY CHATLAR TAB
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Mutual friends header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'O\'zaro Do\'stlar (${mutuals.length} ta)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Chat ochiq 💬', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (mutuals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text('🤝', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 8),
                      const Text(
                        'Hozircha o\'zaro do\'stlar yo\'q',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '"Kuzatish" bo\'limidan o\'rganuvchilarga obuna bo\'ling. Ikkala taraf obuna bo\'lganda shaxsiy chat avtomatik ochiladi!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _tabController.animateTo(2),
                        child: const Text('Foydalanuvchilarni ko\'rish ➔'),
                      ),
                    ],
                  ),
                )
              else
                ...mutuals.map((friend) {
                  final dmWithFriend = state.getDirectMessagesWith(friend.id);
                  final lastMsg = dmWithFriend.isNotEmpty ? dmWithFriend.last.text : 'Hozircha xabarlar yo\'q';
                  final isOnline = friend.isOnline(currentAccountId: state.currentAccount.id);
                  final onlineStatus = friend.getOnlineStatusText(currentAccountId: state.currentAccount.id);
                  final unreadCount = state.getUnreadCountFrom(friend.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => DirectChatScreen(peerUser: friend)),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                                child: Text(friend.avatar, style: const TextStyle(fontSize: 22)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isOnline ? AppColors.primaryGreen : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(friend.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(width: 6),
                                    const Text('🤝', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  onlineStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isOnline ? AppColors.primaryGreen : Colors.grey,
                                    fontWeight: isOnline ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lastMsg,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: unreadCount > 0 ? Colors.orange.shade700 : AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                            label: Text(
                              unreadCount > 0 ? 'Chat ($unreadCount)' : 'Chat',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (ctx) => DirectChatScreen(peerUser: friend)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Group Chat section
              const Text('Umumiy Guruh Chati 💬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),

              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _groupChat.length,
                        itemBuilder: (context, index) {
                          final msg = _groupChat[index];
                          return Align(
                            alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: msg.isMe ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    msg.text,
                                    style: TextStyle(color: msg.isMe ? Colors.white : null, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _peerChatController,
                              decoration: InputDecoration(
                                hintText: 'Guruhga yozing...',
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.04),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            onPressed: () => _sendGroupMessage(state),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. FOYDALANUVCHILAR (KUZATISH & ERISHILGAN NATIJALAR) TAB
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Search input
              TextField(
                onChanged: (val) => setState(() => _userSearchQuery = val),
                decoration: InputDecoration(
                  hintText: 'O\'rganuvchilarni qidirish...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Barcha faol o\'rganuvchilar (${discoverUsers.length} ta):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),

              ...discoverUsers.map((learner) {
                final isFollowing = state.currentAccount.followingUserIds.contains(learner.id);
                final isMutual = state.isMutualFollow(learner.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(14),
                    onTap: () => UserProfileDialog.show(context, learner),
                    child: Row(
                      children: [
                        // Avatar with VIP frame indicator
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (learner.activeFrame == 'gold')
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const SweepGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFF9600), Color(0xFFFFEA79), Color(0xFFFFD700)],
                                  ),
                                ),
                              ),
                            CircleAvatar(
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                              child: Text(learner.avatar, style: const TextStyle(fontSize: 22)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Name & Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(learner.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  if (isMutual) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                      child: const Text('DO\'ST 🤝', style: TextStyle(color: AppColors.primaryGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text('🏆 ${learner.rank}', style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text('🔥 ${learner.streak} kun', style: const TextStyle(fontSize: 11, color: AppColors.orangeFlame, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text('📚 ${learner.learnedWordsCount} so\'z', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                learner.getOnlineStatusText(currentAccountId: state.currentAccount.id),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: learner.isOnline(currentAccountId: state.currentAccount.id) ? AppColors.primaryGreen : Colors.grey,
                                  fontWeight: learner.isOnline(currentAccountId: state.currentAccount.id) ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFollowing ? Icons.check_circle_rounded : Icons.person_add_rounded,
                                color: isFollowing ? AppColors.primaryGreen : AppColors.primaryBlue,
                              ),
                              tooltip: isFollowing ? 'Kuzatilyapti' : 'Kuzatish',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                state.toggleFollow(learner.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                              tooltip: 'Profil va yutuqlar',
                              onPressed: () => UserProfileDialog.show(context, learner),
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
        ],
      ),
    );
  }
}
