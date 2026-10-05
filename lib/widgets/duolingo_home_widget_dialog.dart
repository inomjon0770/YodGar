import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class DuolingoWidgetDialog extends StatefulWidget {
  final AppState state;
  final VoidCallback onStartLearning;

  const DuolingoWidgetDialog({
    super.key,
    required this.state,
    required this.onStartLearning,
  });

  static void show(BuildContext context, AppState state, VoidCallback onStartLearning) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DuolingoWidgetDialog(
        state: state,
        onStartLearning: onStartLearning,
      ),
    );
  }

  @override
  State<DuolingoWidgetDialog> createState() => _DuolingoWidgetDialogState();
}

class _DuolingoWidgetDialogState extends State<DuolingoWidgetDialog> with SingleTickerProviderStateMixin {
  late TabController _widgetSizeController;
  int _selectedStyle = 1; // 0: Small (2x2), 1: Medium (4x2 Classic), 2: Large (4x4 Pro)

  @override
  void initState() {
    super.initState();
    _widgetSizeController = TabController(length: 3, vsync: this, initialIndex: 1);
    _widgetSizeController.addListener(() {
      setState(() => _selectedStyle = _widgetSizeController.index);
    });
  }

  @override
  void dispose() {
    _widgetSizeController.dispose();
    super.dispose();
  }

  void _pinToHomeScreen() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.add_to_home_screen_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 10),
            Text('Ekranga Qadash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telefoningiz yoki brauzeringiz bosh ekraniga YODGAR Duolingo-vidjetini qadash bo\'yicha qo\'llanma:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            _buildGuideStep('1', '📱 Android / Chrome: Yuqori o\'ng burchakdagi 3 ta nuqtani (⋮) bosing ➔ "Bosh ekranga qo\'shish" (Add to Home screen) ni tanlang.'),
            const SizedBox(height: 10),
            _buildGuideStep('2', '🍏 iOS / Safari: Pastki "Ulashish" (Share 📤) tugmasini bosing ➔ "Bosh ekranga qo\'shish" ni tanlang.'),
            const SizedBox(height: 10),
            _buildGuideStep('3', '🔥 Endi telefoningiz ekranida real vaqtda Streak, Coinlar va O\'rganish holati ko\'rinib turadi!'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Shablon tayyor! Ko\'rsatilgan tartibda ekranga qadab oling.'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: const Text('Tushunarli 👍'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final acc = widget.state.currentAccount;
    final isSafe = acc.dailyWordsLearned >= acc.dailyLimit;
    final progress = (acc.dailyWordsLearned / (acc.dailyLimit > 0 ? acc.dailyLimit : 1)).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🦉', style: TextStyle(fontSize: 26)),
                    SizedBox(width: 8),
                    Text(
                      'Duolingo Vidjeti (Widget)',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Telefon ekraniga chiqarib qo\'yish uchun interaktiv shablon. Har kuni streak va coinlaringizni jonli ko\'rsatib turadi!',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 18),

            // Size Tab Selector (Kichik 2x2, O'rta 4x2, Katta 4x4)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _widgetSizeController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(text: 'Kichik 2x2'),
                  Tab(text: 'O\'rta 4x2 (Duo)'),
                  Tab(text: 'Katta 4x4 Pro'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Simulated Phone Screen Background & Widget Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF090D16)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wallpaper_rounded, size: 14, color: Colors.white38),
                      SizedBox(width: 6),
                      Text('TELEFON BOSHI EKRANI KO\'RINIShI', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // The Interactive Widget Preview
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      widget.onStartLearning();
                    },
                    child: _buildWidgetTemplate(acc, isSafe, progress),
                  ),

                  const SizedBox(height: 12),
                  const Text('👆 Vidjetni bosib to\'g\'ridan-to\'g\'ri darsga o\'tishingiz mumkin', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons (Ekranga Qadash / Darsni Boshlash)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.touch_app_rounded, size: 18),
                    label: const Text('Darsga Kirish 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onStartLearning();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add_to_home_screen_rounded, size: 20),
                    label: const Text('Ekranga Qadash 📱', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _pinToHomeScreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET RENDERER ACCORDING TO SELECTED STYLE ---
  Widget _buildWidgetTemplate(dynamic acc, bool isSafe, double progress) {
    if (_selectedStyle == 0) {
      // SMALL 2x2 SQUARE DUOLINGO WIDGET
      return Container(
        width: 170,
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSafe
                ? [const Color(0xFF15803D), const Color(0xFF16A34A)]
                : [const Color(0xFFEA580C), const Color(0xFFDC2626)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (isSafe ? Colors.green : Colors.deepOrange).withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isSafe ? '👑' : '🔥', style: const TextStyle(fontSize: 24)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                  child: Text('${acc.coins} 🪙', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            Text(isSafe ? '🦉' : '😡', style: const TextStyle(fontSize: 48)),
            Column(
              children: [
                Text(
                  '${acc.streak} KUN',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
                ),
                Text(
                  isSafe ? 'Bajarildi! ✅' : 'Hali qilinmadi ⚠️',
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (_selectedStyle == 1) {
      // MEDIUM 4x2 CLASSIC DUOLINGO FLAME WIDGET
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSafe
                ? [const Color(0xFF1E3A8A), const Color(0xFF1D4ED8), const Color(0xFF0284C7)]
                : [const Color(0xFF7C2D12), const Color(0xFFC2410C), const Color(0xFFEA580C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (isSafe ? Colors.blue : Colors.orange).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mascot with Mood
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(isSafe ? '🦉' : '🔥', style: const TextStyle(fontSize: 42)),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Colors.amberAccent, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${acc.streak} KUNLIK STREAK',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
                        child: Text('${acc.coins} 🪙', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSafe
                        ? 'Zo\'r! Bugungi maqsad bajarildi! 🎉'
                        : 'Xavf ostida! Bugun hali dars qilmadingiz ⚠️',
                    style: TextStyle(
                      color: isSafe ? Colors.greenAccent : Colors.amber.shade200,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(isSafe ? Colors.greenAccent : Colors.amberAccent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bugun: ${acc.dailyWordsLearned}/${acc.dailyLimit} so\'z',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        '${acc.rank} 🏆',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // LARGE 4x4 PRO DUOLINGO DASHBOARD WIDGET
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                      child: const Text('Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 8),
                    const Text('YODGAR PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('${acc.coins} 🪙 Coin', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 22),

            // Middle: Streak and Mascot
            Row(
              children: [
                Text(isSafe ? '🦉' : '🔥', style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${acc.streak} Kunlik Streak!',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isSafe ? 'Bugungi olov saqlab qolindi 🔥' : 'Bugun hali so\'z yodlanmadi! ⚠️',
                        style: TextStyle(color: isSafe ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 7-day Streak Calendar row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (idx) {
                final day = idx + 1;
                final isDone = day <= acc.weeklyStreak;
                return Column(
                  children: [
                    Text('K$day', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isDone ? Colors.amber : Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          color: isDone ? Colors.black87 : Colors.white24,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),

            // Fast Learning button inside widget
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Darsni Boshlash', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
