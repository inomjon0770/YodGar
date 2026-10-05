import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DayNightHeader extends StatefulWidget {
  final bool isDay;
  final VoidCallback onToggle;
  final String greeting;
  final String userName;
  final int streak;
  final int coins;
  final VoidCallback onCoinsTap;

  const DayNightHeader({
    super.key,
    required this.isDay,
    required this.onToggle,
    required this.greeting,
    required this.userName,
    required this.streak,
    required this.coins,
    required this.onCoinsTap,
  });

  @override
  State<DayNightHeader> createState() => _DayNightHeaderState();
}

class _DayNightHeaderState extends State<DayNightHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final cloudOffset = _animController.value * 25.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDay
                  ? [
                      const Color(0xFF4A90E2),
                      const Color(0xFF50E3C2),
                      const Color(0xFFF8F9FA),
                    ]
                  : [
                      const Color(0xFF0F2027),
                      const Color(0xFF203A43),
                      const Color(0xFF2C5364),
                    ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isDay ? AppColors.primaryBlue : Colors.black)
                    .withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Celestial bodies & Clouds
              Positioned(
                right: 15,
                top: 5,
                child: widget.isDay
                    ? _buildSun()
                    : _buildMoon(),
              ),

              // Animated Cloud 1
              Positioned(
                right: 70 + cloudOffset,
                top: 15,
                child: Opacity(
                  opacity: widget.isDay ? 0.85 : 0.45,
                  child: const Icon(Icons.cloud_rounded,
                      color: Colors.white, size: 48),
                ),
              ),

              // Animated Cloud 2
              Positioned(
                right: 20 - cloudOffset,
                top: 38,
                child: Opacity(
                  opacity: widget.isDay ? 0.7 : 0.35,
                  child: const Icon(Icons.cloud_rounded,
                      color: Colors.white, size: 36),
                ),
              ),

              // Header content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App brand badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '📖 YODGAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onToggle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.isDay
                                      ? Colors.amber.shade400
                                      : Colors.indigo.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.isDay ? '☀️ Kunduz' : '🌙 Tun',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Coins & Streak Badges
                      Row(
                        children: [
                          // Streak badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.orangeFlame.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orangeFlame
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.streak} kun',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Coins badge (clickable to open shop)
                          GestureDetector(
                            onTap: widget.onCoinsTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Text('🪙', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.coins}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.add_circle,
                                      size: 14, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Greeting & Motivation
                  Text(
                    widget.greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSun() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD54F),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCA28).withValues(alpha: 0.7),
            blurRadius: 24,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildMoon() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE0E0E0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB0BEC5).withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 6,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.nightlight_round, color: Color(0xFFFFF9C4), size: 26),
      ),
    );
  }
}
