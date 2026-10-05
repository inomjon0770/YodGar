import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../models/app_models.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search controllers
  String _userSearchQuery = '';
  String _wordSearchQuery = '';

  // New Story controllers
  final TextEditingController _storyTitle = TextEditingController();
  final TextEditingController _storySubtitle = TextEditingController();
  final TextEditingController _storyContent = TextEditingController();
  String _storyIcon = '📢';

  // Support Reply controller
  final TextEditingController _supportReplyController = TextEditingController();

  // New Word controllers
  final TextEditingController _newEn = TextEditingController();
  final TextEditingController _newRu = TextEditingController();
  final TextEditingController _newUz = TextEditingController();
  final TextEditingController _newDef = TextEditingController();
  final TextEditingController _newEx = TextEditingController();
  String _selectedCat = 'B1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storyTitle.dispose();
    _storySubtitle.dispose();
    _storyContent.dispose();
    _supportReplyController.dispose();
    _newEn.dispose();
    _newRu.dispose();
    _newUz.dispose();
    _newDef.dispose();
    _newEx.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _publishStory(AppState state) {
    if (_storyTitle.text.trim().isEmpty || _storyContent.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, sarlavha va matnni kiriting!'), backgroundColor: Colors.orange),
      );
      return;
    }
    state.addStory(
      title: _storyTitle.text.trim(),
      subtitle: _storySubtitle.text.trim().isEmpty ? 'Muhim yangilik' : _storySubtitle.text.trim(),
      icon: _storyIcon,
      content: _storyContent.text.trim(),
    );
    _storyTitle.clear();
    _storySubtitle.clear();
    _storyContent.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Yangi istoriya barcha foydalanuvchilar uchun e\'lon qilindi!'), backgroundColor: AppColors.primaryGreen),
    );
  }

  void _sendSupportReply(AppState state) {
    final text = _supportReplyController.text.trim();
    if (text.isEmpty) return;

    state.replySupportMessage(text);
    _supportReplyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Foydalanuvchiga rasmiy javob yuborildi!'), backgroundColor: AppColors.primaryGreen),
    );
  }

  void _openAddWordDialog(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('➕ Yangi So\'z Qo\'shish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _newEn, decoration: const InputDecoration(labelText: 'Inglizcha so\'z*')),
                const SizedBox(height: 8),
                TextField(controller: _newRu, decoration: const InputDecoration(labelText: 'Ruscha tarjimasi')),
                const SizedBox(height: 8),
                TextField(controller: _newUz, decoration: const InputDecoration(labelText: 'O\'zbekcha ma\'nosi*')),
                const SizedBox(height: 8),
                TextField(controller: _newDef, decoration: const InputDecoration(labelText: 'Izohi / Ta\'rifi')),
                const SizedBox(height: 8),
                TextField(controller: _newEx, decoration: const InputDecoration(labelText: 'Misol gap')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Daraja: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['A1', 'A2', 'B1', 'B2', 'C1', 'IELTS'].map((c) {
                            final isSel = _selectedCat == c;
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ChoiceChip(
                                label: Text(c, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : Colors.black87)),
                                selected: isSel,
                                selectedColor: AppColors.primaryBlue,
                                onSelected: (v) => setModalState(() => _selectedCat = c),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Bekor qilish')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () {
                if (_newEn.text.trim().isEmpty || _newUz.text.trim().isEmpty) return;
                state.addCustomWord(
                  english: _newEn.text.trim(),
                  russian: _newRu.text.trim().isEmpty ? _newEn.text.trim() : _newRu.text.trim(),
                  uzbek: _newUz.text.trim(),
                  definitionUz: _newDef.text.trim().isEmpty ? 'Admin tomonidan qo\'shildi' : _newDef.text.trim(),
                  exampleSentence: _newEx.text.trim().isEmpty ? 'Example phrase.' : _newEx.text.trim(),
                  category: _selectedCat,
                );
                _newEn.clear();
                _newRu.clear();
                _newUz.clear();
                _newDef.clear();
                _newEx.clear();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ So\'z lug\'atga kiritildi!'), backgroundColor: AppColors.primaryGreen),
                );
              },
              child: const Text('Qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCoinModifierDialog(AppState state, UserAccount user) {
    final coinController = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${user.name} ga Coin berish / ayirish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hozirgi balansi: ${user.coins} 🪙', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            TextField(
              controller: coinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Miqdor',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final val = int.tryParse(coinController.text.trim()) ?? 0;
              state.updateUserCoins(user.id, -val);
              Navigator.of(ctx).pop();
            },
            child: const Text('Ayirish (-)', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.white),
            onPressed: () {
              final val = int.tryParse(coinController.text.trim()) ?? 0;
              state.updateUserCoins(user.id, val);
              Navigator.of(ctx).pop();
            },
            child: const Text('Qo\'shish (+)'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(AppState state, UserAccount user) {
    if (user.role == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bosh admin akkauntini o\'chirish mumkin emas!'), backgroundColor: Colors.red),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Foydalanuvchini o\'chirish'),
        content: Text('${user.name} (${user.email}) hisobini butunlay o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              state.deleteUser(user.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Foydalanuvchi tizimdan o\'chirildi.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('👑 Admin Boshqaruv Markazi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Admin paneldan chiqish',
            onPressed: () {
              Navigator.of(context).pop();
              state.logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.primaryBlue,
          tabs: [
            const Tab(icon: Icon(Icons.dashboard_rounded), text: 'Boshqaruv'),
            Tab(
              icon: const Icon(Icons.people_alt_rounded),
              text: 'Foydalanuvchilar (${state.accounts.length})',
            ),
            Tab(
              icon: const Icon(Icons.menu_book_rounded),
              text: 'Lug\'at (${state.words.length})',
            ),
            Tab(
              icon: const Icon(Icons.amp_stories_rounded),
              text: 'Storiyalar (${state.stories.length})',
            ),
            Tab(
              icon: const Icon(Icons.support_agent_rounded),
              text: 'Texnik Yordam (${state.supportChat.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(state),
          _buildUsersTab(state),
          _buildVocabularyTab(state),
          _buildStoriesTab(state),
          _buildSupportDeskTab(state),
        ],
      ),
    );
  }

  // ================= TAB 1: OVERVIEW & DASHBOARD =================
  Widget _buildOverviewTab(AppState state) {
    final totalCoins = state.accounts.fold<int>(0, (sum, a) => sum + a.coins);
    final pendingWords = state.words.where((w) => w.isCustom && !w.approvedByAdmin).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.gold,
                  child: Text('👑', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Master Admin Nazorati',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Barcha foydalanuvchilar, lug\'at bazasi, coinlar va texnik xizmatlar to\'liq sizning nazoratingizda.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Asosiy Ko\'rsatkichlar (KPI):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildMetricCard('👥 Foydalanuvchilar', '${state.accounts.length + 1540} ta', AppColors.primaryBlue),
              const SizedBox(width: 12),
              _buildMetricCard('🪙 Muomaladagi Coin', '$totalCoins 🪙', AppColors.gold),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricCard('📚 Jami So\'zlar', '${state.words.length} ta', AppColors.primaryGreen),
              const SizedBox(width: 12),
              _buildMetricCard('⏳ Tasdiq Kutilmoqda', '$pendingWords ta', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricCard('📢 Faol Storiyalar', '${state.stories.length} ta', Colors.purple),
              const SizedBox(width: 12),
              _buildMetricCard('📩 Texnik Xabarlar', '${state.supportChat.length} ta', Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Action Buttons
          const Text('Tezkor Amallar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Yangi So\'z Qo\'shish'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                onPressed: () => _openAddWordDialog(state),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.campaign_rounded),
                label: const Text('Istoriya Joylash'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                onPressed: () => _tabController.animateTo(3),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.manage_accounts_rounded),
                label: const Text('Foydalanuvchilarni Ko\'rish'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                onPressed: () => _tabController.animateTo(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, Color color) {
    return Expanded(
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
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // ================= TAB 2: USERS MANAGEMENT =================
  Widget _buildUsersTab(AppState state) {
    final filteredUsers = state.accounts.where((u) {
      return u.name.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_userSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Foydalanuvchi ismi yoki emaili bo\'yicha qidiruv...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => setState(() => _userSearchQuery = v),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, idx) {
              final user = filteredUsers[idx];
              final isMasterAdmin = user.role == 'admin';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isMasterAdmin ? AppColors.gold.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1),
                            child: Text(user.avatar, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    if (isMasterAdmin) ...[
                                      const SizedBox(width: 6),
                                      const Text('👑 Admin', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold)),
                                    ],
                                  ],
                                ),
                                Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          // Delete button (non-admin only)
                          if (!isMasterAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Foydalanuvchini o\'chirish',
                              onPressed: () => _confirmDeleteUser(state, user),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // User stats & Coin actions
                      Row(
                        children: [
                          Text('🪙 ${user.coins} Coin', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                          const SizedBox(width: 12),
                          Text('🔥 ${user.streak} kun streak', style: const TextStyle(fontSize: 12, color: AppColors.orangeFlame)),
                          const SizedBox(width: 12),
                          Text('🏆 ${user.rank}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const Spacer(),

                          // Quick +100
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              side: const BorderSide(color: AppColors.primaryGreen),
                            ),
                            onPressed: () {
                              state.updateUserCoins(user.id, 100);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${user.name} ga +100 Coin berildi!'), backgroundColor: AppColors.primaryGreen),
                              );
                            },
                            child: const Text('+100 🪙', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                          ),
                          const SizedBox(width: 6),

                          // Custom modify
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () => _showCoinModifierDialog(state, user),
                            child: const Text('Boshqarish', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= TAB 3: VOCABULARY MANAGEMENT =================
  Widget _buildVocabularyTab(AppState state) {
    final filtered = state.words.where((w) {
      return w.english.toLowerCase().contains(_wordSearchQuery.toLowerCase()) ||
          w.uzbek.toLowerCase().contains(_wordSearchQuery.toLowerCase()) ||
          w.russian.toLowerCase().contains(_wordSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Controls: Search + Add Word Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'So\'z qidirish (En, Uz, Ru)...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _wordSearchQuery = v),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Qo\'shish'),
                onPressed: () => _openAddWordDialog(state),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final w = filtered[idx];
              final isPending = w.isCustom && !w.approvedByAdmin;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: isPending ? Colors.orange.withValues(alpha: 0.1) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                    child: Text(w.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryBlue)),
                  ),
                  title: Row(
                    children: [
                      Text(w.english, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text(' ➔ '),
                      Text(w.uzbek, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                      if (isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Kutilmoqda', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('🇷🇺 ${w.russian} • ${w.definitionUz}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.primaryGreen),
                          tooltip: 'Tasdiqlash',
                          onPressed: () {
                            state.approveWord(w.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ "${w.english}" so\'zi rasman tasdiqlandi!'), backgroundColor: AppColors.primaryGreen),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'O\'chirish',
                        onPressed: () {
                          state.deleteWord(w.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${w.english}" so\'zi o\'chirildi.'), backgroundColor: Colors.red),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= TAB 4: STORIES MANAGEMENT =================
  Widget _buildStoriesTab(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yangi Istoriya (Story) Joylash:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Ushbu e\'lon barcha foydalanuvchilarning asosiy sahifasidagi Stories barida ko\'rinadi.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: _storyTitle, decoration: const InputDecoration(labelText: 'Sarlavha (masalan: 2.0 Yangilanish)')),
                const SizedBox(height: 10),
                TextField(controller: _storySubtitle, decoration: const InputDecoration(labelText: 'Qisqa izoh')),
                const SizedBox(height: 10),
                TextField(controller: _storyContent, maxLines: 3, decoration: const InputDecoration(labelText: 'To\'liq matn')),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Belgi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...['📢', '🎉', '💡', '🔥', '🚀', '⭐', '🏆'].map((emoji) {
                      final isSel = _storyIcon == emoji;
                      return GestureDetector(
                        onTap: () => setState(() => _storyIcon = emoji),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primaryBlue.withValues(alpha: 0.25) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: isSel ? AppColors.primaryBlue : Colors.transparent),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 18)),
                        ),
                      );
                    }),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                      onPressed: () => _publishStory(state),
                      child: const Text('E\'lon qilish'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Active Stories List
          const Text('Faol Storiyalar Ro\'yxati:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          ...state.stories.map((st) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                  child: Text(st.icon, style: const TextStyle(fontSize: 20)),
                ),
                title: Text(st.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${st.subtitle} • ${st.content}', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'O\'chirish',
                  onPressed: () {
                    state.deleteStory(st.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Istoriya o\'chirildi.'), backgroundColor: Colors.red),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= TAB 5: TECHNICAL SUPPORT DESK =================
  Widget _buildSupportDeskTab(AppState state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.blue.withValues(alpha: 0.1),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Foydalanuvchilarning texnik savollariga bu yerdan to\'g\'ridan-to\'g\'ri javob berishingiz mumkin.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        // Message stream
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.supportChat.length,
            itemBuilder: (context, idx) {
              final msg = state.supportChat[idx];
              final isAdminMsg = msg.senderName.contains('Admin') || msg.senderName.contains('Mutaxassis');

              return Align(
                alignment: isAdminMsg ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isAdminMsg ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.senderName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAdminMsg ? Colors.white70 : AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isAdminMsg ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Admin reply bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _supportReplyController,
                  decoration: InputDecoration(
                    hintText: 'Foydalanuvchiga javob yozing...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                icon: const Icon(Icons.send_rounded),
                onPressed: () => _sendSupportReply(state),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
