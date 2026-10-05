import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import 'glass_container.dart';

class CoinShopDialog extends StatefulWidget {
  const CoinShopDialog({super.key});

  @override
  State<CoinShopDialog> createState() => _CoinShopDialogState();
}

class _CoinShopDialogState extends State<CoinShopDialog> with SingleTickerProviderStateMixin {
  late TabController _shopTabController;
  bool _isWatchingAd = false;
  int _adCountdown = 3;

  @override
  void initState() {
    super.initState();
    _shopTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _shopTabController.dispose();
    super.dispose();
  }

  void _watchAd(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    setState(() {
      _isWatchingAd = true;
      _adCountdown = 3;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _adCountdown = 2);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _adCountdown = 1);
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          state.watchAdForCoins((earned) {
            setState(() => _isWatchingAd = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Tabriklaymiz! +$earned Coin hisobingizga qo\'shildi!'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          });
        });
      });
    });
  }

  void _buyPerk(BuildContext context, ShopPerk perk) {
    HapticFeedback.mediumImpact();
    final state = Provider.of<AppState>(context, listen: false);
    if (state.currentAccount.coins < perk.coinPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Tangalar yetarli emas! Sizda ${state.currentAccount.coins} coin bor, kerak: ${perk.coinPrice} coin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = state.buyPerk(perk);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 "${perk.title}" muvaffaqiyatli xarid qilindi! (-${perk.coinPrice} 🪙)'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _showPaymentModal(BuildContext context, CoinPackage package) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'To\'lov: ${package.title}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🪙 ${package.coins} Coin',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Narxi: ${package.priceUzs} so\'m',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text('To\'lov usulini tanlang:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPaymentMethodButton(ctx, '💳 Click', Colors.blue, package),
                  const SizedBox(width: 12),
                  _buildPaymentMethodButton(ctx, '🟢 Payme', Colors.teal, package),
                  const SizedBox(width: 12),
                  _buildPaymentMethodButton(ctx, '🌐 Uzum', Colors.purple, package),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodButton(BuildContext sheetContext, String name, Color color, CoinPackage package) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color, width: 1.5),
          ),
        ),
        onPressed: () {
          final state = Provider.of<AppState>(context, listen: false);
          state.buyCoinPackage(package);
          Navigator.of(sheetContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ To\'lov muvaffaqiyatli! +${package.coins} Coin qo\'shildi.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        },
        child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final acc = state.currentAccount;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassContainer(
        borderRadius: 26,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🪙', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coin Markazi',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Sarflash & Balansni to\'ldirish',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Current Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mavjud balansingiz:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          '🪙 ${acc.coins} Coin',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (acc.hasNoAds)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('🚫 No Ads', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        if (acc.streakFreezes > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('🧊 x${acc.streakFreezes}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Two Tab switcher
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _shopTabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🛍️ Coin Sarflash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🪙 Coin Olish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _shopTabController,
                  children: [
                    // TAB 1: COIN SARFLASH (SPENDING SHOP)
                    ListView(
                      children: state.shopPerks.map((perk) {
                        bool isActive = false;
                        if (perk.id == 'no_ads' && acc.hasNoAds) isActive = true;
                        if (perk.id == 'double_coins' && acc.hasDoubleCoins) isActive = true;
                        if (perk.id == 'frame_gold' && acc.activeFrame == 'gold') isActive = true;
                        if (perk.id == 'avatar_duo' && acc.unlockedAvatars.contains('🦉')) isActive = true;
                        if (perk.id == 'sobir_pro' && acc.isPremium) isActive = true;

                        final canAfford = acc.coins >= perk.coinPrice;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isActive ? AppColors.primaryGreen : Colors.black12,
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(perk.icon, style: const TextStyle(fontSize: 24)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            perk.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('FAOLLASHTIRILGAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      perk.description,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Narxi: ${perk.coinPrice} 🪙',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 14),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isActive ? Colors.grey.shade400 : (canAfford ? AppColors.primaryGreen : Colors.grey.shade300),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            elevation: 0,
                                          ),
                                          onPressed: isActive ? null : () => _buyPerk(context, perk),
                                          child: Text(
                                            isActive
                                                ? 'Olingan'
                                                : (perk.id == 'streak_freeze' && acc.streakFreezes > 0
                                                    ? '+1 olish'
                                                    : 'Sotib olish'),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    // TAB 2: COIN OLISH (BUY PACKAGES & WATCH ADS)
                    ListView(
                      children: [
                        // Watch ad card (Balanced: 5 coins, 10 if double booster)
                        if (!acc.hasNoAds)
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Text('📺', style: TextStyle(fontSize: 26)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Bepul Coin olish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(
                                        'Qisqa reklama ko\'rib +${acc.hasDoubleCoins ? 10 : 5} Coin oling',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _isWatchingAd ? null : () => _watchAd(context),
                                  child: _isWatchingAd
                                      ? Text('$_adCountdown s...')
                                      : const Text('Tomosha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),

                        const Text('Sotib olish paketlari (So\'mda):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        // Packages list (Click, Payme, Uzum - Unchanged as requested!)
                        ...state.coinPackages.map((pkg) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: pkg.isPopular ? AppColors.gold : Colors.black12,
                                width: pkg.isPopular ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('🪙', style: TextStyle(fontSize: 20)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('${pkg.coins} Coin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          if (pkg.isPopular) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                                              child: const Text('HIT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text('Bonus: ${pkg.bonus}', style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _showPaymentModal(context, pkg),
                                  child: Text('${pkg.priceUzs} so\'m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
