import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class DirectChatScreen extends StatefulWidget {
  final UserAccount peerUser;

  const DirectChatScreen({super.key, required this.peerUser});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppState>(context, listen: false).markMessagesAsRead(widget.peerUser.id);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(AppState state) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    state.sendDirectMessage(widget.peerUser.id, text);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickPrompt(AppState state, String text) {
    _textController.text = text;
    _sendMessage(state);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final peer = state.accounts.firstWhere((a) => a.id == widget.peerUser.id, orElse: () => widget.peerUser);
    final isOnline = peer.isOnline(currentAccountId: state.currentAccount.id);
    final onlineStatus = peer.getOnlineStatusText(currentAccountId: state.currentAccount.id);
    final messages = state.getDirectMessagesWith(widget.peerUser.id);

    // Auto mark incoming messages as read when viewing chat
    final unread = state.getUnreadCountFrom(widget.peerUser.id);
    if (unread > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state.markMessagesAsRead(widget.peerUser.id);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                  child: Text(peer.avatar, style: const TextStyle(fontSize: 22)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.primaryGreen : Colors.grey.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peer.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    onlineStatus,
                    style: TextStyle(
                      fontSize: 11,
                      color: isOnline ? AppColors.primaryGreen : Colors.white70,
                      fontWeight: isOnline ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orangeFlame.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '${widget.peerUser.streak} kun',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.orangeFlame),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mutual Friendship Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.lock_open_rounded, size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Siz va ${widget.peerUser.name} o\'zaro obuna bo\'lgansiz. Shaxsiy chat faol!',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.peerUser.avatar, style: const TextStyle(fontSize: 52)),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.peerUser.name} bilan suhbatni boshlang!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Bir-biringiz bilan so\'zlar yodlash, streaklar va yangi mavzular haqida fikr almashing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ActionChip(
                                label: const Text('Salom! Bugun nechta so\'z yodlading? 👋'),
                                onPressed: () => _sendQuickPrompt(state, 'Salom! Bugun nechta so\'z yodlading? 👋'),
                              ),
                              ActionChip(
                                label: const Text('Streak qanday ketyapti? 🔥'),
                                onPressed: () => _sendQuickPrompt(state, 'Streak qanday ketyapti? 🔥'),
                              ),
                              ActionChip(
                                label: const Text('Birga so\'z o\'yinlari o\'ynaymizmi? 🎮'),
                                onPressed: () => _sendQuickPrompt(state, 'Birga so\'z o\'yinlari o\'ynaymizmi? 🎮'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == state.currentAccount.id;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primaryBlue : Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 18),
                            ),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : null,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : Colors.grey,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      msg.isRead ? Icons.done_all_rounded : Icons.check_rounded,
                                      size: 15,
                                      color: msg.isRead ? const Color(0xFF67E8F9) : Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '${widget.peerUser.name} ga xabar yozing...',
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(state),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    onPressed: () => _sendMessage(state),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
